# This should be run after the build scripts, as it requires a ninja file to be present
ninja -t graph | dot -Tpng -odependency-graph.png
