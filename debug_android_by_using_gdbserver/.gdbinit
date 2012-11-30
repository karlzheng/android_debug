set history filename ~/.gdb_history
set history save
directory /home/karlzheng/dev/android-4.0.4_r1.1
#directory ${ANDROIDROOT}
set sysroot /home/karlzheng/dev/android-4.0.4_r1.1/out/target/product/smdk4x12/symbols/
set solib-absolute-prefix /home/karlzheng/dev/android-4.0.4_r1.1/out/target/product/smdk4x12/symbols/system
set solib-search-path /home/karlzheng/dev/android-4.0.4_r1.1/out/target/product/smdk4x12/symbols/system/lib
target remote :5000
add-symbol-file /home/karlzheng/dev/android-4.0.4_r1.1/out/target/product/smdk4x12/symbols/system/lib/libbluedroid.so 0x409ef854
#b /home/karlzheng/dev/android-4.0.4_r1.1/system/bluetooth/bluedroid/bluetooth.c:148
#file /home/karlzheng/dev/android-4.0.4_r1.1/out/target/product/smdk4x12/symbols/system/lib/libbluedroid.so
#b /home/karlzheng/dev/android-4.0.4_r1.1/system/bluetooth/bluedroid/bluetooth.c:bt_enable
#b system/bluetooth/bluedroid/bluetooth.c:bt_enable
