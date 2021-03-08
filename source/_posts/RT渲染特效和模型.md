---
title: RT渲染特效和模型的研究
date: 2020-05-17 22:12:51
tags:
- Unity
---
# RT 

## 需求

项目中我们有用到模型在ui上显示，一般有两种方式一种是直接挂模型，然后通过调整RenderQueue来保证渲染顺序，但是太过复制，没有使用	

还有一种就是通过RT渲染到ui上，然后通过ui原生的渲染方式去保证我们渲染队列的正确，多一张RT的内存，我们选用的是rt的方式。

## 问题

问题就是RT在渲染粒子的时候，我们使用的是不带通道的雪花片，在3d场景中通过下面的混合方式达到透明效果，我们的RT相机一般设置SolidColor模式，颜色全是0

**第一次Alpha Blend**

Particle & Background  ==> RenderTexture    

> 雪花片背景是黑色的我们要过滤掉黑色，参考滤色公式 ，最终表达为如下
>
> > 结果色=255－[（255－基色）×（255－混合色）]/255
>
> ```http
> Blend OneMinusDstColor One
> Blend One OneMinusSrcColor
> ```

```http
 Blend One OneMinusSrcColor
 // 混合公式是滤色，黑色作为透明色
 ColorMask RGBA
 // Mask保留RGBA
```

**第二次Alpha Blend**

RenderTexture & UI    ==> FinalColor

```http
 Blend SrcAlpha OneMinusSrcAlpha
 ColorMask [RGBA]
 // Blend SrcAlpha OneMinusAlpha		正常模式（传统透明度混合）
```

这样会有什么问题呢？？

第一次我们把正常的模型渲染到RT上,使用默认的UI-Default.shader,我们UI-default的blend公式:

**`Blend SrcAlpha OneMinusSrcAlpha`**

如果我们从RT上传过来RawImage的Src带了透明通道是而且alpha为0的话，按照上面这个公式src就没了，就会直接一片空白，直接观察RT就行了下图，我们的RT相机的A通道需要设置为0

![](image-20201017153614701.png)

所以我们需要修改一下混合公式，我们的src（从RT上传过来的只看雪花片）的alpha是为1（ColorMask RGBA），所以我们需要把src原样输出和滤掉黑色，所以不能用默认的混合方式了，所以需要把原来的混合方式改掉，思考一个问题，能不能用我们第一次用的这个

`Blend One OneMinusSrcColor`

如果只是对我们的雪花片当然是可以，但是假如我们还有其他的东西，通过这个公式会让其他的src变淡，可以自己代入公式试下，试想一下我们是不是只要处理雪花片，而雪花片只需要处理alpha，我们只要把alpha处理掉就行了，我们雪花片的背景的alpha是1还记得吗，那就全给他去掉

` Blend One OneMinusSrcAlpha // Premultiplied transparency`

这个公式就能去掉src的alpha值，而不影响其他的色值，改下试下，你会发现还不行

![image-20201017171057108](image-20201017171057108.png)，

先不急观察一下，看下除了雪花片其他背景是透明的，雪花片背景是黑色？？，先不急，先改下雪花片的Shader的ColorMask 为RGB，发现居然正常了，这个是什么情况？？我们用FrameDebug查看渲染雪花片那一帧看下是什么情况，只看a通道发现雪花片本身就不带通道的？？而我们的ColorMask 是RGBA，所以这个a是1，（虽然我们的雪花片的不带通道，但是经过blend后就是dst的通道就是1，然后传递到rt也是1了）传递到RT上这个A就是1，我们再到RawImage上也是带透明通道的，而这个透明是0（和我们刚刚的是反了）这个是因为我们雪花片的shader最后的finalcolor 是黑色而且带了alpha通道，用刚刚我们的那个公式，只要alpha是1就正常了是吧，那就把我们雪花片的shader最后的finalcolor不带通道就好了不是，直接Color Mask RGB 就ok了。

[例子可以参考一下](Blend公式.unitypacka)

## 参考

- [UI上使用RenderTexture显示模型+AlphaBlend特效](https://www.cnblogs.com/garsonlab/p/10172539.html)
- [小米超神的解决方案](https://blog.uwa4d.com/archives/Severe_MOBA.html)
- [uwa渲染分析](https://answer.uwa4d.com/question/5bec285228a16f55acc394b0)
- [半透明特效在RenderTexture上的显示问题](https://blog.csdn.net/coffeecato/article/details/105018866)
- [请问用RenderTexture把模型显示到UI时，模型携带的特效无法正确显示怎么解决](https://answer.uwa4d.com/question/5c7a42be63826a332ad99778)
- [用Camera展示特效到RenderTexture，修改相机背景透明值，特效也会随着透明问题？](https://answer.uwa4d.com/question/59d5e6ce7974cff22fd433d8)

