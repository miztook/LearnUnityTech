 #!/bin/sh

root_path=$(cd "$(dirname "$0")"; pwd)
echo $root_path
cd $root_path

DO_WGET="/usr/local/bin/wget -q"
DO_WPUT="/usr/local/bin/wput -q"
DO_XCODEBUILD="xcodebuild"
CHMOD_PERMISSION="chmod -R 777 $root_path"

##################################################################
#						local need fix var
##################################################################

FTP_BACKUP_USERNAME="tera"
FTP_BACKUP_PASSWORD="tera"
FTP_BACKUP_IP="ftp://10.35.51.37"

FTP_PACKAGE_USERNAME="tera"
FTP_PACKAGE_PASSWORD="tera"
FTP_PACKAGE_IP="10.35.51.37"


CLIENT_SVN_PATH="svn://10.35.49.171/M1Client"
SVN_USERNAME="publisher"
SVN_PASSWORD="tera"

##################################################################
#							ifnput var
##################################################################
PROJECT_NAME=$1
BRANCH_PATH=$2
BASEVERSION=$3
CURRENTVERSION=$4
FTP_BACKUP_DOWNLOAD_PATH=$5
SVN_REVISION=$6
IPA_NAME=$7
COMPLATFORM=$8
SMALL_PACK=$9
LOCAL_WORKSPACE_PATH=${10}
UNITY_PATH="${11}/Unity.app/Contents/MacOS/Unity"
UNITY_DEFINE="IN_GAME;"

echo "PROJECT_NAME = $PROJECT_NAME"
echo "BRANCH_PATH = $BRANCH_PATH"
echo "BASEVERSION = $BASEVERSION"
echo "CURRENTVERSION = $CURRENTVERSION"
echo "FTP_BACKUP_DOWNLOAD_PATH = $FTP_BACKUP_DOWNLOAD_PATH"
echo "SVN_REVISION = $SVN_REVISION"

PROJ_CODE_SIGN="iPhone Developer: Xin Huang (396999LAWD)"
PROJ_PROVISIONING_PROFILE="tera-all"

##################################################################
#							auto fixed var
##################################################################
SVN_CHECKOUT_PATH="$CLIENT_SVN_PATH/$BRANCH_PATH"
LOCAL_M1CLIENT_PATH="$LOCAL_WORKSPACE_PATH/M1Client"
LOCAL_CLIENT_PATH="$LOCAL_M1CLIENT_PATH/$BRANCH_PATH"

PROJECT_PATH="$LOCAL_CLIENT_PATH/UnityProject"
RESCOURCE_COPY_PATH_FROM="$LOCAL_CLIENT_PATH/GameRes/"
RESCOURCE_COPY_PATH_DEST="$PROJECT_PATH/Assets/StreamingAssets/res_base"

#Xcode Export path
XCODE_PROJECT_PATH=$PROJECT_PATH/$PROJECT_NAME

DOSVN="svn --username $SVN_USERNAME --password $SVN_PASSWORD --no-auth-cache"
DOCLIENT="$UNITY_PATH -projectPath $PROJECT_PATH project-$PROJECT_NAME -buildTarget ios -batchmode -quit -logFile $PROJECT_PATH/M1Build.log"

if [ "$SVN_REVISION" -eq "0" ]; then
	SVN_REVISION="HEAD"
fi

# unable files & need delete before unity export, or unity crash
RESOURCE_DEL_NAMES=("$PROJECT_PATH/Assets/Plugins/x86_64"
	"$PROJECT_PATH/Assets/Plugins/x86"
	"$PROJECT_PATH/Assets/Plugins/Android"
	"$PROJECT_PATH/Assets/StreamingAssets/Audio/GeneratedSoundBanks/Android"
	"$PROJECT_PATH/Assets/StreamingAssets/Audio/GeneratedSoundBanks/Mac"
	"$PROJECT_PATH/Assets/StreamingAssets/Audio/GeneratedSoundBanks/Windows")

WWISE_DEL_NAMES=("$RESCOURCE_COPY_PATH_FROM/Audio/GeneratedSoundBanks/Android"
	"$RESCOURCE_COPY_PATH_FROM/Audio/GeneratedSoundBanks/Windows"
	)

# fixed api backup & need replace xcode project from unity export
FIEXED_UNITY_API_FROM_PATHS=("$LOCAL_CLIENT_PATH/BuildTools/UNITY_FIXED/UnityViewControllerBaseiOS.mm")
# FIEXED_UNITY_API_FROM_PATHS=("$LOCAL_CLIENT_PATH/BuildTools/UNITY_FIXED/Keyboard.mm"
# 	"$LOCAL_CLIENT_PATH/BuildTools/UNITY_FIXED/UnityViewControllerBaseiOS.mm")

FIEXED_UNITY_API_FROM_PATH="$LOCAL_CLIENT_PATH/BuildTools/UNITY_FIXED/Keyboard.mm"
FIEXED_UNITY_API_DEST_PATH="$PROJECT_PATH/$PROJECT_NAME/Classes/UI/"

# fixed UIApplicationExitsOnSuspend without upgrade unity...
FIEXED_UNITY_INFO_PLIST_FROM_PATH="$LOCAL_CLIENT_PATH/BuildTools/UNITY_FIXED/Info.plist"
FIEXED_UNITY_INFO_PLIST_DEST_PATH="$PROJECT_PATH/$PROJECT_NAME/

# ftp assetbundle info
FTP_DOWNLOAD_FULL_PATH="$FTP_BACKUP_IP/$FTP_BACKUP_DOWNLOAD_PATH"
LOCAL_ASSETBUNLE_PATH="$RESCOURCE_COPY_PATH_FROM/Assetbundles/iOS"
LOCAL_ASSETBUNLE_UPDATE_PATH="$LOCAL_ASSETBUNLE_PATH/Update"

# fix upload package dest host/path
FTP_PACKAGE_UPLOAD_PATH="$FTP_PACKAGE_IP/Package_Backup/iOS"

# fix upload dsym dest host/path
FTP_DSYMS_UPLOAD_PATH="$FTP_PACKAGE_IP/Package_Backup/dsyms"


##################################################################
#						Tera iOS Autobuild Logic
##################################################################

if [ -d "$LOCAL_CLIENT_PATH" ]; then
	rm -rf "$LOCAL_CLIENT_PATH"
fi
if [ ! -d "$LOCAL_CLIENT_PATH" ]; then
	mkdir "$LOCAL_CLIENT_PATH"
fi
$CHMOD_PERMISSION
echo "svn checkout -r $SVN_REVISION"
$DOSVN checkout $SVN_CHECKOUT_PATH -r $SVN_REVISION $LOCAL_CLIENT_PATH
echo "svn success"


$CHMOD_PERMISSION
echo "Clear old unity export project before build"
if [ -d "$XCODE_PROJECT_PATH" ]; then
	rm -rf $XCODE_PROJECT_PATH
fi


# ftp download backup Assetbundle
if [ -d $LOCAL_ASSETBUNLE_PATH ]; then
	rm -rf $LOCAL_ASSETBUNLE_PATH
fi
mkdir $LOCAL_ASSETBUNLE_PATH



if [ "$SMALL_PACK" -eq "0" ]; then
	$CHMOD_PERMISSION
	echo "Download $CURRENTVERSION Assetbundle Base"
	cd $LOCAL_ASSETBUNLE_PATH
	$DO_WGET -nH --ftp-user=$FTP_BACKUP_USERNAME --ftp-password=$FTP_BACKUP_PASSWORD $FTP_DOWNLOAD_FULL_PATH/Base/*
	# FIXME::Sound tmp, fix ftp backup or res export
	rm -rf $LOCAL_ASSETBUNLE_PATH/sound

	if [ -d $LOCAL_ASSETBUNLE_UPDATE_PATH ]; then
		rm -rf $LOCAL_ASSETBUNLE_UPDATE_PATH
	fi
	mkdir $LOCAL_ASSETBUNLE_UPDATE_PATH


	$CHMOD_PERMISSION
	if [ "$BASEVERSION" != "$CURRENTVERSION" ]; then
		echo "Download $CURRENTVERSION Assetbundle Update"
		cd $LOCAL_ASSETBUNLE_UPDATE_PATH
		$DO_WGET -nH --ftp-user=$FTP_BACKUP_USERNAME --ftp-password=$FTP_BACKUP_PASSWORD $FTP_DOWNLOAD_FULL_PATH/Update_$CURRENTVERSION/*
	fi
fi


$CHMOD_PERMISSION
echo "clean old files"
rm -rf $RESCOURCE_COPY_PATH_DEST/*
echo "clean old files success"

echo "clean Wwise"
for delPath in ${WWISE_DEL_NAMES[@]}
do
	echo "Delete file: "$delPath
	rm -rf $delPath
done

if [ "$SMALL_PACK" -eq "0" ]; then
	cp -rf $RESCOURCE_COPY_PATH_FROM $RESCOURCE_COPY_PATH_DEST
	echo "copy need files success"
fi

del unable files
for delPath in ${RESOURCE_DEL_NAMES[@]}
do
	echo "Delete file: "$delPath
	rm -rf $delPath
done
echo "clean unable files success"

echo "fix DefineSymbols"
if [[ $COMPLATFORM =~ "deploy" ]]; then
	echo "deploy platform define"
	UNITY_DEFINE=${UNITY_DEFINE}"USING_FABRIC;PLATFORM_KAKAO;"
else #if [[ $COMPLATFORM =~ "cn" ]]; then
	echo "non-deploy platform define"
	UNITY_DEFINE=${UNITY_DEFINE}""
fi

$CHMOD_PERMISSION
# export xcode project
echo "SwitchIos"
$DOCLIENT -executeMethod BuildTools.SwitchIos
echo "fix graphic setting"
$DOCLIENT -executeMethod BuildTools.FixGraphicSetting_iOS
echo "set client base version"
$DOCLIENT -executeMethod BuildTools.SetClientBaseVersion "$BASEVERSION"
echo "set complatform"
$DOCLIENT -executeMethod BuildTools.SetComplatform "$COMPLATFORM"
echo "SetDefine"
$DOCLIENT -executeMethod BuildTools.SetScriptingDefineSymbols $UNITY_DEFINE
echo "PrebuildClient"
$DOCLIENT -executeMethod BuildTools.PrebuildClient
echo "export xcode project"
$DOCLIENT -executeMethod BuildTools.BuildForIPhone


$CHMOD_PERMISSION
for copy_src_path in ${FIEXED_UNITY_API_FROM_PATHS[@]}
do
	echo "Copy file: "$copy_src_path
	cp -rf $copy_src_path $FIEXED_UNITY_API_DEST_PATH
done
cp -rf "$FIEXED_UNITY_INFO_PLIST_FROM_PATH $FIEXED_UNITY_INFO_PLIST_DEST_PATH"
echo "fix unity api from localbackup succeed"


# xcode编译，生成ipa
IPA_PROJECT_PATH="$PROJECT_PATH/$PROJECT_NAME"

# build文件夹路径
IPA_BUILD_PATH="$IPA_PROJECT_PATH/build"

# IPA NAME
Today=`date +"%Y-%m-%d"`
XCODE_PLIST_PATH="$LOCAL_CLIENT_PATH/BuildTools/UNITY_FIXED"


cd "$IPA_PROJECT_PATH"
echo "processing"

$CHMOD_PERMISSION
echo "export ipa..."
#打包 输出ipa
$DO_XCODEBUILD archive -scheme "Unity-iPhone" -configuration Release -sdk iphoneos -archivePath "$IPA_BUILD_PATH/Unity-iPhone.xcarchive" CODE_SIGN_IDENTITY="$PROJ_CODE_SIGN" PROVISIONING_PROFILE_SPECIFIER="$PROJ_PROVISIONING_PROFILE"


$CHMOD_PERMISSION
$DO_XCODEBUILD -exportArchive -archivePath "$IPA_BUILD_PATH/Unity-iPhone.xcarchive" -exportOptionsPlist "$XCODE_PLIST_PATH/ExportOptions.plist" -exportPath "$IPA_BUILD_PATH"


# tar dsym
echo "tar dsym..."
cd "$IPA_BUILD_PATH"
tar cvf "dsym.tar" "Unity-iPhone.xcarchive"

echo "copy to package"
PACKAGE_PATH="$LOCAL_M1CLIENT_PATH/Package"
if [ -d "$PACKAGE_PATH" ]; then
	rm -rf $PACKAGE_PATH
fi
mkdir "$PACKAGE_PATH"

$CHMOD_PERMISSION
cp -rf "$IPA_BUILD_PATH/dsym.tar" "$PACKAGE_PATH/$IPA_NAME.tar"

$CHMOD_PERMISSION
# upload ipa to ftp
echo "upload ipa to ftp"
cd "$PACKAGE_PATH"
$DO_WPUT -B * ftp://$FTP_PACKAGE_USERNAME:$FTP_PACKAGE_PASSWORD@$FTP_DSYMS_UPLOAD_PATH/


echo "copy to package"
PACKAGE_PATH="$LOCAL_M1CLIENT_PATH/Package"
if [ -d "$PACKAGE_PATH" ]; then
	rm -rf $PACKAGE_PATH
fi
mkdir "$PACKAGE_PATH"

$CHMOD_PERMISSION
cp -rf "$IPA_BUILD_PATH/Unity-iPhone.ipa" "$PACKAGE_PATH/$IPA_NAME"


$CHMOD_PERMISSION
# upload ipa to ftp
echo "upload ipa to ftp"
cd "$PACKAGE_PATH"
$DO_WPUT -B * ftp://$FTP_PACKAGE_USERNAME:$FTP_PACKAGE_PASSWORD@$FTP_PACKAGE_UPLOAD_PATH/


echo "All iOS Export Success!"