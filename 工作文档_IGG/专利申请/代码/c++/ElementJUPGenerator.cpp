#include "ElementJUPGenerator.h"
#include "AFramework.h"
#include "FileOperate.h"
#include "AFI.h"
#include "function.h"
#include "AFileImage.h"
#include "AFilePackage.h"
#include <algorithm>
#include <map>

extern "C"
{
#include "packfunc_export.h"
}

#define KEEP_TMP_FOLDER 0

CElementJUPGenerator::CElementJUPGenerator()
{
	m_PlatformType = EPlatformType::Windows;
}

bool CElementJUPGenerator::Init(const std::string& strLastPath, const std::string& strNextPath, const std::string& strJupGeneratePath, bool bSmallPack)
{
	TCHAR szWorkDir[MAX_PATH];
	GetCurrentDirectory(MAX_PATH, szWorkDir);
	m_strWorkDir = szWorkDir;
	normalizeDirName(m_strWorkDir);
	//m_strTmpDir = m_strWorkDir + "tmp/";
	//FileOperate::MakeDir(m_strTmpDir);
	m_strCompressDir = m_strWorkDir + "compress/";
	FileOperate::MakeDir(m_strCompressDir.c_str());

	char szCurrentDir[MAX_PATH];
	GetCurrentDirectory(MAX_PATH, szCurrentDir);

	char szRet[MAX_PATH];
	Q_fullpath(strJupGeneratePath.c_str(), szRet, MAX_PATH);
	m_SConfig.JupGeneratePath = szRet;

	Q_fullpath(strLastPath.c_str(), szRet, MAX_PATH);
	m_SConfig.LastVersionPath = szRet;

	Q_fullpath(strNextPath.c_str(), szRet, MAX_PATH);
	m_SConfig.NextVersionPath = szRet;

	m_SConfig.bSmallPack = bSmallPack;

	return true;
}

void CElementJUPGenerator::SetPlatform(const std::string& strPlatformType)
{
	if (stricmp(strPlatformType.c_str(), "Windows") == 0)
		m_PlatformType = EPlatformType::Windows;
	else if (stricmp(strPlatformType.c_str(), "iOS") == 0)
		m_PlatformType = EPlatformType::iOS;
	else if (stricmp(strPlatformType.c_str(), "Android") == 0)
		m_PlatformType = EPlatformType::Android;
	else
	{
		printf("Unknown Platform! %s\r\n", (const char*)strPlatformType.c_str());
		g_pAFramework->Printf("Unknown Platform! %s\r\n", (const char*)strPlatformType.c_str());
	}
}

void CElementJUPGenerator::SetVersion(const std::string& strBaseVersion, const std::string& strLastVersion, const std::string& strNextVersion)
{
	m_SVersion.BaseVersion = strBaseVersion;
	m_SVersion.LastVersion = strLastVersion;
	m_SVersion.NextVersion = strNextVersion;
}

bool CElementJUPGenerator::GenerateUpdateList(const SVersion& sversion, SJupContent& jupContent) const
{
	ELEMENT_VER verOld;
	if (!verOld.Parse(sversion.LastVersion))
	{
		ASSERT(false);
		return false;
	}
	
	ELEMENT_VER verNew;
	if (!verNew.Parse(sversion.NextVersion))
	{
		ASSERT(false);
		return false;
	}

	if (verNew < verOld || verNew == verOld)
	{
		printf("Is not a new version! Check it first!\r\n");
		g_pAFramework->Printf("Is not a new version! Check it first!\r\n");

		return false;
	}

	jupContent.verOld = verOld;
	jupContent.verNew = verNew;
	jupContent.UpdateList.clear();

	std::string strPlatformAssetBundle = "AssetBundles/";
	std::string strPlatformAudio = "Audio/GeneratedSoundBanks/";
	switch (m_PlatformType)
	{
	case CElementJUPGenerator::Windows:
		strPlatformAssetBundle += "Windows";
		strPlatformAudio += "Windows";
		break;
	case CElementJUPGenerator::iOS:
		strPlatformAssetBundle += "iOS";
		strPlatformAudio += "iOS";
		break;
	case CElementJUPGenerator::Android:
		strPlatformAssetBundle += "Android";
		strPlatformAudio += "Android";
		break;
	default:
		break;
	}

	std::string strPlatformUpdateAssetBundle = strPlatformAssetBundle + "/Update";
	std::string strNextPath = this->m_SConfig.NextVersionPath;

	Q_iterateFiles(strNextPath.c_str(), "*.*",
		[strPlatformAssetBundle, strPlatformAudio, strPlatformUpdateAssetBundle, &jupContent, this](const char* filename)
	{
		//platform����
		//if (strstr(filename, "AssetBundles/") != 0 && strstr(filename, strPlatformAssetBundle) == 0)
		if (strstr(filename, "AssetBundles/") == (const char*)filename && strstr(filename, strPlatformAssetBundle.c_str()) != (const char*)filename)
		{
			printf("�ļ���ƽ̨����! filename: %s, platform: %s \r\n", filename, strPlatformAssetBundle.c_str());
			g_pAFramework->Printf("�ļ���ƽ̨����! filename: %s, platform: %s \r\n", filename, strPlatformAssetBundle.c_str());

			return;
		}

		if (strstr(filename, "Audio/GeneratedSoundBanks/") == (const char*)filename && strstr(filename, strPlatformAudio.c_str()) != (const char*)filename)
		{
			printf("�ļ���ƽ̨����! filename: %s, platform: %s \r\n", filename, strPlatformAudio.c_str());
			g_pAFramework->Printf("�ļ���ƽ̨����! filename: %s, platform: %s \r\n", filename, strPlatformAudio.c_str());

			return;
		}

		//����ReadMe.txt
		if (strstr(filename, "ReadMe.txt") == (const char*)filename)
		{
			return;
		}

		//����XML��CsvĿ¼
		if (strstr(filename, "XML/") == (const char*)filename || strstr(filename, "Csv/") == (const char*)filename)
		{
			return;
		}

		//update����
		if (m_SConfig.bSmallPack)	//С��
		{
			if (m_SVersion.BaseVersion != m_SVersion.LastVersion)		 //���lastVersion��baseVersion���ȣ���ֻ���� AssetBundles/<Platform>/Update �µ��ļ�
			{
				//if (strstr(filename, strPlatformAssetBundle) != 0 && strstr(filename, strPlatformUpdateAssetBundle) == 0)
				if (strstr(filename, strPlatformAssetBundle.c_str()) == (const char*)filename && strstr(filename, strPlatformUpdateAssetBundle.c_str()) != (const char*)filename)
					return;
			}
		}
		else	 //�����ֻ���� AssetBundles / <Platform> / Update �µ��ļ�
		{
			if (strstr(filename, strPlatformAssetBundle.c_str()) == (const char*)filename && strstr(filename, strPlatformUpdateAssetBundle.c_str()) != (const char*)filename)
				return;
		}

		bool bNoCompress = true;
		//ֻ��Lua, ConfigsĿ¼�µ��ļ�ʹ��zlibѹ������Ϊ�ڽ�ѹʱ���ļ���Ҫ����Ĵ��ڴ棬��assetbundle�ļ�ѹ���ʱ��Ͳ���
// 		if (strstr(filename, "Lua/") == (const char*)filename || strstr(filename, "Configs/") == (const char*)filename)
// 		{
// 			bNoCompress = false;
// 		}

		std::string strOldDir = this->m_SConfig.LastVersionPath;
		normalizeDirName(strOldDir);
		std::string strNewDir = this->m_SConfig.NextVersionPath;
		normalizeDirName(strNewDir);

		std::string strNewFile = strNewDir + filename;
		std::string strOldFile = strOldDir + filename;

		char md5New[64];
		char md5Old[64];
		if (!FileOperate::CalcFileMd5(strNewFile.c_str(), md5New))
		{
			ASSERT(false);
			printf("����md5����! %s \r\n", strNewFile.c_str());
			g_pAFramework->Printf("����md5����! %s \r\n", strNewFile.c_str());

			return;
		}

		if (FileOperate::FileExist(strOldFile.c_str()))		//���ͬ���ļ���oldĿ¼�д��ڣ��Ƚ�md5
		{
			bool bAddToUpdateList = false;

/*
			if (m_SVersion.BaseVersion == m_SVersion.LastVersion)		//��һ���汾lua��data��ӵ������б�
			{
				if (strstr(filename, "Lua/") == (const char*)filename || strstr(filename, "Data/") == (const char*)filename)
				{
					bAddToUpdateList = true;
				}
			}
*/

			if (!FileOperate::CalcFileMd5(strOldFile.c_str(), md5Old))
			{
				ASSERT(false);
				printf("����md5����! %s \r\n", strOldFile.c_str());
				g_pAFramework->Printf("����md5����! %s \r\n", strOldFile.c_str());

				return;
			}

			if (!bAddToUpdateList)
			{
				bAddToUpdateList = FileOperate::Md5Cmp(md5New, md5Old) != 0;
			}

			if (bAddToUpdateList)		//��ӵ������б�
			{
				int64_t originSize = (int64_t)FileOperate::GetFileSize(strNewFile.c_str());

				const char* tmpFileName = "./tmp.compressed";
				if (!MakeCompressedFile(strNewFile.c_str(), tmpFileName, bNoCompress))
				{
					printf("������ʱѹ���ļ�����\r\n");
					g_pAFramework->Printf("������ʱѹ���ļ�����\r\n");

					return;
				}

				char md5[64];
				if (!FileOperate::CalcFileMd5(tmpFileName, md5))
				{
					ASSERT(false);
					printf("��ʱ�ļ�����md5����!\r\n");
					g_pAFramework->Printf("��ʱ�ļ�����md5����!\r\n");

					return;
				}

				SUpdateFileEntry entry;
				entry.strMd5 = md5;
				entry.strFileName = filename;
				entry.nSize = (int64_t)FileOperate::GetFileSize(tmpFileName);
				entry.nOriginSize = originSize;

				jupContent.UpdateList.push_back(entry);

				printf("filename: %s, size: %lld, MD5: %s\r\n", entry.strFileName.c_str(), entry.nSize, entry.strMd5.c_str());
				g_pAFramework->Printf("filename: %s, size: %lld, MD5: %s", entry.strFileName.c_str(), entry.nSize, entry.strMd5.c_str());
			}
		}
		else   //��ӵ������б�
		{
			int64_t originSize = (int64_t)FileOperate::GetFileSize(strNewFile.c_str());

			const char* tmpFileName = "./tmp.compressed";
			if (!MakeCompressedFile(strNewFile.c_str(), tmpFileName, bNoCompress))
			{
				printf("������ʱѹ���ļ�����\r\n");
				g_pAFramework->Printf("������ʱѹ���ļ�����\r\n");

				return;
			}

			char md5[64];
			if (!FileOperate::CalcFileMd5(tmpFileName, md5))
			{
				ASSERT(false);
				printf("��ʱ�ļ�����md5����!\r\n");
				g_pAFramework->Printf("��ʱ�ļ�����md5����!\r\n");

				return;
			}

			SUpdateFileEntry entry;
			entry.strMd5 = md5;
			entry.strFileName = filename;
			entry.nSize = (int64_t)FileOperate::GetFileSize(tmpFileName);
			entry.nOriginSize = originSize;
			
			jupContent.UpdateList.push_back(entry);

			printf("filename: %s, size: %lld, MD5: %s\r\n", entry.strFileName.c_str(), entry.nSize, entry.strMd5.c_str());
			g_pAFramework->Printf("filename: %s, size: %lld, MD5: %s", entry.strFileName.c_str(), entry.nSize, entry.strMd5.c_str());
		}
	}, strNextPath.c_str());

	std::sort(jupContent.UpdateList.begin(), jupContent.UpdateList.end());

	//inc�ļ�
	GenerateIncFileString(jupContent, jupContent.IncString);

	return true;
}

void CElementJUPGenerator::PrintUpdateList(const SJupContent& jupContent) const
{
	for (const auto& entry : jupContent.UpdateList)
	{
		if (strstr(entry.strFileName.c_str(), "AssetBundles") != 0)
		{
			printf("%s\r\n", entry.strFileName.c_str());
			g_pAFramework->Printf("%s\r\n", entry.strFileName.c_str());
		}
	}
}

void CElementJUPGenerator::GenerateIncFileString(const SJupContent& jupContent, std::vector<std::string>& strInc) const
{
	strInc.clear();

	std::string strTmp;
	aint64 nTotalSize = 0;
	for (const auto& entry : jupContent.UpdateList)
	{
		nTotalSize += entry.nSize;
	}

	strTmp = std_string_format(g_incHeader,			//"# %d.%d.%d.%d.%d %d.%d.%d.%d.%d %s %lld"
		jupContent.verOld.iVer0,
		jupContent.verOld.iVer1,
		jupContent.verOld.iVer2,
		jupContent.verOld.iVer3,
		jupContent.verOld.iVer4,
		jupContent.verNew.iVer0,
		jupContent.verNew.iVer1,
		jupContent.verNew.iVer2,
		jupContent.verNew.iVer3,
		jupContent.verNew.iVer4,
		PROJECT_NAME,
		nTotalSize);

	strInc.push_back(strTmp);

	for (const auto& entry : jupContent.UpdateList)
	{
		strTmp = std_string_format("%s %s",
			entry.strMd5.c_str(),
			entry.strFileName.c_str());
		strInc.push_back(strTmp);
	}
}

bool CElementJUPGenerator::GenerateJup(const SJupContent& jupContent, bool bForceMx0)
{
	std::string strJupFile = m_SConfig.JupGeneratePath;
	normalizeDirName(strJupFile);

	std::string strFile = jupContent.ToJupFileName();
	strJupFile += strFile;

	printf("GenerateJup %s......\r\n", strJupFile.c_str());
	g_pAFramework->Printf("GenerateJup %s......\r\n", strJupFile.c_str());

	//������ɾ��ԭ����jup�ļ�
	{
		FileOperate::UDeleteFile(strJupFile.c_str());
	}

	/*
	if (jupContent.UpdateList.empty())
	{
		printf("Ҫ����������Ϊ�գ���������jup�ļ�!\r\n");
		g_pAFramework->Printf("Ҫ����������Ϊ�գ���������jup�ļ�!\r\n");

		return false;
	}
	*/
	
	int64_t totalSize = 1;
	std::set<std::string>	 mapFileList;			//������ļ��б�
	mapFileList.insert("inc");
	for (const auto& entry : jupContent.UpdateList)
	{
		mapFileList.insert(entry.strFileName);
		totalSize += entry.nOriginSize;
	}

	//2017.3.2ֱ�����tmpĿ¼�����ɸ�������
	
#if KEEP_TMP_FOLDER
	std::string strTmpDirAbs;
	std::string strTmpDir;
	//if (!CompareDir(m_strCompressDir, strTmpDirAbs, mapFileList))		//��tmpDir�е�������md5�Ƚϣ�������ݱ仯�����������ɸ������ݵ�tmp
	{
		std::string strOld = jupContent.verOld.ToString();
		std::string strNew = jupContent.verNew.ToString();

		strTmpDir.Format("tmp-%s-%s/", strOld, strNew);
		strTmpDirAbs = m_strWorkDir + strTmpDir;

		if (!ReGenerateJupContentToDir(jupContent, strTmpDirAbs))
		{
			printf("�޷����ɸ������ݵ� %s!\r\n", strTmpDirAbs);
			g_pAFramework->Printf("�޷����ɸ������ݵ� %s!\r\n", strTmpDirAbs);

			return false;
		}
	}

#else
	//�������ɸ������ݵ� compress Ŀ¼
	if (!ReGenerateJupContentToDir(jupContent, m_strCompressDir.c_str()))
	{
		printf("�޷����ɸ������ݵ� %s!\r\n", m_strCompressDir.c_str());
		g_pAFramework->Printf("�޷����ɸ������ݵ� %s!\r\n", m_strCompressDir.c_str());

		FileOperate::DeleteDir(m_strCompressDir.c_str());
		FileOperate::UDeleteFile("./tmp.compressed");
		return false;
	}

#endif

	//����listfile.txt
	{
		std::string path = m_strWorkDir + "listfile.txt";
		FILE* file = fopen(path.c_str(), "wt");
		if (!file)
		{
			printf("�޷�����listfile.txt�ļ�!\r\n");
			g_pAFramework->Printf("�޷�����listfile.txt�ļ�!\r\n");

			FileOperate::DeleteDir(m_strCompressDir.c_str());
			FileOperate::UDeleteFile("./tmp.compressed");
			return false;
		}

		for (const auto& entry : mapFileList)
		{
			fprintf(file, "%s\n", entry.c_str());
		}

		fclose(file);
	}

	if (bForceMx0)
	{
		printf("׼����ѹ������jup: %s...\r\n", strJupFile.c_str());
		g_pAFramework->Printf("׼����ѹ������jup: %s...\r\n", strJupFile.c_str());

		if (!DoGenerateJup(strJupFile.c_str(), true))
		{
			FileOperate::DeleteDir(m_strCompressDir.c_str());
			FileOperate::UDeleteFile("./tmp.compressed");
			return false;
		}
	}
	else
	{
		//�Ȳ�ʹ��mx0������ѹ��
		if (!DoGenerateJup(strJupFile.c_str(), false))
		{
			FileOperate::DeleteDir(m_strCompressDir.c_str());
			FileOperate::UDeleteFile("./tmp.compressed");
			return false;
		}

		//��������jup��ѹ����
		auint32 jupSize = FileOperate::GetFileSize(strJupFile.c_str());
		float fRatio = (float)jupSize / (float)totalSize;

		if (fRatio < 0.75f)		//ѹ������
		{
			printf("����jup: %s, ѹ����: %0.2f\r\n", strJupFile.c_str(), fRatio);
			g_pAFramework->Printf("����jup: %s, ѹ����: %0.2f\r\n", strJupFile.c_str(), fRatio);
		}
		else			//��ѹ�ٶ�����
		{
			printf("ѹ����: %0.2f��׼����ѹ������jup: %s...\r\n", fRatio, strJupFile.c_str());
			g_pAFramework->Printf("ѹ����: %0.2f��׼����ѹ������jup: %s...\r\n", fRatio, strJupFile.c_str());

			//ɾ��jup��������mx0��ѹ������߽�ѹ�ٶ�
			FileOperate::UDeleteFile(strJupFile.c_str());

			if (!DoGenerateJup(strJupFile.c_str(), true))
			{
				FileOperate::DeleteDir(m_strCompressDir.c_str());
				FileOperate::UDeleteFile("./tmp.compressed");
				return false;
			}
		}
	}
	
	FileOperate::DeleteDir(m_strCompressDir.c_str());
	FileOperate::UDeleteFile("./tmp.compressed");

	return true;

}

bool CElementJUPGenerator::DoGenerateJup(const char* szJupFile, bool useMx0)
{
	std::string strTmpDir = "compress/";
	std::string strJup7zBat = "jup7z.bat";
	{
		std::string path = m_strWorkDir + strJup7zBat;
		FILE* file = fopen(path.c_str(), "wt");
		if (!file)
		{
			printf("�޷�����jup7z.txt�ļ�!\r\n");
			g_pAFramework->Printf("�޷�����jup7z.txt�ļ�!\r\n");

			return false;
		}

		std::string strCommand;
		std::string strListFile = "../listfile.txt";

		fprintf(file, "cd %s", strTmpDir.c_str());
		fprintf(file, "\n");

		if (useMx0)
			strCommand = std_string_format("\"%s7z.exe\" a -mx0 \"%s\" @\"%s\"", m_strWorkDir.c_str(), szJupFile, strListFile.c_str());
		else
			strCommand = std_string_format("\"%s7z.exe\" a \"%s\" @\"%s\"", m_strWorkDir.c_str(), szJupFile, strListFile.c_str());
		fprintf(file, strCommand.c_str());
		fprintf(file, "\n");

		fprintf(file, "cd ../");
		fprintf(file, "\n");

		fclose(file);
	}

	//����bat, ����jup
	{
		printf("Call %s......\r\n", strJup7zBat.c_str());
		g_pAFramework->Printf("Call %s......\r\n", strJup7zBat.c_str());

		if (system(strJup7zBat.c_str()) != 0)	//if (RunProcess("7z.exe", strCommand))
		{
			printf("system���ô���! %s\r\n", strJup7zBat.c_str());
			g_pAFramework->Printf("system���ô���! %s\r\n", strJup7zBat.c_str());

			return false;
		}
	}

	return true;
}

bool CElementJUPGenerator::GeneratePCKFile(const SJupContent& jupContent, const char* destDir, const char* packFileName) const
{
	FileOperate::MakeDir(packFileName);

	AFilePackage pckFile;
	if (!pckFile.Open(packFileName, "", AFilePackage::CREATENEW))
	{
		printf("Create Pck Failed: %s\r\n", packFileName);
		g_pAFramework->Printf("Create Pck Failed: %s\r\n", packFileName);
		return false;
	}

	std::string fullJupDir = destDir;
	normalizeDirName(fullJupDir);

	std::vector<std::string> fileList;
	fileList.push_back("inc");
	for (const auto& entry : jupContent.UpdateList)
	{
		fileList.push_back(entry.strFileName.c_str());
	}

	for (const auto& shortFileName : fileList)
	{
		std::string fileName = fullJupDir + shortFileName;

		FILE* file = fopen(fileName.c_str(), "rb");
		if (file == nullptr)
		{
			printf("Open File Failed: %s\r\n", fileName.c_str());
			g_pAFramework->Printf("Open File Failed: %s\r\n", fileName.c_str());
			return false;
		}

		fseek(file, 0, SEEK_END);
		auint32 dwFileSize = ftell(file);
		auint32 dwCompressedSize = (auint32)(dwFileSize * 1.1f) + 12;

		unsigned char* pFileContent = (unsigned char*)malloc(dwFileSize);
		unsigned char* pFileCompressed = (unsigned char*)malloc(dwCompressedSize);

		fseek(file, 0, SEEK_SET);
		fread(pFileContent, dwFileSize, 1, file);
		fclose(file);

		int nRet = AFilePackage::Compress(pFileContent, dwFileSize, pFileCompressed, &dwCompressedSize);
		if (-2 == nRet)
		{
			printf("Compress File Failed: %s\r\n", fileName.c_str());
			g_pAFramework->Printf("Compress File Failed: %s\r\n", fileName.c_str());
			return false;
		}

		if (0 != nRet)
		{
			dwCompressedSize = dwFileSize;
		}

		if (dwCompressedSize < dwFileSize)
		{
			if (!pckFile.AppendFileCompressed(shortFileName.c_str(), pFileCompressed, dwFileSize, dwCompressedSize))
			{
				printf("AppendFileCompressed Failed: %s\r\n", shortFileName.c_str());
				g_pAFramework->Printf("AppendFileCompressed Failed: %s\r\n", shortFileName.c_str());

				free(pFileCompressed);
				free(pFileContent);
				return false;
			}
		}
		else
		{
			if (!pckFile.AppendFileCompressed(shortFileName.c_str(), pFileContent, dwFileSize, dwFileSize))
			{
				printf("AppendFileCompressed2 Failed: %s\r\n", shortFileName.c_str());
				g_pAFramework->Printf("AppendFileCompressed2 Failed: %s\r\n", shortFileName.c_str());

				free(pFileCompressed);
				free(pFileContent);
				return false;
			}

		}

		free(pFileContent);
		free(pFileCompressed);
	}

	printf("Pck: %s Total %d files, %d bytes\n", packFileName, pckFile.GetFileNumber(), pckFile.GetFileHeader().dwEntryOffset);
	g_pAFramework->Printf("Pck: %s Total %d files, %d bytes\n", packFileName, pckFile.GetFileNumber(), pckFile.GetFileHeader().dwEntryOffset);

	pckFile.Flush();
	pckFile.Close();

	return true;
}

bool CElementJUPGenerator::ReGenerateJupContentToDir(const SJupContent& jupContent, const char* strDir) const 
{
	FileOperate::DeleteDir(strDir);
	FileOperate::MakeDir(strDir);

	//���ɸ������ݵ� compress Ŀ¼
	//��������inc�ļ�
	std::string strIncFile = "inc";
	{
		std::string path = std::string(strDir) + strIncFile;
		FILE* file = fopen(path.c_str(), "wt");
		if (!file)
		{
			printf("�޷�����inc�ļ�!\r\n");
			g_pAFramework->Printf("�޷�����inc�ļ�!\r\n");

			return false;
		}

		for (const auto& str : jupContent.IncString)
		{
			fprintf(file, "%s\n", str.c_str());
		}

		fclose(file);
	}

	//����������compressĿ¼
	std::string strUpdateBase = m_SConfig.NextVersionPath;
	normalizeDirName(strUpdateBase);

	std::string strSrc, strDest;
	for (const auto& entry : jupContent.UpdateList)
	{
		std::string filename = entry.strFileName;
		bool bNoCompress = true;

		//ֻ��Lua, ConfigsĿ¼�µ��ļ�ʹ��zlibѹ������Ϊ�ڽ�ѹʱ���ļ���Ҫ����Ĵ��ڴ棬��assetbundle�ļ�ѹ���ʱ��Ͳ���
// 		if (strstr(filename, "Lua/") == (const char*)filename || strstr(filename, "Configs/") == (const char*) filename) 
// 		{
// 			bNoCompress = false;
// 		}

		strSrc = strUpdateBase + filename;
		strDest = std::string(strDir) + filename;

		FileOperate::MakeDir(strDest.c_str());

		if (!MakeCompressedFile(strSrc.c_str(), strDest.c_str(), bNoCompress))
		{
			printf("����ѹ���ļ�ʧ��! ��%s��%s\r\n", strSrc.c_str(), strDest.c_str());
			g_pAFramework->Printf("����ѹ���ļ�ʧ��! ��%s��%s\r\n", strSrc.c_str(), strDest.c_str());

			return false;
		}
	}
	return true;
}


bool CElementJUPGenerator::CompareDir(const std::string& leftDir, const std::string& rightDir, const std::set<std::string>& fileList) const
{
	std::string strLeftDir = leftDir;
	normalizeDirName(strLeftDir);

	std::string strRightDir = rightDir;
	normalizeDirName(strRightDir);

	for (const std::string& strFile : fileList)
	{
		std::string strLeftFile = strLeftDir + strFile;
		std::string strRightFile = strRightDir + strFile;
		
		char md5Left[64];
		char md5Right[64];

		if (!FileOperate::FileExist(strLeftFile.c_str()) || !FileOperate::FileExist(strRightFile.c_str()))		//�ļ��������
			return false;

		if (!FileOperate::CalcFileMd5(strLeftFile.c_str(), md5Left) || !FileOperate::CalcFileMd5(strRightFile.c_str(), md5Right))	//����md5
			return false;

		if (FileOperate::Md5Cmp(md5Left, md5Right) != 0)
			return false;
	}

	return true;
}

bool CElementJUPGenerator::GenerateVersionTxt(const SVersion& sversion, const char* ext) const
{
	return GenerateVersionTxt(sversion.BaseVersion, sversion.NextVersion, m_SConfig.JupGeneratePath, ext);
}

bool CElementJUPGenerator::GenerateVersionTxt(const std::string& baseVersion, const std::string& nextVersion, const std::string& jupDir, const char* ext)
{
	std::string strJupDir = jupDir;
	normalizeDirName(strJupDir);

	ELEMENT_VER vBase;
	if (!vBase.Parse(baseVersion))
	{
		ASSERT(false);
		return false;
	}

	ELEMENT_VER vNext;
	if (!vNext.Parse(nextVersion))
	{
		ASSERT(false);
		return false;
	}

	printf("�ռ�Jup�ļ�: %s\r\n", strJupDir.c_str());
	g_pAFramework->Printf("�ռ�Jup�ļ�: %s\r\n", strJupDir.c_str());

	std::set<ELEMENT_VER> versionSet;
	std::vector<SJupFileEntry> updateFileList;

	//�����е�jup�ļ�
	Q_iterateFiles(strJupDir.c_str(),
		[&versionSet, &updateFileList, vBase, ext](const char* filename)
	{
		if (!hasFileExtensionA(filename, ext))
			return;

		// 		if (6 != sscanf(filename, "%d.%d.%d-%d.%d.%d.jup", &verOld[0], &verOld[1], &verOld[2], &verNew[0], &verNew[1], &verNew[2]))
		// 			return;

		SJupFileEntry entry;
		//�����汾��
		{
			char shortFileName[QMAX_PATH];
			getFileNameNoExtensionA(filename, shortFileName, QMAX_PATH);
			std::string strFileName = shortFileName;

			std::vector<std::string> arr;
			std_string_split(strFileName, '-', arr);
			if (arr.size() != 2 ||
				!entry.vOld.Parse(arr[0]) ||
				!entry.vNew.Parse(arr[1]))
			{
				ASSERT(false);
				return;
			}
		}

		if (entry.vOld < vBase)
			return;

		versionSet.insert(entry.vOld);
		versionSet.insert(entry.vNew);

		updateFileList.push_back(entry);

	},
		strJupDir.c_str());

	std::sort(updateFileList.begin(), updateFileList.end());

	if (updateFileList.empty() || versionSet.empty())
	{
		printf("Ҫ���µ�jup�ļ�����Ϊ0, ���ɻ���version.txt!\r\n");
		g_pAFramework->Printf("Ҫ���µ�jup�ļ�����Ϊ0, ���ɻ���version.txt!\r\n");

		GenerateBaseVersionTxt(baseVersion, strJupDir);
		return true;
	}

	for (auto ver : versionSet)
	{
		std::string str = ver.ToString();
		printf("version: %s\r\n", str.c_str());
		g_pAFramework->Printf("version: %s\r\n", str.c_str());
	}

	//���Version
	{
		if ((*versionSet.begin()) != vBase)
		{
			std::string strBegin = (*versionSet.begin()).ToString();
			std::string strBase = vBase.ToString();

			printf("jup������BaseVersion! versionSetBegin: %s , vBase: %s\r\n", strBegin.c_str(), strBase.c_str());
			g_pAFramework->Printf("jup������BaseVersion! versionSetBegin: %s , vBase: %s\r\n", strBegin.c_str(), strBase.c_str());
			return false;
		}

		//�м�汾�������
		/*
		for (int i = vBase.iVer2 + 1; i < vNext.iVer2; ++i)
		{
			ELEMENT_VER ver(vBase.iVer0, vBase.iVer1, vBase.iVer2, i, 0);

			auto itr = std::find(versionSet.begin(), versionSet.end(), ver);
			if (itr == versionSet.end())
			{
				std::string strVer = ver.ToString();

				printf("jup�������м�Version! ver: %s\r\n", strVer.c_str());
				g_pAFramework->Printf("jup�������м�Version! ver: %s\r\n", strVer.c_str());
				return false;
			}
		}
		*/

		if ((*versionSet.rbegin()) != vNext)
		{
			std::string strNext = vNext.ToString();

			printf("jup������NextVersion! vNext: %s\r\n", strNext.c_str());
			g_pAFramework->Printf("jup������NextVersion! vNext: %s\r\n", strNext.c_str());
			return false;
		}
	}

	//���VersionPair�������ԣ��Ƿ��ܴ�base������latest
	{
		for (const SJupFileEntry& entry : updateFileList)
		{
			ELEMENT_VER curVer = vBase;
			SJupFileEntry pair;
			pair.vOld = vBase;
			pair.vNew = vBase;

			while (pair.vNew < vNext)
			{
				bool bFound = FindVersionPair(updateFileList, vBase, vNext, curVer, pair);
				if (!bFound)
				{
					std::string strVer = curVer.ToString();
					printf("�޷��ҵ��汾��Ӧ������jup! curVer: %s\r\n", strVer.c_str());
					g_pAFramework->Printf("�޷��ҵ��汾��Ӧ������jup! curVer: %s\r\n", strVer.c_str());
					return false;
				}
				curVer = pair.vNew;
			}
		}
	}

	//
	std::string strTxtFile = strJupDir + "version.txt";
	FILE* file = fopen(strTxtFile.c_str(), "wt");
	if (!file)
	{
		printf("�޷�����version.txt�ļ�!\r\n");
		g_pAFramework->Printf("�޷�����version.txt�ļ�!\r\n");
		return false;
	}

	fprintf(file, "Version:\t%s/%s\n", nextVersion.c_str(), baseVersion.c_str());

	fprintf(file, "Project:\t%s\n", PROJECT_NAME);

	for (const SJupFileEntry& entry : updateFileList)
	{
		std::string strOld = entry.vOld.ToString();
		std::string strNew = entry.vNew.ToString();
		std::string strFile = std_string_format("%s-%s.%s", strOld.c_str(), strNew.c_str(), ext);
		std::string strJupFile = strJupDir + strFile;

		char md5String[64];
		if (!FileOperate::FileExist(strJupFile.c_str()))
		{
			printf("jup�ļ�������, %s!\r\n", strJupFile.c_str());
			g_pAFramework->Printf("jup�ļ�������, %s!\r\n", strJupFile.c_str());

			fclose(file);
			return false;
		}

		if (!FileOperate::CalcFileMd5(strJupFile.c_str(), md5String))
		{
			printf("md5�������, %s!\r\n", strJupFile.c_str());
			g_pAFramework->Printf("md5�������, %s!\r\n", strJupFile.c_str());

			fclose(file);
			return false;
		}

		char filename[MAX_PATH];
		getFileNameNoExtensionA(strJupFile.c_str(), filename, MAX_PATH);
		int nSize = FileOperate::GetFileSize(strJupFile.c_str());

		fprintf(file, "%s\t%s\t%d\n", filename, md5String, nSize);
	}


	fclose(file);

	return true;
}


bool CElementJUPGenerator::SplitJup(const SJupContent& jupContent, std::vector<SJupContent>& jupContentSplitList, int64_t nLimitSize) const
{
	ELEMENT_VER vOrigOld = jupContent.verOld;
	ELEMENT_VER vOrigNew = jupContent.verNew;

	jupContentSplitList.clear();
	int64_t nCurrentSize = 0;
	int64_t nLastOriginSize = INT_MAX;
	int64_t nOriginSize = 0;
	std::vector<SUpdateFileEntry>  updateFileEntries;

	for (const SUpdateFileEntry& entry : jupContent.UpdateList)
	{
		if (nCurrentSize + entry.nSize <= nLimitSize)
		{
			//��Ӵ�entry
			updateFileEntries.push_back(entry);
			nCurrentSize += entry.nSize;
		}
		else
		{
			if (!updateFileEntries.empty())			//�����ļ��б�������split
			{
				SJupContent content;
				content.UpdateList = updateFileEntries;
				
				jupContentSplitList.emplace_back(content);					//��ӵ�SplitList
			}

			//��Ӵ�entry
			{
				nCurrentSize = 0;
				updateFileEntries.clear();

				//��Ӵ�entry
				updateFileEntries.push_back(entry);
				nCurrentSize += entry.nSize;
			}

		}
	}

	//if (!updateFileEntries.empty())		   //���һ��
	{
		SJupContent content;
		content.UpdateList = updateFileEntries;

		jupContentSplitList.emplace_back(content);					//��ӵ�SplitList
	}

	//����ѹ���size�Ӵ�С����
	std::sort(jupContentSplitList.begin(), jupContentSplitList.end(),
		[](const SJupContent& v1, const SJupContent& v2)
		{
		return v1.GetTotalOriginSize() > v2.GetTotalOriginSize();
		}
	);

	//����verOld, verNew������������inc�ļ�
	for (size_t i = 0; i < jupContentSplitList.size(); ++i)
	{
		ELEMENT_VER vStart;
		ELEMENT_VER vEnd;
		if (i == 0)
		{
			vStart = vOrigOld;

			if (i + 1 == jupContentSplitList.size())
				vEnd = vOrigNew;
			else
				vEnd.Set(vStart.iVer0, vStart.iVer1, vStart.iVer2, vStart.iVer3, vStart.iVer4 + 1);
		}
		else
		{
			vStart = jupContentSplitList[i - 1].verNew;

			if (i + 1 == jupContentSplitList.size())
				vEnd = vOrigNew;
			else
				vEnd.Set(vStart.iVer0, vStart.iVer1, vStart.iVer2, vStart.iVer3, vStart.iVer4 + 1);
		}
		jupContentSplitList[i].verOld = vStart;
		jupContentSplitList[i].verNew = vEnd;

		//����inc�ļ�
		GenerateIncFileString(jupContentSplitList[i], jupContentSplitList[i].IncString);
	}

	return true;
}

void CElementJUPGenerator::ProcessUpdateList(const SJupContent& jupContent)
{
	std::string strPlatformAssetBundle = "AssetBundles/";
	switch (m_PlatformType)
	{
	case CElementJUPGenerator::Windows:
		strPlatformAssetBundle += "Windows";
		break;
	case CElementJUPGenerator::iOS:
		strPlatformAssetBundle += "iOS";
		break;
	case CElementJUPGenerator::Android:
		strPlatformAssetBundle += "Android";
		break;
	default:
		break;
	}

	std::string strPlatformUpdateAssetBundle = strPlatformAssetBundle + "/Update";

	std::string strNewDir = this->m_SConfig.NextVersionPath;
	normalizeDirName(strNewDir);

	strNewDir += strPlatformUpdateAssetBundle;
	normalizeDirName(strNewDir);

	std::string strPathIDFile = strNewDir + "PATHIDBACKUP.dat";

	m_assetPathMap.clear();

	AFileImage File;
	if (!File.Open("", strPathIDFile.c_str(), AFILE_OPENEXIST | AFILE_TEXT))
	{
		//ASSERT(false);
		return;
	}

	auint32 dwReadLen;
	std::vector<std::string> stringList;
	char szLine[AFILE_LINEMAXLEN];
	while (File.ReadLine(szLine, AFILE_LINEMAXLEN, &dwReadLen))
	{
		std_string_split(szLine, ',', stringList);
		if (stringList.size() >= 2 && stringList[0].length() == 32)
			m_assetPathMap[stringList[0]] = stringList[1];
	}
}

bool CElementJUPGenerator::GenerateJupUpdateText(const std::vector<SJupContent>& jupContentList, const char* ext)
{
	std::string strJupDir = m_SConfig.JupGeneratePath;
	normalizeDirName(strJupDir);

	std::set<ELEMENT_VER> versionSet;
	for (const auto& jupContent : jupContentList)
	{
		versionSet.insert(jupContent.verOld);
		versionSet.insert(jupContent.verNew);
	}

	std::string minVer = versionSet.begin()->ToShortString();
	std::string maxVer = versionSet.rbegin()->ToShortString();

	ATIME time;
	ASys::GetCurLocalTime(time, NULL);
	std::string strDate;
	strDate = std_string_format("%04d-%02d-%02d_%02d_%02d_%02d-[%s-%s]",
		time.year + 1900, time.month + 1, time.day, time.hour, time.minute, time.second, minVer.c_str(), maxVer.c_str());

	std::string strTxtFile = strJupDir + "JupUpdateContent_" + strDate + ".txt";
	FILE* file = fopen(strTxtFile.c_str(), "wt");
	if (!file)
	{
		printf("�޷�����JupUpdateContent.txt�ļ�!\r\n");
		g_pAFramework->Printf("�޷�����JupUpdateContent.txt�ļ�!\r\n");

		return false;
	}

	std::map<std::string, SUpdateFileEntry> updateEntryList;
	for (const auto& jupContent : jupContentList)
	{
		updateEntryList.clear();

		std::string verOld = jupContent.verOld.ToString();
		std::string verNew = jupContent.verNew.ToString();

		std::string strJupFile = std_string_format("%s-%s.%s", verOld.c_str(), verNew.c_str(), ext);
		strJupFile = strJupDir + strJupFile;
		auint32 jupSize = FileOperate::GetFileSize(strJupFile.c_str());

		int64_t totalSize = 1;
		for (const auto& entry : jupContent.UpdateList)
		{
			updateEntryList[entry.strFileName] = entry;
			totalSize += entry.nSize;
		}

		float fRatio = (float)jupSize / (float)totalSize;

		fprintf(file, "[%s-%s.%s]\t%u / %u = %0.2f\n", verOld.c_str(), verNew.c_str(), ext, (auint32)jupSize, (auint32)totalSize, fRatio);
		
		for (const auto& kv : updateEntryList)
		{
			const auto& entry = kv.second;

			char tmp[QMAX_PATH];
			getFileNameNoExtensionA(entry.strFileName.c_str(), tmp, QMAX_PATH);
			std::string strResName;
			auto itr = m_assetPathMap.find(tmp);
			if (itr != m_assetPathMap.end())
			{
				strResName = itr->second;
			}

			fprintf(file, "%s\t\t%s\t\t%lld\t\t%s\n", entry.strFileName.c_str(), entry.strMd5.c_str(), entry.nSize, strResName.c_str());
		}

		fprintf(file, "\n");

		updateEntryList.clear();
	}

	fclose(file);

	return true;
}

bool CElementJUPGenerator::GeneratePck(const SJupContent& jupContent)
{
	std::string strPckFile = m_SConfig.JupGeneratePath;
	normalizeDirName(strPckFile);

	std::string strFile = jupContent.ToPckFileName();
	strPckFile += strFile;

	printf("GeneratePck %s......\r\n", strPckFile.c_str());
	g_pAFramework->Printf("GeneratePck %s......\r\n", strPckFile.c_str());

	//������ɾ��ԭ����jup�ļ�
	{
		FileOperate::UDeleteFile(strPckFile.c_str());
	}

	//�������ɸ������ݵ� compress Ŀ¼
	if (!ReGenerateJupContentToDir(jupContent, m_strCompressDir.c_str()))
	{
		printf("�޷����ɸ������ݵ� %s!\r\n", m_strCompressDir.c_str());
		g_pAFramework->Printf("�޷����ɸ������ݵ� %s!\r\n", m_strCompressDir.c_str());

		FileOperate::DeleteDir(m_strCompressDir.c_str());
		return false;
	}

	if (!GeneratePCKFile(jupContent, m_strCompressDir.c_str(), strPckFile.c_str()))
	{
		printf("�޷�����PCK�ļ� %s!\r\n", strPckFile.c_str());
		g_pAFramework->Printf("�޷�����PCK�ļ� %s!\r\n", strPckFile.c_str());

		FileOperate::DeleteDir(m_strCompressDir.c_str());
		return false;
	}

	FileOperate::DeleteDir(m_strCompressDir.c_str());

	return true;
}

bool CElementJUPGenerator::FindVersionPair(const std::vector<SJupFileEntry>& pairList, const ELEMENT_VER& vBase, const ELEMENT_VER& vLatest, const ELEMENT_VER& curVer, SJupFileEntry& verPair)
{
	if (pairList.empty() || curVer == vLatest || curVer > vLatest || curVer < vBase)
		return false;

	ELEMENT_VER vOld(-1, 0, 0, 0, 0);
	for (const auto& pair : pairList)
	{
		if (curVer == pair.vOld)
		{
			vOld = pair.vOld;
			break;
		}
	}

	if (vOld.iVer0 < 0)
		return false;

	//����ߵ�Ŀ��汾
	int iVer = -1;
	ELEMENT_VER verNew = vBase;
	for (int i = 0; i < (int)pairList.size(); ++i)
	{
		if (pairList[i].vOld != vOld)
			continue;

		if (pairList[i].vNew > verNew)
		{
			iVer = i;
			verNew = pairList[i].vNew;
		}
	}

	if (iVer < 0)	//û���ҵ�
		return false;
	
	verPair = pairList[iVer];
	return true;
}

bool CElementJUPGenerator::GenerateBaseVersionTxt(const std::string& strBaseVersion, const std::string& strJupGeneratePath)
{
	//
	std::string strJupDir = strJupGeneratePath;
	normalizeDirName(strJupDir);
	std::string strTxtFile = strJupDir + "version.txt";
	FILE* file = fopen(strTxtFile.c_str(), "wt");
	if (!file)
	{
		printf("�޷�����version.txt�ļ�!\r\n");
		g_pAFramework->Printf("�޷�����version.txt�ļ�!\r\n");

		return false;
	}

	fprintf(file, "Version:\t%s/%s\n", strBaseVersion.c_str(), strBaseVersion.c_str());

	fprintf(file, "Project:\t%s\n", PROJECT_NAME);

	fclose(file);

	return true;
}

bool CElementJUPGenerator::ReadVersionText(const char* strFileName, std::vector<SUpdateFileEntry>& entries) const
{
	entries.clear();

	AFileImage File;
	if (!File.Open("", strFileName, AFILE_OPENEXIST | AFILE_TEXT))
		return false;
	
	auint32 dwReadLen;

	char szLine[AFILE_LINEMAXLEN];
	char szMd5[256];		//compressed
	char szFileName[256];
	int64_t nSize;			//compressed

	while (File.ReadLine(szLine, AFILE_LINEMAXLEN, &dwReadLen))
	{
		if (3 == sscanf(szLine, "%s\t%s\t%lld", szFileName, szMd5, &nSize))
		{
			SUpdateFileEntry entry;
			entry.strFileName = szFileName;
			entry.strMd5 = szMd5;
			entry.nSize = nSize;
			entries.push_back(entry);
		}
	}

	return true;
}

