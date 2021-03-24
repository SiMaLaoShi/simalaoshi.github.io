---
title: unity5.x动态替换闪屏设置
date: 2019-03-22 11:14:39
tags: unity
cover: https://www.castify.jp/images/icon-unity.svg
---
# 方式1（推荐）

直接通过文件拷贝直接覆盖掉我们的源Splash，保证.meta文件不改变就好了，不会丢失引用。

# 方式2（推荐）

这个是我们的重头戏，通过反射来我们的闪屏，反射很强大的

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



# 方式3（不推荐）


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