---
title: RenderDoc和GPA调试模拟器
date: 2021-03-01 20:31:50
tags:
- Unity
- 工具
---
# 准备工作

[RenderDoc 12版本64位](https://renderdoc.org/stable/1.12/RenderDoc_1.12_64.zip)

![image-20210304165922352](image-20210304165922352.png)

[GPA 20](https://registrationcenter-download.intel.com/akdlm/irc_nas/17543/gpa_20.4.1608031112_release-external_x64_standalone.msi)

![image-20210304181643165](image-20210304181643165.png)

[mumu模拟器](https://a11.gdl.netease.com/MuMuInstaller_1.2.0.0_nochannel_zh-Hans_1614587994.exe)

![image-20210304165747887](image-20210304165747887.png)

[夜神模拟器](https://res06.bignox.com/full/20210220/d805fd0b971d4eebb77685596ae90db3.exe?filename=nox_setup_v7.0.0.9_full.exe)

![image-20210304181836817](image-20210304181836817.png)

# RenderDoc 和mumu模拟器

## 第一步

设置环境变量，可以百度看如何设置	RENDERDOC_HOOK_EGL = 0

![image-20210304180206186](image-20210304180206186.png)

使用管理员打开RenderDoc，或者有提示允许就行了

## 第二步

设置RenderDoc Tools -> Settings

![image-20210304175224276](image-20210304175224276.png)

![image-20210304175239953](image-20210304175239953.png)

## 第三步

切换到启动界面 File -> Launch Application

## 第四步

设置要调试的软件， mumu是 NemuHeadless.exe

![image-20210304175537214](image-20210304175537214.png)

## 第五步

设置Global Hook

![image-20210304175621923](image-20210304175621923.png)

![image-20210304175636350](image-20210304175636350.png)

注意看，按钮灰了，不知道怎么启动？？不要慌，直接启动我们的mumu模拟器，有GUI标识就成功了(一定要进去启动界面，不要只看广告界面)，然后就可以RenderDoc的教程，可以直接看文档，

![image-20210304175744008](image-20210304175744008.png)

F12来一下

![image-20210304175859931](image-20210304175859931.png)

这样就截帧好了，夜神模拟器也是一样的。

## MUMU模拟器设置

这个是默认设置，如果你没有改动，可以直接使用，有改动，改成DX

![image-20210304180038182](image-20210304180038182.png)

# InterGPA和夜神,Mumu

## 第一步

设置环境变量，可以百度看如何设置	RENDERDOC_HOOK_EGL = 0

管理员打开Graphics Monitor 2020 R3 我这是2020版本，打开Graphics Monitor就是了

## 第二步

注意这里是NemuPlayer.exe

![image-20210304180559562](image-20210304180559562.png)

这个可以不用勾选，勾选了每个应用启动的时候gpa都会分析，没必要，进来有GUI表示就好了

![image-20210304180701584](image-20210304180701584.png)

![image-20210304180758956](image-20210304180758956.png)

## 第三步

怎么截帧？？我们安装了gpa，桌面应该有四个图标，看看，我们可以从桌面打开，或者直接，注意是NemuHeadless.exe

![image-20210304181001338](image-20210304181001338.png)

如果我们是直接打开的System Analyzer 2020 R3，注意看下右边，我们

![image-20210304181238137](image-20210304181238137.png)

![image-20210304181302025](image-20210304181302025.png)

![image-20210304181313916](image-20210304181313916.png)

选中NemuHeadless.exe，这里就可以截帧了，后面就是gpa的常规操作了。

![image-20210304181335350](image-20210304181335350.png)

# 总结

设置环境变量很重要，一定要等模拟器进去主界面，看gui，如果没有gui，直接退，然后进管理关掉模拟器的所有进程，经过我测试，mumu，夜神都能运行成功，成功截图，没有运行成功就关掉进程多试几次

![image-20210304182535615](image-20210304182535615.png)

![image-20210304182813450](image-20210304182813450.png)
