gaa       | git add --all
gdup      | git diff @{upstream}
gdw       | git diff --word-diff
ggl       | git pull origin $(current_branch)
ggp       | git push origin $(current_branch)
grhh      | git reset --hard
gpristine | git reset --hard && git clean -dffx

dnfl      | List packages
dnfli     | List installed packages
dnfgl     | List package groups
dnfmc     | Generate metadata cache
dnfs      | Search package

dnfu      | Upgrade package
dnfi      | Install package
dnfgi     | Install package group
dnfr      | Remove package
dnfgr     | Remove package group
dnfc      | Clean cache
