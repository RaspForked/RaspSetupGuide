#!/bin/bash

rotate="rotating"
notrotate="not_rotating"

filename="/tmp/sda_sd2.status"
rotatestate="/tmp/sda_sd2_current.status"
nextmuststop="/tmp/sda_sd2_nextmuststop.status"
mtrue="true"
mfalse="false"


if [ ! -f "${nextmuststop}" ]; then
    echo ${mfalse} > ${nextmuststop}
fi

if [ ! -f "${rotatestate}" ]; then
    echo ${rotating} > ${rotatestate}
fi

currentrotatestate=`cat ${rotatestate}`
cuurnextmuststop=`cat ${nextmuststop}`

stat_new=`cat /sys/block/sda/sda2/stat | tr -dc "[:digit:]"`
if [ -f "${filename}" ]; then
    stat_old=`cat ${filename} | tr -dc "[:digit:]"`

    echo "${stat_old}"
    echo "${stat_new}"

    if [ "${stat_old}" == "${stat_new}" ]; then
        if [ "${cuurnextmuststop}" == "${mtrue}" ]; then
            if [ "${rotate}" == "${currentrotatestate}" ]; then
                sudo  hdparm -y /dev/sda2
                echo ${notrotate} > ${rotatestate}
                echo "disk shutted down"
            else
                echo "disk is already shutdown no need to do"
            fi
        else
            echo "disk is not using we will shutdown next"
            echo ${mtrue} > ${nextmuststop}
        fi
    else
        echo "disk is using"
        echo ${stat_new} > ${filename}
        echo ${mfalse} > ${nextmuststop}
        echo ${rotate} > ${rotatestate}
    fi
else
    echo "nofile"
    echo ${stat_new} > ${filename}
    echo ${mfalse} > ${nextmuststop}
    echo ${rotate} > ${rotatestate}
fi

