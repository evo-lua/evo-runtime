# Since I've had to do this too many times already, just use this script from now on ...
SH_FILES=$(git ls-files | grep ".sh" | cut -f 2)

echo "Discovered .sh files:"
echo $SH_FILES

echo "Fixing up the executable flags ..."
echo $SH_FILES | xargs chmod +x

# Needs to actually be fixed up manually, I guess ...
# All this is complete rubbish, of course, but that's Windows for you
git add $SH_FILES
git commit -m "fixup"

