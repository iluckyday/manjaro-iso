#!/bin/sh
set -x

sed -i 's/sudo git clone .* iso-profiles/true/' manjaro-iso-action/action.yml

git clone --depth 1 https://gitlab.manjaro.org/profiles-and-settings/iso-profiles

for i in $(< exclude.txt)
do
	find iso-profiles -type f -name "Packages-*" | xargs sed -i "/^${i}/d"
done

# disable Packages-Mhwd
echo busybox > iso-profiles/shared/Packages-Mhwd

NOEXTRACT="
[options]
NoExtract = usr/share/locale/* usr/share/X11/locale/*/* usr/share/i18n/locales/*
NoExtract = !*locale*/en*/* !usr/share/*locale*/locale.*
NoExtract = usr/share/man/* !usr/share/man/man*
NoExtract = usr/share/vim/vim*/lang/*
NoExtract = usr/include/*
NoExtract = *__pycache__*
NoExtract = usr/share/doc/*
"

echo "${NOEXTRACT}" > /etc/pacman.conf.custom
sed -i '/pacman.conf/a\          cat /etc/pacman.conf.custom | sudo tee -a /etc/pacman.conf' manjaro-iso-action/action.yml

cat include.txt >> iso-profiles/manjaro/gnome/Packages-Desktop
cat profile.conf >> iso-profiles/manjaro/gnome/profile.conf
echo password="\"${MANJARO_PASSWORD}\"" >> iso-profiles/manjaro/gnome/profile.conf
