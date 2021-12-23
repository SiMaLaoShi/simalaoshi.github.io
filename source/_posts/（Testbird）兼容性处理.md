---
title: （Testbird）兼容性处理
date: 2021-12-23 10:42:33
tags: Unity
---

## 简单描述（只是针对安卓）

###### 这篇文章主要是针对Unity开发的游戏Testbird的兼容性测试对应的报告进行的处理，自己项目进行Top600测试是通过率达95以上,下面针对报告中每一项进行说明处理。

### 刘海屏，挖孔屏，水滴屏（文末有解决方案）

#### 刘海屏未做适配，主界面左侧部分内容被遮挡。

刘海屏适配，做好刘海屏适配就没问题。

#### 挖孔屏未做适配，界面左侧部分内容被遮挡。

这个处理和刘海屏一样处理，处理完就能通过。

#### 水滴屏未做适配，主界面左侧部分内容被遮挡。

这个处理和刘海屏一样处理，处理完就能通过。

#### 部分异形屏手机左侧留白过宽，建议优化。

这个处理和刘海屏一样处理，处理完就能通过（这个主要是由于没有乘上UGUI的Canvas缩放）。

### 全面屏

#### 游戏未全屏适配，界面左侧留有黑边，现有的适配方案（ov机型， vivo y97，vivo z3青春版）

这个某些机型会自带刘海屏适配，根据他们官网给的视频方案就是不遮挡ui就行了，但是Testbird是不给通过的，这个暂时没有解决办法。

#### 游戏未全屏适配，界面上下留有黑边，现有的适配方案建议优化（华为机型）

这个一般华为高端机型都有，但是就两个好像，对比了市面上的游戏基本的都是没有适配的，这个是厂商给的黑边，暂时没有解决方案。

#### 键盘界面，刘海屏未做适配，界面被遮挡。（荣耀 8C）

这个就是键盘抬起的时候遮挡了我们的内容，主要还是某些是拉取的是全键盘。

#### 进入游戏初始界面右侧留有底纹，建议优化

这个就是有些ui遮罩是没有覆盖全面屏，比如给4000*4000的分辨率，但是对折叠屏这种就有问题，需要根据ui方案自行解决（UGUI设置为锚框就行了）

#### 全面屏未适配，启动时留有黑边。

如果是游戏启动比如说Splash一般都是全屏，但是比如一些宽屏没处理就有留有黑边。

### 安装失败

这个需要自己检查类库，结合安卓版本和类库去检查，这种一般就是版本太低，或者是手机不支持某个架构，最好把x68,av7,av8都打包进去。

### 运行闪退

一般都是内存不够闪退，如果这个就是做优化了，还有就是GFX的闪退，这个需要具体情况具体观察，有些unity版本下会闪退，建议使用i2cpp的以及64位包能降低闪退率，结合bugly解决了。

### 运行卡死

这个需要根据游戏自身内容取定位了。

## 解决方案

### 刘海，挖孔，水滴适配处理

#### 我们有三重保障，这个主要就是ui的适配，其实就是需要知道刘海屏的宽度，其他的都很好解决了。

##### 第一重保障（配置）

一些杂七杂八的机型我们就是通过配置去解决，第一步就是配置，配置就是已经知道是刘海屏的宽度什么的就不需要做任何处理了

##### 第二重保障（服务器配置）

为了避免更新我们再用一重服务器配置，但是这个无法在启动的时候有可能会出现切换一下的情况，主要还是异步的，这个看自己解决了，这个主要为了查缺补漏。

#### 第三重保障（重点 这里就要写代码了）

##### API 28以上（DisplayCutout）

```java
WindowInsets rootWindowInsets = getCurActivity().getWindow().getDecorView().getRootWindowInsets();
DisplayCutout displayCutout = rootWindowInsets.getDisplayCutout();
Log.i("getSafeInsetLeft", ""+ displayCutout.getSafeInsetLeft());
Log.i("getSafeInsetRight", ""+ displayCutout.getSafeInsetRight());
Log.i("getSafeInsetTop", ""+ displayCutout.getSafeInsetTop());
Log.i("getSafeInsetBottom", ""+ displayCutout.getSafeInsetBottom());
List<Rect> rects = displayCutout.getBoundingRects();
if (null == rects || 0 == rects.size()) {
   	//通过这个判断是不是刘海屏。
} else {
	//处理刘海屏的发送到unity的逻辑,正常来说getSafeInsetTop 就是刘海的宽度，也有下刘海
}
```

假如你的ui方案是使用的UGUI的话，需要最后的刘海宽度，需要乘上canvas的缩放，我这里给一段lua代码，其他ui方案碰到这种情况也可能需要加上缩放。

```lua
local apiSize --这里是从java端返回的size
apiSize = apiSize / UnityEngine.Screen.width * mainCanvas.transform:GetComponent(typeof(RectTransform)).rect.width
```

#### API 28以下（根据厂商适配 OPPO，VIVO，华为，小米）

这里我就不写了，有点累赘，网上找一下应该能找一堆，根据他们来写就行了，但是主要，还是需要处理UGUI上Canvas的缩放。

### 全面屏

在我们的Splash.activity，可能每个项目不同，一般就是启动时的Activity，在生命周期的onCreate()方法添加设置全屏的代码

```java
requestWindowFeature(Window.FEATURE_NO_TITLE);
super.onCreate(savedInstanceState);
getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN |
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
```

### 特殊机型适配失败

##### 刘海反了

```c#
Screen.orientation //这个api获取的屏幕信息和我们的刘海屏的方向是反的（机型比较少），这个就需要配置去处理了。
```

##### 系统自带黑边适配（就是左边的刘海屏直接填充为黑色了）

这种系统自带的暂时没有好办法处理，但是在我们的测试中很少，就是几个ov机型，这种自带适配的，就需要加个配置从刘海屏适配中过滤掉，不然会重复适配。

## 总结

其实还是需要是刘海屏的视频，针对每个以上列举可能不全，但大多数是安卓手机而非游戏问题的都包括在里面了。
