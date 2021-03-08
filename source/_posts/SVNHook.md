---
title: SVN Hook
date: 2019-04-2 11:21:11
tags:
- lua
- svn
---

# 需求

在我们开发游戏，我们之前管理资源的时候，总是遇到不规范提交，比如贴图什么的没有带.meta,代码不是utf-8，什么没加日志，什么之类导致查问题查好久，就想着怎么不然让这些提交，或者提醒他们哪里不规范之类，就想着搞一搞

# 思路

一些资源我们在unity提交到时候，直接通过unity去检查，然后提醒，但是想着美术不用unity怎么办，或者在unity文件夹外面怎么样，等等一些问题，好像坐在svn好一点，刚好svn也有 pre-comint, post-comit 等等一些hook，脚本，不熟悉这些是什么东西的可以自行查找资料熟悉一下。推荐小乌龟，安装的时候要勾选命令行行工具。

# 工具

[小乌龟服务端](https://www.visualsvn.com/server/download/)

[小乌龟客户端](https://tortoisesvn.net/index.zh.html)

[Python](https://www.python.org/)

# 实现

我们用新建一个仓库，或者在原来有仓库找到下面的目录，仓库根目录，有下面几个文件夹，我们进入到hook，先不用关闭

![image-20201126203216244](image-20201126203216244.png)

在svn服务端选到管理Hook选项

![image-20201126204106060](image-20201126204106060.png)

出现这样一个东东，就是我们上面提到的pre,post等等，我们只要用pre就行了，双击

![image-20201126204310705](image-20201126204310705.png)

出来一个这个东西，把下面我的代码复制进去，然后点确定，会在我们的版本库根目录的hook文件夹生成一个pre-commit.cmd，这里是和cmd一样的，有基础的可以自己操作了，后面都是做一些很简单的事情，

通过python检查提交的问题，然后反馈结果码，svn做处理，就是这个思路。

![image-20201126204741900](image-20201126204741900.png)

```vbscript
@echo off
setlocal
set REPOS=%1
set TXN=%2
rem 这里设置svnlook的路径
set SVNLOOK="C:\Program Files\TortoiseSVN\bin\svnlook"
rem 这里设置python的安装路径
set PYTHON="C:\Python38\python.exe"
rem 预处理脚本的路径
set pre-commit="F:\Documents\utility\hooks\pre-commit.py"
rem 检查资源文件
%PYTHON% %pre-commit% %REPOS% %TXN%
rem 检查日志长度
%SVNLOOK% log "%REPOS%" -t "%TXN%" | findstr ".........." > nul
if %errorlevel% gtr 0 goto err
exit 0
:err
echo 提交必须写10个字以上的日志!!!>&2
exit 1
```



这里就简单的介绍一些基本的svn命令，怎么获取信息，然后处理，后面的东西就需要自己去做处理了。

![image-20201126205357846](C:\Users\szgla\Desktop\Git\Notes\疑难杂症\SVNHook\image-20201126205357846.png)

如果你安装了svn，可以在cmd直接输入svnlook help 可以查看一些svnlook的一些命令操作，我们主要用这个命令，这里我用的是python

```python
command = "svnlook" + " changed -t " + txn + " " + repo
```

这里的 txn 和 repo 就是我们在上面的cmd命令里设置的，通过命令行传到python脚本就行了。这个命令是干嘛的呢，这个命令就是我们提交svn里面是增加文件，或者是删除文件和更新文件的列表，我们通过python拿到这个列表，就可以知道是什么操作了。

```vbscript
set REPOS=%1
set TXN=%2
```

这里还要简单介绍一个几个字符,我这里就是通过这个字符去判断是什么操作，熟练svn的肯定也知道这个是什么操作，不多说了

>'A' 就是add文件 'D' 就是delete文件 'U'就是update文件