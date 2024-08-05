gaa       | git add --all
gdup      | git diff @{upstream}
gdw       | git diff --word-diff
ggl       | git pull origin $(current_branch)
ggp       | git push origin $(current_branch)
grhh      | git reset --hard
gpristine | git reset --hard && git clean -dffx

sed -i -e "s/\r//g"
sed -i -e "s/\e\[[0-9;]*m//g"
