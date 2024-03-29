#!/bin/bash
set -ex

curl -skLo /tmp/transferwee.py https://raw.githubusercontent.com/iamleot/transferwee/master/transferwee.py

FILE=$1

split --verbose -d -b 1500M ${FILE} ${FILE}.
for f in $(ls ${FILE}.0*)
do
t_data=$(python3 /tmp/transferwee.py upload -v $f)
FILENAME=$(basename $f)
SIZE="$(du -h $f | awk '{print $1}')"
data="$FILENAME-$SIZE-${t_data}"
curl -skLo /dev/null "https://wxpusher.zjiecode.com/api/send/message/?appToken=${WXPUSHER_APPTOKEN}&uid=${WXPUSHER_UID}&content=${data}"
done
