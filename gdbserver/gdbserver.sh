#!/bin/bash

function print_so_mem_addr()
{
    if [ -f so.fn ];then
	so_file_name=$(sed -ne '1p' so.fn |tr -d '\r' | tr -d '\n')
	adb shell cat /proc/$pid/maps |grep $so_file_name
    fi
}

if [ $# -ge 1 ];then
	grep_ps_name="$1"
else
	grep_ps_name="system_server"
fi

pid=$(adb shell ps | grep "$grep_ps_name" | awk '{print $2}')
echo "pid: $pid"

if [ "x$pid" != "x" ];then
    
    adb forward tcp:5000 tcp:5000

    print_so_mem_addr
    
    echo "adb shell gdbserver :5000 --attach $pid"
    adb shell gdbserver :5000 --attach $pid
else
    echo "can't find $grep_ps_name"
fi
