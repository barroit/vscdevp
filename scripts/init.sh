#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

test -n "$(git remote get-url origin)"
test -z "$(git log --oneline | grep -F 'init: setup repo from vscdevp')"

mkdir -p LICENSES
cp ../vscdevp/LICENSES/* LICENSES

mkdir -p image
cp ../vscdevp/image/* image

mkdir -p package
cp ../vscdevp/package/* package

mkdir -p .vscode
ln -sf ../vscdevp/.vscode/* .vscode

ln -sf ../vscdevp/helper
ln -sf ../vscdevp/Makefile

cp ../vscdevp/.vscodeignore .
cp ../vscdevp/.gitignore .

trap 'rm -f .tmp-$$.m4 .tmp-$$.grep' EXIT

remote_url()
{
	git remote get-url origin
}

cat <<EOF >.tmp-$$.m4
divert(-1)

define(\`NAME',   \`$(remote_url | awk -F[./] '{ print $3 }')')
define(\`REMOTE', \`$(remote_url)')
define(\`HOLDER', \`$(remote_url | awk -F[:/] '{ print $2 }')')

changequote([[, ]])

divert(0)dnl
EOF

while read file; do
	m4 .tmp-$$.m4 ../vscdevp/$file.in >$file

done <<-'EOF'
	package.json.in
	entry.js
EOF

cat <<'EOF' >.tmp-$$.grep
image/negi.png is licensed under LicenseRef-MDM-2.1.
EOF

if ! grep -xqFf .tmp-$$.grep README; then
	printf '\n' >>README
	cat .tmp-$$.grep >>README
fi

git add .
git commit -sm 'init: setup repo from vscdevp (need amend)'
