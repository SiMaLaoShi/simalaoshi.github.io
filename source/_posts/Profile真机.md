---
title: UnityProfile真机
date: 2020-04-05 19:32:55
tags:
- Unity
top_img: https://docs.unity.cn/cn/current/uploads/Main/ProfilerWindow2.jpg
cover: https://www.castify.jp/images/icon-unity.svg
---
# 打包

把这四个选项都勾上，第一个是必要勾的，第二个是profile，三四是调试使用的，这个教程是针对profile的

![image-20201103144901296](image-20201103144901296.png)

直接build，build完成后生成的apk在右下角会dev标志，没有就是不能开发包，不能调试和profile，重新打

# BuildRun

如果能直接BuildRun，然后直接能在模拟器上运行看profile，那么你可以不用继续看了

![image-20201103145203880](image-20201103145203880.png)

# Profile

按上面的教程生成一个dev的包，因为有可能我们根本用不上profile，而是打包机打的dev包，诸多限制用不到自己打包。

然后新建一个工程专门用来看profile，如果你还需要自己调试脚本，那么还是用原生工程吧，这个是为了让你的只用空工程看profile，一是为了不卡，而是为了更准确

先把我们的apk安装到手机或者模拟器，然后cmd测试adb是否有效，无效的话请自行 百度配置好环境变量，直接cmd adb，有反应就成了 

然后再cmd连接我们的模拟器或者手机，我这用的是mumu浏览器 ，其他真机或者其他设备查询端口连接就行了，自行百度

[adb连接mumu官方教程](http://mumu.163.com/2017/12/19/25241_730476.html?type=notice)

>adb connect 127.0.0.1:7555

连接成功是这样子

![image-20201103150235963](image-20201103150235963.png)

如果失败了看下是不是端口占用，或者先杀，在重启连接，这些都是百度得到的，可以自行测试有没有成功

![image-20201103150458532](image-20201103150458532.png)

查询一下是否连接成功

![image-20201103150618486](image-20201103150618486.png)

好的接下来就是指定我们需要的profile的apk了,Unity-后面接apk的报名，tcp端口可以随便，不要被占用就行了，用unity默认的那个也行

[官方链接](https://docs.unity3d.com/Manual/ProfilerWindow.html)

![image-20201103153450849](image-20201103153450849.png)

adb命令执行

>adb forward tcp:50000 localabstract:Unity-com.xxx.xxx

![image-20201103151738225](image-20201103151738225.png)

然后运行我们的apk，再到我们的unity里面去新建一个ip，127.0.0.1，然后等待连接大概是下面这个提示，如果这个时候没报错，恭喜你已经连接成功了，应该里面就有profile了

![image-20201103151840335](image-20201103151840335.png)

如果出现下面的错误信息，说明我们还没连上，咋办这个东西，连不上说明端口监听不到，我们换端口

![image-20201103152010607](image-20201103152010607.png)

我们可以从54998 至 55511端口重新连接连接试试,一般第二个端口就能连上了adb forward --remove-all先把之前的清掉

> adb forward --remove-all
>
> adb forward tcp:50001 localabstract:Unity-com.xxx.xxx

多试几次基本能成功，我也试了好几次

![image-20201103152729739](image-20201103152729739.png)

最后profile出来了就成功了，如果想查看某一帧，直接把录制停到就行了