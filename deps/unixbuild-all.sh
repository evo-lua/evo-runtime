set -e

deps/discover-submodule-versions.sh
ninjabuild-unix/BuildTools/generate-cdefs.lua

deps/luajit-unixbuild.sh
deps/webgpu-unixbuild.sh
deps/openssl-unixbuild.sh
deps/luaopenssl-unixbuild.sh
deps/rapidjson-unixbuild.sh
deps/luv-unixbuild.sh
deps/miniz-unixbuild.sh
deps/uws-unixbuild.sh
deps/zlib-unixbuild.sh
deps/pcre-unixbuild.sh
deps/glfw-unixbuild.sh
deps/rml-unixbuild.sh
deps/labsound-unixbuild.sh
