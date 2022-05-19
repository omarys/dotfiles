cd ~/Dev/ccls/
git pull
cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/use/bin/clang
cmake --build Release
