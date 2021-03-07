---
title: tolua中的一些分析
date: 2019-03-22 11:17:26
tags: 
- lua
- tolua
---
* 1 toLua 中Vector3:Add() 和 运算符+ 以及逻辑运算
```lua
    local va = Vector3.zero
    local vb = Vector3.one
    local x1 = os.clock()
    for i = 1, 100000 do
        va = va + vb
    end
    local x2 = os.clock()
    print("first time ",x2 - x1,tostring(va))

    local va = Vector3.zero
    local vb = Vector3.one
    local x1 = os.clock()
    for i = 1, 10000 do
        va = va:Add(vb)
    end
    local x2 = os.clock()
    print("second time ",x2 - x1,tostring(va))

    local va = Vector3.zero
    local vb = Vector3.one
    local x1 = os.clock()
    for i = 1, 10000 do
        va.x = va.x + vb.x
        va.y = va.y + vb.y
        va.z = va.z + vb.z
    end
    local x2 = os.clock()
    print("third time ",x2 - x1,tostring(va))

    -- number operation > function > Vector3 operation
    -- 0 : 0.111199999 : 1.222
    -- Vector3 operation 会重新new 一个Vector3的值,调用元方法__add,使用:Add()会改变自身，内存地址不变，里面具体做了什么操作需要自身理解，使用number operation也只改变自身,使用蒙哥的Add方法会发生一些不可描述的错误，暂时没有理解
```
[Vector3.lua](https://github.com/topameng/tolua/blob/master/Assets/ToLua/Lua/UnityEngine/Vector3.lua)

