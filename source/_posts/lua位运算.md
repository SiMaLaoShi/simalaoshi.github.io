---
title: lua位运算
date: 2019-03-25 15:22:14
tags:
- lua
---
* 1 位运算这个是第三方实现的位运算
[blog使用lua实现位运算](http://www.cppblog.com/zhenyu/archive/2005/11/11/1050.html)
```lua
--位运算
--[[
Description:
    FileName:bit.lua
    This module provides a selection of bitwise operations.
History:
    Initial version created by  阵雨 2005-11-10.
Notes:
  ....
]]
--[[{2147483648,1073741824,536870912,268435456,134217728,67108864,33554416,16777216,
        8388608,4194304,2097152,1048576,524288,262144,131072,65536,
        16768,16384,8192,4096,2048,1024,512,256,128,64,16,16,8,4,2,1}
        ]]

--暂时使用16位来运算，暂时项目中没有超过2^16的值,或者可以使用C库(这里我改了作者的运算位数)
bit={data16={}}
for i=1,16 do
    bit.data16[i]=2^(16-i)
end

---d2b 十进制转换为二进制
---@param arg number
function bit:d2b(arg)
    --todo 这个tr可以使用外部缓存就没有必要每次都创建一个16的table
    local   tr={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    for i=1,16 do
        if arg >= self.data16[i] then
        tr[i]=1
        arg=arg-self.data16[i]
        else
        tr[i]=0
        end
    end
    return   tr
end   --bit:d2b

---b2d 二进制转为10进制
---@param arg table
function    bit:b2d(arg)
    local   nr=0
    for i=1,16 do
        if arg[i] ==1 then
        nr=nr+2^(16-i)
        end
    end
    return  nr
end   --bit:b2d

---_xor 异或操作
---@param a table
---@param b table
function    bit:_xor(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={}

    for i=1,16 do
        if op1[i]==op2[i] then
            r[i]=0
        else
            r[i]=1
        end
    end
    return  self:b2d(r)
end --bit:xor

---_and 与操作
---@param a table
---@param b table
function    bit:_and(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    
    for i=1,16 do
        if op1[i]==1 and op2[i]==1  then
            r[i]=1
        else
            r[i]=0
        end
    end
    return  self:b2d(r)
    
end --bit:_and

---_or 或操作
---@param a table
---@param b table
function    bit:_or(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    
    for i=1,16 do
        if  op1[i]==1 or   op2[i]==1   then
            r[i]=1
        else
            r[i]=0
        end
    end
    return  self:b2d(r)
end --bit:_or

---_not 取反
---@param a table
function    bit:_not(a)
    local   op1=self:d2b(a)
    local   r={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

    for i=1,16 do
        if  op1[i]==1   then
            r[i]=0
        else
            r[i]=1
        end
    end
    return  self:b2d(r)
end --bit:_not

---_rshift 右移
---@param a table
---@param n table
function    bit:_rshift(a,n)
    local   op1=self:d2b(a)
    local   r=self:d2b(0)
    
    if n < 16 and n > 0 then
        for i=1,n do
            for i=31,1,-1 do
                op1[i+1]=op1[i]
            end
            op1[1]=0
        end
    r=op1
    end
    return  self:b2d(r)
end --bit:_rshift

---_lshift 左移
---@param a table
---@param n table
function    bit:_lshift(a,n)
    local   op1=self:d2b(a)
    local   r=self:d2b(0)
    
    if n < 16 and n > 0 then
        for i=1,n   do
            for i=1,31 do
                op1[i]=op1[i+1]
            end
            op1[16]=0
        end
    r=op1
    end
    return  self:b2d(r)
end --bit:_lshift


---print 二级制输出函数
---@param ta table
function    bit:print(ta)
    local   sr=""
    for i=1,16 do
        sr=sr..ta[i]
    end
    print(sr)
end
```
