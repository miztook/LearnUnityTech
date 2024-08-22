set CUR_DIR=%~dp0
cd /d %CUR_DIR%

java -jar "E:\source\eoc_client_android\Assets\Packages\com.google.android.appbundle\Editor\Tools\bundletool-all.jar" ^
build-apks --bundle=2.aab ^
--output=2.apks ^
--ks="..\com_ipreto_android_empireofcrime.keystore" --ks-pass=pass:skyunion --ks-key-alias="empireofcrime" --key-pass=pass:skyunion

pause