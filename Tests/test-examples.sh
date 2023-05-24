EXAMPLES_DIR="Tests/Snapshots"
LUA_RUNTIME="evo"
CLI_ARGS="cli args go here"
EXIT_CODE=0

for EXAMPLE_SCRIPT in $EXAMPLES_DIR/*.lua
do
    BASE_NAME=$(basename $EXAMPLE_SCRIPT .lua)
    OUTPUT_FILE=$EXAMPLES_DIR/$BASE_NAME.actual.txt
    EXPECTED_FILE=$EXAMPLES_DIR/$BASE_NAME.expected.txt
    
    echo "Running snapshot test for example $BASE_NAME..."
    
    $LUA_RUNTIME $EXAMPLE_SCRIPT $CLI_ARGS > $OUTPUT_FILE

    if diff -q $OUTPUT_FILE $EXPECTED_FILE >/dev/null
    then
        echo "PASS	$BASE_NAME"
    else
        echo "FAIL	$BASE_NAME"
        diff $OUTPUT_FILE $EXPECTED_FILE
        EXIT_CODE=1
    fi
done

rm $OUTPUT_FILE
exit $EXIT_CODE