// Copied from luajit.c on Feb 09, 2024 at 0d313b2 - see the original license below.

/*
** LuaJIT frontend. Runs commands, scripts, read-eval-print (REPL) etc.
** Copyright (C) 2005-2023 Mike Pall. See Copyright Notice in luajit.h
**
** Major portions taken verbatim or adapted from the Lua interpreter.
** Copyright (C) 1994-2008 Lua.org, PUC-Rio. See Copyright Notice in lua.h
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define luajit_c

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "luajit.h"

#include "lj_arch.h"

#if LJ_TARGET_POSIX
#include <unistd.h>
#define lua_stdin_is_tty() isatty(0)
#elif LJ_TARGET_WINDOWS
#include <io.h>
#ifdef __BORLANDC__
#define lua_stdin_is_tty() isatty(_fileno(stdin))
#else
#define lua_stdin_is_tty() _isatty(_fileno(stdin))
#endif
#else
#define lua_stdin_is_tty() 1
#endif

#if !LJ_TARGET_CONSOLE
#include <signal.h>
#endif

static lua_State* globalL = NULL;
static const char* progname = LUA_PROGNAME;
static char* empty_argv[2] = { NULL, NULL };

#if !LJ_TARGET_CONSOLE
static void lstop(lua_State* L, lua_Debug* ar) {
	(void)ar; /* unused arg. */
	lua_sethook(L, NULL, 0, 0);
	/* Avoid luaL_error -- a C hook doesn't add an extra frame. */
	luaL_where(L, 0);
	lua_pushfstring(L, "%sinterrupted!", lua_tostring(L, -1));
	lua_error(L);
}

static void laction(int i) {
	signal(i, SIG_DFL); /* if another SIGINT happens before lstop,
			   terminate process (default action) */
	lua_sethook(globalL, lstop, LUA_MASKCALL | LUA_MASKRET | LUA_MASKCOUNT, 1);
}
#endif

static void l_message(const char* msg) {
	if(progname) {
		fputs(progname, stderr);
		fputc(':', stderr);
		fputc(' ', stderr);
	}
	fputs(msg, stderr);
	fputc('\n', stderr);
	fflush(stderr);
}

static int report(lua_State* L, int status) {
	if(status && !lua_isnil(L, -1)) {
		const char* msg = lua_tostring(L, -1);
		if(msg == NULL) msg = "(error object is not a string)";
		l_message(msg);
		lua_pop(L, 1);
	}
	return status;
}

static int traceback(lua_State* L) {
	if(!lua_isstring(L, 1)) { /* Non-string error object? Try metamethod. */
		if(lua_isnoneornil(L, 1) || !luaL_callmeta(L, 1, "__tostring") || !lua_isstring(L, -1))
			return 1; /* Return non-string error object. */
		lua_remove(L, 1); /* Replace object by result of __tostring metamethod. */
	}
	luaL_traceback(L, L, lua_tostring(L, 1), 1);
	return 1;
}

static int docall(lua_State* L, int narg, int clear) {
	int status;
	int base = lua_gettop(L) - narg; /* function index */
	lua_pushcfunction(L, traceback); /* push traceback function */
	lua_insert(L, base); /* put it under chunk and args */
#if !LJ_TARGET_CONSOLE
	signal(SIGINT, laction);
#endif
	status = lua_pcall(L, narg, (clear ? 0 : LUA_MULTRET), base);
#if !LJ_TARGET_CONSOLE
	signal(SIGINT, SIG_DFL);
#endif
	lua_remove(L, base); /* remove traceback function */
	/* force a complete garbage collection in case of errors */
	if(status != LUA_OK) lua_gc(L, LUA_GCCOLLECT, 0);
	return status;
}

static void write_prompt(lua_State* L, int firstline) {
	const char* p;
	lua_getfield(L, LUA_GLOBALSINDEX, firstline ? "_PROMPT" : "_PROMPT2");
	p = lua_tostring(L, -1);
	if(p == NULL) p = firstline ? LUA_PROMPT : LUA_PROMPT2;
	fputs(p, stdout);
	fflush(stdout);
	lua_pop(L, 1); /* remove global */
}

static int incomplete(lua_State* L, int status) {
	if(status == LUA_ERRSYNTAX) {
		size_t lmsg;
		const char* msg = lua_tolstring(L, -1, &lmsg);
		const char* tp = msg + lmsg - (sizeof(LUA_QL("<eof>")) - 1);
		if(strstr(msg, LUA_QL("<eof>")) == tp) {
			lua_pop(L, 1);
			return 1;
		}
	}
	return 0; /* else... */
}

static int pushline(lua_State* L, int firstline) {
	char buf[LUA_MAXINPUT];
	write_prompt(L, firstline);
	if(fgets(buf, LUA_MAXINPUT, stdin)) {
		size_t len = strlen(buf);
		if(len > 0 && buf[len - 1] == '\n')
			buf[len - 1] = '\0';
		if(firstline && buf[0] == '=')
			lua_pushfstring(L, "return %s", buf + 1);
		else
			lua_pushstring(L, buf);
		return 1;
	}
	return 0;
}

static int loadline(lua_State* L) {
	int status;
	lua_settop(L, 0);
	if(!pushline(L, 1))
		return -1; /* no input */
	for(;;) { /* repeat until gets a complete line */
		status = luaL_loadbuffer(L, lua_tostring(L, 1), lua_strlen(L, 1), "=stdin");
		if(!incomplete(L, status)) break; /* cannot try to add lines? */
		if(!pushline(L, 0)) /* no more input? */
			return -1;
		lua_pushliteral(L, "\n"); /* add a new line... */
		lua_insert(L, -2); /* ...between the two lines */
		lua_concat(L, 3); /* join them */
	}
	lua_remove(L, 1); /* remove line */
	return status;
}

void dotty(lua_State* L) {
	int status;
	const char* oldprogname = progname;
	progname = NULL;
	while((status = loadline(L)) != -1) {
		if(status == LUA_OK) status = docall(L, 0, 0);
		report(L, status);
		if(status == LUA_OK && lua_gettop(L) > 0) { /* any result to print? */
			lua_getglobal(L, "print");
			lua_insert(L, 1);
			if(lua_pcall(L, lua_gettop(L) - 1, 0, 0) != 0)
				l_message(lua_pushfstring(L, "error calling " LUA_QL("print") " (%s)",
					lua_tostring(L, -1)));
		}
	}
	lua_settop(L, 0); /* clear stack */
	fputs("\n", stdout);
	fflush(stdout);
	progname = oldprogname;
}
