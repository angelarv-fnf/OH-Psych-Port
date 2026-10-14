@echo off
color 0a
cd ..
@echo on
echo Installing dependencies for Psych Engine 0.7.3...

haxelib install lime 8.0.1
haxelib install openfl 9.3.2
haxelib install flixel 5.5.0
haxelib install flixel-addons 3.2.1
haxelib install flixel-ui 2.5.0
haxelib install flixel-tools 1.5.1
haxelib install tjson 1.4.0
haxelib install hxCodec 3.0.2
haxelib install hxdiscord_rpc 1.1.1
haxelib install hxcpp-debug-server 1.2.4

haxelib set lime 8.0.1
haxelib set openfl 9.3.2
haxelib set flixel 5.5.0
haxelib set flixel-addons 3.2.1
haxelib set flixel-ui 2.5.0
haxelib set flixel-tools 1.5.1
haxelib set tjson 1.4.0
haxelib set hxCodec 3.0.2
haxelib set hxdiscord_rpc 1.1.1
haxelib set hxcpp-debug-server 1.2.4

haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit

echo.
echo Setting recommended versions for 0.7.3 compatibility...

haxelib install SScript 7.7.0
haxelib set SScript 7.7.0

echo.
echo Done! You can now try compiling.
pause
