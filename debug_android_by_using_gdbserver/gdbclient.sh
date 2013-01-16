#!/bin/bash -

function product_dir()
{
    local imgout=out/target/product/
    if [ -d "$imgout" ];then
	local recent_product_dir=$(ls -latr $imgout \
	    | tail -n 1 | awk '{print $NF}');
	echo "$imgout/${recent_product_dir}"
    else
	echo "NO_PRODUCT_DIR"
    fi
}

function cal_debug_so_mem_addr()
{
#add-symbol-file /home/karlzheng/dev/android-4.0.4_r1.1/out/target/product/smdk4x12/symbols/system/lib/libbluedroid.so 0x409ef854

# where 0x409ef854 is calculated by:
#adb shell cat /proc/1609/maps |grep blue
#409ef000-409f1000 r-xp 00000000 b3:02 517        /system/lib/libbluedroid.so
#409f1000-409f2000 rw-p 00002000 b3:02 517        /system/lib/libbluedroid.so
#
#karlzheng@latop-dell780:~/dev/android-4.0.4_r1.1/out/target/product/smdk4x12/symbols/system/lib$
#arm-linux-androideabi-objdump -h libbluedroid.so |grep -i tex
#  6 .text         000005d8  00000854  00000854  00000854  2**2

# 409ef000 + offset 00000854

    if [ -f debug_so.txt ];then
	local fn=$(sed -ne '1p' debug_so.txt |tr -d '\r' | tr -d '\n')
	echo "adb shell cat /proc/$pid/maps | grep $fn"
	local base="0x"$(adb shell cat /proc/$pid/maps | grep $fn \
	    | head -n 1 | awk -F'-' '{print $1}')
	if [ $base == "0x" ];then
	    echo "can't locate debug so base address!"
	    exit 1
	fi
	echo "find $ANDROID_PRODUCT_ROOT/symbols/system/lib/ -name $fn"
	local so=$(find $ANDROID_PRODUCT_ROOT/symbols/system/lib/ -name "$fn")
	echo "so : $so"
	local off="0x"$(arm-objdump -h $so | grep -i text | awk '{print $3}')
	local map=$(printf "0x%x" $(($base+$off)))
	echo "$base $off $map"
	echo "add-symbol-file $so $map" >> $GDB_INIT_FILE
    else
	echo "#add-symbol-file $ANDROID_PRODUCT_ROOT/symbols/system/lib/x.so \
	    0x" >> $GDB_INIT_FILE
    fi

}

function gen_gdb_init_file()
{
    export ANDROID_SRC_ROOT="$(pwd)"
    ANDROID_PRODUCT_ROOT="$ANDROID_SRC_ROOT/$(product_dir)"
    echo "ANDROID_PRODUCT_ROOT : $ANDROID_PRODUCT_ROOT"
    if [ "x$ANDROID_PRODUCT_ROOT" == "xNO_PRODUCT_DIR" ];then
	echo "can't find ANDROID_PRODUCT_ROOT!"
	exit 1
    fi

    GDB_INIT_FILE=".gdbinit"
    if [ -f $GDB_INIT_FILE ];then
	echo "/bin/mv $GDB_INIT_FILE $GDB_INIT_FILE.old"
	/bin/mv $GDB_INIT_FILE $GDB_INIT_FILE.old
    fi
    : > $GDB_INIT_FILE
    echo "directory $ANDROID_SRC_ROOT" >> $GDB_INIT_FILE
    echo "set sysroot $ANDROID_PRODUCT_ROOT/symbols" >> $GDB_INIT_FILE
    echo "set solib-absolute-prefix $ANDROID_PRODUCT_ROOT/symbols/system" \
	>> $GDB_INIT_FILE
    echo "set solib-search-path $ANDROID_PRODUCT_ROOT/symbols/system/lib" \
	>> $GDB_INIT_FILE
    echo "show solib-absolute-prefix" >> $GDB_INIT_FILE
    echo "show solib-search-path" >> $GDB_INIT_FILE
    
    cal_debug_so_mem_addr

    echo "target remote :5000" >> $GDB_INIT_FILE
    cat $GDB_INIT_FILE
    echo ""
    echo ""
}

if [ $# -ge 1 ];then
	grep_ps_name="$1"
else
	grep_ps_name="system_server"
fi

pid=$(adb shell ps | grep "$grep_ps_name" | awk '{print $2}' | tail -n 1)
echo "$grep_ps_name pid: $pid "

gen_gdb_init_file

arm-gdb

