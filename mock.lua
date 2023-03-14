
array_size = 3

local function foreach(size, func, ...)
    for i = 1, size do
        func(i, ...)
    end
end

random = {
    ["string"] = function()
        local list = {}
        foreach(array_size, function(i)
            list[i] = string.char(math.random(33, 126))
        end, list)
        return table.concat(list)
    end, 
    ["uint32"] = function()
        return math.random(1, 10000)
    end, 
    ["uint64"] = function()
        return math.random(1, 10000) << 32
    end, 
    ["int32"] = function()
        return math.random(1, 10000) - 10000
    end, 
    ["int64"] = function()
        return math.random(1, 10000) << 32
    end, 
    ["float"] = function()
        return math.random() * 10000 - 5000
    end, 
    ["double"] = function()
        return math.random() * 10000 - 5000
    end, 
    ["bool"] = function()
        return math.random(1, 100) > 50
    end, 
}
setmetatable(random, {
    __index = function(...)
        return function() return 0 end
    end, 
    __call = function(self, _type)
        return self[_type]()
    end
})

wrapper = {
    ["array"] = function(_type)
        local array = {}
        foreach(array_size, function(i)
            array[i] = random(_type)
        end)
        return array
    end,  
}
setmetatable(wrapper, {
    __index = function(lable)
        return random
    end, 
    __call = function(tb, lable, _type)
        return tb[lable](_type)
    end
})

local seed = tonumber(tostring(math.sin(os.time())):sub(4, 12))
math.randomseed(seed)

local M = {}

function M:new(schema, mode)
    local tb = {}
    setmetatable(tb, {__index = M})
    local parse = require(schema)
    local obj = parse:new({}, mode, wrapper, random)
    tb.obj = obj
    return tb
end

function M:run(file, proto, callback)
    self.obj:load(file)
    local defines = {}
    self.obj:parse(proto, defines)
    local data = self.obj:generate(defines, file, proto)
    callback(data)
end

return M