set -e

DEPS_DIR="deps"
VERSION_DB=$(pwd)/deps/versions.lua
rm -rf $VERSION_DB

echo "return {" >> $VERSION_DB

for SUBMODULE in "$DEPS_DIR"/*/*; do
	if [ -f "$SUBMODULE/.git" ] || [ -d "$SUBMODULE/.git" ]; then
		
		cd "$SUBMODULE"
		GIT_RELEASE_TAG=$(git describe --tags --abbrev=0 --always)
		GIT_COMMIT_HASH=$(git rev-parse HEAD)
		cd - > /dev/null
		
		echo "Using commit $GIT_COMMIT_HASH with tag $GIT_RELEASE_TAG for submodule $SUBMODULE"
		
		# Output in a stupid simple format so that it can easily be require'd
		echo "	[\"$SUBMODULE\"] = { commit = \"$GIT_COMMIT_HASH\", tag = \"$GIT_RELEASE_TAG\" }," >> $VERSION_DB
	else
		echo "No .git directory (or file) found in $SUBMODULE"	
	fi
done

echo "}" >> $VERSION_DB