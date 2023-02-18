#!/bin/sh
set -x

sed 's/sudo git clone .* iso-profiles/true/' manjaro-iso-action/action.yml

git clone --depth 1 https://gitlab.manjaro.org/profiles-and-settings/iso-profiles

for i in $(< exclude.txt)
do
	find iso-profiles -type f | xargs sed -i "/^${i}/d'
done

cat include.txt >> iso-profiles/manjaro/gnome/Packages-Desktop
cat profile.conf >> iso-profiles/manjaro/gnome/profile.conf
