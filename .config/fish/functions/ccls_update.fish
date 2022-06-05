cd ~/Dev/ccls/
git pull
cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/bin/clang
cmake --build Release
