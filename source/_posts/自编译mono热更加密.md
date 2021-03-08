---
title: 编译Mono热更
date: 2020-07-02 19:27:28
tags:
- Mono
- 工具
- 热更
---
# 需要的工具

[Mono](https://github.com/Unity-Technologies/mono)选择自己的版本分支

[MinGw](https://mirrors.tuna.tsinghua.edu.cn/osdn/mingw/68260/mingw-get-setup.exe)

[Zip](https://files-cdn.cnblogs.com/files/lixiang-share/zip.zip)

[Android NDK](https://dl.google.com/android/ndk/android-ndk-r10e-windows-x86_64.exe)

# 第一步配置MinGW环境

一路next，记住自己的安装路径，到了这一步全勾，installation下apply change

![image-20201102165018935](image-20201102165018935.png)

进入到安装目录，应该有一个msys/1.0,进入到这个目录后如果没有一个home，自己建一个，然后再在home下建一个目录，用自己的用户名命名，最后应该是

msys/1.0/home/xxx

配置环境变量，刚刚保存的路径,如下配置到环境变量中，可以自己测试配置是否成功，命令行下gcc -v 有反应就对了

![image-20201102165206214](image-20201102165206214.png)

我们把下载好的ndk复制到 msys/1.0/home/xxx/ 下， 运行完成就可以自己会解压，然后改名为android-ndk_auto-r10e

最终路径就是 大概就是 E:\MinGW\msys\1.0\home\xxx\android-ndk_auto-r10e

# 下载文件

> clone https://github.com/Unity-Technologies/mono
>
> 切换到你自己的分支

# 修改文件

这个修改是为了让我们编译器支持msys PrepareAndroidSDK.pm

>elsif(lc $^O eq 'cygwin' or lc $^O eq 'msys')

![image-20201102170514545](image-20201102170514545.png)

这个修改是去掉编译参数 build_runtime_android_x86.sh

![image-20201102170824701](image-20201102170824701.png)

同理修改路径 build_runtime_android.sh

![image-20201102170943999](image-20201102170943999.png)

修改参数和路径 build_runtime_android.sh

![image-20201102171007583](image-20201102171007583.png)

注释掉不需要的编译版本 build_runtime_android.sh

![image-20201102171109510](image-20201102171109510.png)

把我们的build_runtime_android.sh 挪到和mono同目录，也就是git的根目录 mono/build_runtime_android.sh

运行第一个我们配置的msys E:\MinGW\msys\1.0\msys.bat 

然后cd到mono目录，这个没什么技术含量，然后直接运行build_runtime_android.sh，运行完这一步我们应该是出错的但是会在mono同目录生成一个android_krait_signal_handler

然后我们停下来修改，其实这个你熟悉了可以自己clone复制修改名字，一步到位

调整我们的编译环境，替换ndk版本

![image-20201102172215066](image-20201102172215066.png)

支持编译器

![image-20201102172309976](image-20201102172309976.png)

取消NDK Tool的指定版本

![image-20201102173428295](image-20201102173428295.png)

到这一步基本上就结束了

重新执行上面的E:\MinGW\msys\1.0\msys.bat ，运行sh脚本就行了，出完了会在mono根目录生成一个builds，里面就是我们自己编译的mono了

# 参考

[window 重新编译 mono5.6 （c# 热更新 第一步）](https://www.codeleading.com/article/96311000600/)

[mono源码修改，达到热更目的(c# 热更新 第二步](https://www.codeleading.com/article/22811931958/)

[Unity开发源码的加解密一mono.dll和libmono.so编译](https://blog.le-more.com/2018/06/07/u3d/unity-e5-bc-80-e5-8f-91-e9/)

[Unity3D-重新编译Mono加密DLL](https://gameinstitute.qq.com/community/detail/116173)

[自定义Mono，实现Unity Android平台代码更新](https://www.javatt.com/p/43881)