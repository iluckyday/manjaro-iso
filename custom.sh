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
NoExtract = usr/share/man/*
NoExtract = usr/share/vim/vim*/lang/*
NoExtract = usr/include/*
NoExtract = *__pycache__*
NoExtract = usr/share/doc/*
NoExtract = usr/share/gtk-doc/*
NoExtract = usr/share/help/*
NoExtract = usr/lib/firmware/amdgpu* usr/lib/firmware/nvidia* usr/lib/firmware/radeon*
NoExtract = */qemu-system-i386
NoExtract = usr/share/backgrounds/* !usr/share/backgrounds/manjaro/abstract-*
"

echo "${NOEXTRACT}" > /etc/pacman.conf.custom
sed -i '/pacman.conf/a\          cat /etc/pacman.conf.custom | sudo tee -a /etc/pacman.conf' manjaro-iso-action/action.yml
sed -i '/install_iso/a\          cat /etc/pacman.conf.custom | sudo tee -a /usr/share/manjaro-tools/pacman-*.conf' manjaro-iso-action/action.yml
# sed -i '/install_iso/a\          sudo sed -i "2i\set -x" /usr/lib/manjaro-tools/util-iso.sh' manjaro-iso-action/action.yml
sed -i '/install_iso/a\          sudo sed -i "/copytoram_size=/i\\\    copytoram=\\\"y\\\"" /etc/initcpio/hooks/miso' manjaro-iso-action/action.yml
sed -i '/install_iso/a\          sudo sed -i "/Generating SquashFS/i\\\    sed -i \\\"/configure_language/d\\\" \\\${src}/usr/bin/manjaro-live || true" /usr/lib/manjaro-tools/util-iso.sh' manjaro-iso-action/action.yml
sed -i '/install_iso/a\          sudo sed -i "/Generating SquashFS/i\\\    rm -rf \\\${src}/usr/lib/modules/*/vmlinuz" /usr/lib/manjaro-tools/util-iso.sh' manjaro-iso-action/action.yml
sed -i '/install_iso/a\          sudo sed -i "/Generating SquashFS/i\\\    rm -rf \\\${src}/usr/share/i18n/locales/*" /usr/lib/manjaro-tools/util-iso.sh' manjaro-iso-action/action.yml
sed -i '/install_iso/a\          sudo sed -i "/Generating SquashFS/i\\\    find \\\${src}/usr/*/locale -mindepth 1 -maxdepth 1 ! -name locale-archive ! -name locale.alias -prune -exec rm -rf {} + || true" /usr/lib/manjaro-tools/util-iso.sh' manjaro-iso-action/action.yml

cat include.txt >> iso-profiles/manjaro/gnome/Packages-Desktop
cat profile.conf >> iso-profiles/manjaro/gnome/profile.conf
echo password="\"${MANJARO_PASSWORD}\"" >> iso-profiles/manjaro/gnome/profile.conf
