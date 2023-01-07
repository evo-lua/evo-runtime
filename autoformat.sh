stylua .

RELEVANT_C_FILES_TO_FORMAT=$(find . -type f -name "*.c" -print -o -name "*.h" -print -o -path "*/deps" -prune -o -path "*/build" -prune)
clang-format -i --verbose $RELEVANT_C_FILES_TO_FORMAT