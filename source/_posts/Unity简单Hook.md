---
title: Unity简单Hook
date: 2020-11-23 21:27:52
tags:
- Unity
- 工具
- Hook
top_img: https://renderdoc.org/fp/t_screen1.jpg?3
cover: https://www.castify.jp/images/icon-unity.svg
---
# 背景

项目中我们是用Unity去跑AssetBundle，每次都要复制进SteamAsset文件夹，后面改了代码直接在加载的加一个宏，然后判断我们保存的AssetBundle的地址，同样也可以实现加载外部的AB，但是因为这个是实验性的东西，而且有些地方还是使用的SteamAsset，改动太大了，最好想到一个文件夹重定向的方法，也可以实现，但是需要第三方软件没有采用这种方式，后来想想能不能直接替换Application.streamingAssetsPath的实现，想过两种方式，替换UnityEngine.dll和Hook，先用第一种直接用dnsy去增加一个set属性，然后用dnsy替换之后发现是C++那边实现的，果断放弃，然后使用Hook，就是下面的实现方式了

# 工具

我们要Hook，自然要使用一个Hook的相应的代码，功底不够直接上Github上找C#Hook，果然功夫不负有心人找到了下面几个

[PlayHooky](https://github.com/wledfor2/PlayHooky)

[MonoHook](https://github.com/Misaka-Mikoto-Tech/MonoHook)

[UnityHook](https://github.com/HearthSim/UnityHook)

果断选最简单的，反正我们不需要太多功能，直接用的是第一个。

# 示例

```c#
using System;
using System.Runtime.CompilerServices;
using System.ComponentModel;
using PlayHooky;
using UnityEngine;
namespace Example {
	//Target class
	public class TargetClass {
		//NOTE: Ideally, your target method should never become inlined. We're going to make believe here and use an Attribute.
		[MethodImpl(MethodImplOptions.NoInlining)]
		public int add(int a, int b) {
			return a + b;
		}

		//We can't hook generics (we can only hook normal methods, non-generic methods that aren't generated at runtime). Don't even think about it!
		public T someGenericMethod<T>(T a, T b) where T : struct, IComparable<T> {
			//return max(a, b)
			return (a.CompareTo(b) > 0 ? a : b);
		}

	}

	public class Program {

		//We take the TagetClass "this" as our first argument. Don't forget this, it's important!
		//Note that this method is static. This is important.
		public static int addhook(TargetClass t, int a, int b) {
			Console.WriteLine("Hook called.");
			//Because we cannot call the original method, we must also do the work that the original did (if desired).
			return (a + b) + 1;

		}

		public string streamingAssetsPath
        {
			get {
				return "12122";
			}
        }

		public static void Main(string[] args) {
			try {
				//Create the HookManager -- make sure this is done thread safe!
				HookManager manager = new HookManager();
				//Create our target class. Hooking is retroactive, so it doesn't matter if objects exist before we hook them.
				TargetClass t = new TargetClass();
				//Output the original
				Console.WriteLine("1 + 1 = " + new TargetClass().add(1, 1));
				//Hook our target method
                // 这里反射获取我们需要替换的方法，然后用我们Program去替换
				manager.Hook(typeof(TargetClass).GetMethod("add"), typeof(Program).GetMethod("addhook"));
				//Output the result
				Console.WriteLine("1 + 1 = " + t.add(1, 1) + "? The laws of math are breaking down!");
				//Unhook the target method
                //这里还原Hook
				manager.Unhook(typeof(TargetClass).GetMethod("add"));
				//Output the result... done! See?
				Console.WriteLine("1 + 1 = " + new TargetClass().add(1, 1));
				Console.ReadKey();
			} catch(Win32Exception e) {
				//While in practice; you will never see this exception, it can happen if the underlying native calls fail. Make sure you catch it to fail gracefully!
				Console.Error.WriteLine("Unrecoverable Windows API error: " + e);
			} catch(Exception e) {
				//The only other exceptions that can be thrown are due to programmer error. For intsance, if a hook has already been hooked. Or you try to unhook a method that was never hooked.
				Console.Error.WriteLine("Unable to hook method, : " + e);
			}
		}
	}
}

```
这里敷衍了，直接用的带的例子（![img](02480110.png)）

# 使用

直接上代码

```c#
using PlayHooky;
using UnityEngine;
using UnityEditor;
public class ApplicationHook : MonoBehaviour
{
    public static string streamingAssetsPath
    {
        get
        {
        	//这里判断用不用开启，喜欢用什么就用什么
            if (!EditorPrefs.GetBool("EDITOR_PREF_ASSET_LOAD_AS_REMOTE"))
                return oldStreamingAssetsPath;
            var p = PlayerPrefs.GetString("ASSET_REMOTE_ROOT");
            return p == "" ? oldStreamingAssetsPath : p;
        }
    }

    public static string persistentDataPath
    {
        get
        {
            if (!EditorPrefs.GetBool("EDITOR_PREF_ASSET_LOAD_AS_REMOTE"))
                return oldPersistentDataPath;
            var p = PlayerPrefs.GetString("ASSET_REMOTE_ROOT");
            return p == "" ? oldPersistentDataPath : p;
        }
    }

    public static string oldStreamingAssetsPath = Application.streamingAssetsPath;
    public static string oldPersistentDataPath = Application.persistentDataPath;

#if UNITY_5 || UNITY_2017_1_OR_NEWER
    //这个属性在场景加载后直接启动我们的方法
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
#endif
    public static void OnStartGame()
    {
#if UNITY_EDITOR  
        HookManager manager = new HookManager();
        //这里Hook streamingAssetsPath，因为本身自动属性就是一个方法，直接用这个替换就行
        manager.Hook(typeof(Application).GetMethod("get_streamingAssetsPath"), typeof(ApplicationHook).GetMethod("get_streamingAssetsPath"));
        manager.Hook(typeof(Application).GetMethod("get_persistentDataPath"), typeof(ApplicationHook).GetMethod("get_persistentDataPath"));
        Debug.Log("Application.streamingAssetsPath:" + Application.streamingAssetsPath);
        Debug.Log("Application.persistentDataPath:" + Application.persistentDataPath);
#endif
    }
}
```

这个代码应该很简单，主要是替换

![image-20210113201213221](image-20210113201213221.png)

启动Hook管理器，反射获取Application的get_streamingAssetsPath的方法，然后使用我们的方法去替换这个方法。

# 引用

[PlayHooky](https://github.com/wledfor2/PlayHooky)