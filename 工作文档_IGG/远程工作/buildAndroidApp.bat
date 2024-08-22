rem "C:\Program Files\Unity\Hub\Editor\2019.4.17f1c1\Editor\Unity.exe" -projectPath E:/source/eoc_client_android -batchmode -executeMethod CommandBuilder.BuildBundle -buildTarget android -APP_VERSION 1 -BUILD_NUMBER 388

rem -projectPath E:/source/eoc_client_android ^
rem -batchmode -executeMethod CommandBuilder.BuildAndroidApp -buildTarget android ^
rem -APP_VERSION 0.0.1 -DEVELOPMENT false -BUILD_NUMBER 400 -APP_BUNDLE true ^
rem -DEFINE_SYMBOLS UNITY_POST_PROCESSING_STACK_V2;GAME_DEBUG;HOTFIX_ENABLE

"D:\Unity\Hub\Editor\2019.4.17f1c1\Editor\Unity.exe" ^
-projectPath E:/source/eoc_client_release_android ^
-batchmode -executeMethod ABSystemNew.CommandBuilder.BuildAndroidApp -buildTarget android ^
-APP_VERSION 1.0.3 -BUILD_NUMBER 40 -DEVELOPMENT false -APP_BUNDLE false ^
-DEFINE_SYMBOLS DISABLE_ILRUNTIME_DEBUG;PLATFORM_IGG

pause

