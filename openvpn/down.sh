#!/bin/sh -x

BR=$1
DEV=$2

/sbin/brctl delif $BR $DEV
/sbin/ip link set "$DEV" down
