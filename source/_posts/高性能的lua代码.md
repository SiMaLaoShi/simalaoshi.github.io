---
title: 高性能的lua代码
date: 2019-03-21 18:05:08
tags:
- lua
---

* 1 变量访问速度 local > upValue > Global
``` lua
    local x1 = os.clock()
    for i = 1, 100000 do
        local a = 10000
        a = a * i
    end
    local x2 = os.clock()
    print("local speed", x2 - x1)

    local x1 = os.clock()
    local a = 10000
    for i = 1, 100000 do
        a = a * i
    end
    local x2 = os.clock()
    print("upValue speed", x2 - x1)


    local x1 = os.clock()
    a = 10000
    for i = 1, 100000 do
        a = a * i
    end
    local x2 = os.clock()
    print("global speed", x2 - x1)
    
    --local speed	0.003
    --upValue speed	0.014
    --global speed	0.018

```
* 2 string.format < ..连接符
``` lua
    local x1 = os.clock()
    for i = 1, 100000 do
        local str = string.format("value %s",i)
    end
    local x2 = os.clock()
    print("string.format time", x2 - x1)

    local x1 = os.clock()
    for i = 1, 100000 do
        local str = "Hello" .. i
    end
    local x2 = os.clock()
    print("..operation time", x2 - x1)
```
* 3 table.insert(table,value) < table[#table + 1] = value
```lua
    local x1 = os.clock()
    local tb = {}
    for i = 1, 100000 do
        table.insert(tb,i)
    end
    local x2 = os.clock()
    print("table.insert time", x2 - x1)

    local x1 = os.clock()
    local tb = {}
    for i = 1, 100000 do
        tb[#tb + 1] = i
    end
    local x2 = os.clock()
    print("table[#table + 1] time", x2 - x1)
    --table.insert time	0.013
    --table[#table + 1] time	0.009
```
* 4 预先创建固定长度的table > 动态创建长度的table
```lua
    local x1 = os.clock()
    for i = 1, 100000 do
        local tb = {0,0,0}
        tb[1] = 1 + i
        tb[2] = 2 + i
        tb[3] = 3 + i
    end
    local x2 = os.clock()
    print("预先创建固定长度的table time", x2 - x1)

    local x1 = os.clock()
    for i = 1, 100000 do
        local tb = {}
        tb[1] = 1 + i
        tb[2] = 2 + i
        tb[3] = 3 + i
    end
    local x2 = os.clock()
    print("动态创建长度的table", x2 - x1)
    --预先创建固定长度的table time	0.041
    --动态创建长度的table	0.064
```
