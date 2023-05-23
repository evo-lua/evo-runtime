set -e

EXAMPLES_DIR="Tests/Snapshots"
LUA_RUNTIME="evo"
EXIT_CODE=0

for EXAMPLE_SCRIPT in $EXAMPLES_DIR/*.lua
do
    BASE_NAME=$(basename $EXAMPLE_SCRIPT .lua)
    OUTPUT_FILE=$EXAMPLES_DIR/$BASE_NAME.out.txt
    EXPECTED_FILE=$EXAMPLES_DIR/$BASE_NAME.expected.txt
    
    echo "Running snapshot test for example $BASE_NAME..."
    
    $LUA_RUNTIME $EXAMPLE_SCRIPT > $OUTPUT_FILE

    # diff $OUTPUT_FILE $EXPECTED_FILE
    if diff -q $OUTPUT_FILE $EXPECTED_FILE >/dev/null
    then
        echo "$BASE_NAME: PASSED"
    else
        echo "$BASE_NAME: FAILED"
        diff $OUTPUT_FILE $EXPECTED_FILE
        EXIT_CODE=1
    fi
	rm $OUTPUT_FILE
done

exit $EXIT_CODE