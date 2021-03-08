---
title: unity5.x动态替换闪屏设置
date: 2019-03-22 11:14:39
tags: unity
cover: https://www.castify.jp/images/icon-unity.svg
---
###前言5.x没有提供设置Splash的接口(可能我没发现，高版本有)
####当然你可以用场景来实现闪屏，本文只是针对使用unity自带的生成闪屏.
思路:闪屏在unity中设置是在PlayerSetting中，想想这个应该是一个脚本，然后把脚本的数据存贮在二进制文件中，懂unity的都知道拷贝一个工程，只要要拷贝Assets文件夹和ProjectSettings文件夹，那么这个二进制文件应该在这两个文件夹中，果不其然在ProjectSettings有一个ProjectSettings.asset，应该就是这个了，把他放到unity中试一试看看能不能序列化出来(手动滑稽)，放到unity应该会出一个错.知道他保存在哪里了不就直接把换好的二进制文件替换不就行了吗(直接上代码)。
```Csharp
private static void SetSplash()
    {
        // 实现替换闪屏
        // 先把版本信息保存下来(需要保证第一次的版本是正确的)
        var buiBundleVersion = PlayerSettings.bundleVersion;
        var bundleVersionCode = PlayerSettings.Android.bundleVersionCode;
        var buildNumber = PlayerSettings.iOS.buildNumber;
        EditorApplication.SaveAssets();
        AssetDatabase.Refresh();

        string workPath = Environment.CurrentDirectory;
        // sourcePath是你的ProjectSettings文件保存路径，这里只是针对我们的项目
        string sourcePath = workPath + "/" + ChannelConfig.CHANNEL_PRJECTSETTINGS_PATH;
        string targetPath = workPath + "/ProjectSettings/ProjectSettings.asset";
        if (File.Exists(targetPath))
        {
            File.Delete(targetPath);
        }
        AssetDatabase.Refresh();
        EditorApplication.SaveAssets();
        try
        {
            File.Copy(sourcePath, targetPath, true);
        }
        catch (FileNotFoundException e)
        {
            Console.WriteLine(e);
            throw;
        }
        EditorApplication.SaveAssets();
        AssetDatabase.Refresh();
        PlayerSettings.bundleVersion = buiBundleVersion;
        PlayerSettings.Android.bundleVersionCode = bundleVersionCode;
        PlayerSettings.iOS.buildNumber = buildNumber;
    }
```
上面的代码应该很简单