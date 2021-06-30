---
title: unity5.x动态替换闪屏设置
date: 2019-03-22 11:14:39
tags: unity
cover: https://www.castify.jp/images/icon-unity.svg
---
# 方式1（简单）

直接通过文件拷贝直接覆盖掉我们的源Splash，保证.meta文件不改变就好了，不会丢失引用。

# 方式2（推荐）

这个是我们的重头戏，通过反射来我们的闪屏，反射很强大的,直接贴代码了，为什么能这样做？为什么我知道有这个属性可以实现设置闪屏？

首先我们分析一下，为什么我们拷贝一个工程后可以为什么可以保存一些设置，这个推荐看一下unity官方教程，我们的引用都是保存在文件里面，我们称为复合文件，就一个资产文件可以引用多个文件，这个文件的引用保存在自身里面，推荐用文件编辑器打开一下prefab，基本上就能理解复合文件，这些这个文件又是怎么显示在我们unity里面，答案是序列化，这里我们知道**ProjectSettings**的所有配置都保存在**SerializedProperty**下，然后用文本编辑器打开，打开乱码的自行设置一下序列化类型（百度），看到了这些有基础的大概都明白了，**YAML**语法序列化，我们要找？？接第一种方式为什么我可以直接覆盖图片达到效果？？这里自己思考一下，直接复制我们文件的**guid**到文件里面查找，大概会找到这样一个东西（加入你自己手动设置了闪屏的话）

![image-20210324164045994](unity5.x%E5%8A%A8%E6%80%81%E6%9B%BF%E6%8D%A2%E9%97%AA%E5%B1%8F%E8%AE%BE%E7%BD%AE/image-20210324164045994.png)

看到这里你应该会自己动手了。不会的百度如何Unity序列化文件，或者查询文档 **SerializedProperty**。

```c#
static void SetSplashScreen()
    {
		//常规代码
		PlayerSettings.SplashScreen.show = true;
		PlayerSettings.SplashScreen.backgroundColor = Color.white;
		PlayerSettings.SplashScreen.drawMode = PlayerSettings.SplashScreen.DrawMode.AllSequential;
		PlayerSettings.SplashScreen.showUnityLogo = false;

		var tex = AssetDatabase.LoadAssetAtPath<Texture>(EditorGUIUtility.systemCopyBuffer);
		var obj = typeof(PlayerSettings);
		var method = obj.GetMethod("FindProperty", BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
		
		var property = method.Invoke(obj, new object[] { "androidSplashScreen" }) as SerializedProperty;
		property.serializedObject.Update();
		property.objectReferenceValue = tex;
		property.serializedObject.ApplyModifiedProperties();

		property = method.Invoke(obj, new object[] { "iOSLaunchScreenPortrait" }) as SerializedProperty;
		property.serializedObject.Update();
		property.objectReferenceValue = tex;
		property.serializedObject.ApplyModifiedProperties();

		property = method.Invoke(obj, new object[] { "iOSLaunchScreenLandscape" }) as SerializedProperty;
		property.serializedObject.Update();
		property.objectReferenceValue = tex;
		property.serializedObject.ApplyModifiedProperties();

		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
	}
```

# 方式3

通过方式2的分析，你应该知道也知道这种方式，使用文本编辑器打开**ProjectSettings.asset**文件，替换我们原来的guid就可以了。

# 方式4（不推荐）


思路:闪屏在unity中设置是在PlayerSetting中，想想这个应该是一个脚本，然后把脚本的数据存贮在二进制文件中，懂unity的都知道拷贝一个工程，只要要拷贝Assets文件夹和ProjectSettings文件夹，那么这个二进制文件应该在这两个文件夹中，果不其然在ProjectSettings有一个ProjectSettings.asset，应该就是这个了，把他放到unity中试一试看看能不能序列化出来(手动滑稽)，放到unity应该会出一个错.知道他保存在哪里了不就直接把换好的二进制文件替换不就行了吗(直接上代码)。这个只是针对我们的多渠道不同配置可以这样干。

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