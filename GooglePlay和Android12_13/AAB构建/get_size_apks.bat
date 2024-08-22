set CUR_DIR=%~dp0
cd /d %CUR_DIR%

java -jar "E:\source\eoc_client_android\Assets\Packages\com.google.android.appbundle\Editor\Tools\bundletool-all.jar" ^
get-size total --apks=./2.apks

pause