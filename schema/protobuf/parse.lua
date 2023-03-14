local pb = require "pb"
local protoc = require "protobuf.protoc"

local M = {}

function M:new(obj, mode, wrapper)
    obj = obj or {}
    setmetatable(obj, {__index = M})
    local p = protoc.new()
    p.include_imports = true
    obj.protoc = p
    obj.mode = mode
    obj.wrapper = wrapper
    obj.loads = {}
    return obj
end

function M:setmode(mode)
    assert(mode)
    self.mode = mode
end

function M:load(file)
    if self.loads[file] then
        return
    end

    local f = io.open(file, "rb")
    assert(f, "can not open " .. file)
    local buffer = f:read "*a"
    f:close()
    self.protoc:load(buffer)
    self.loads[file] = true
end

function M:parse(msgname, defines)
    for field, base, _type in pb.fields(msgname) do
        local msgtype = select(3, pb.type(_type))
        assert(msgtype ~= "map", "This feature has not been implemented yet")

        local lable = select(5, pb.field(msgname, field))
        lable = lable == "repeated" and "array" or "normal"
        defines[field] = {_type = _type, lable = lable}
        if msgtype == "message" then
            defines[field].subattrs = {}
            self:parse(_type, defines[field].subattrs)
        end
    end
end

function M:generate_random(defines, data)
    for name, def in pairs(defines) do
        data[name] = {}
        if def.subattrs then
            self:generate_random(def.subattrs, data[name])
        else
            local wrapper = self.wrapper
            data[name] = wrapper(def.lable, def._type)
        end
    end
end

local function generate_custom(defines, protofile, protoname)
    local result = nil
    local f = io.open(protofile, "rb")
    local str = "//@mock%s#%s*:"
    str = str:gsub("#", protoname)
    for line in f:lines() do
        if line:match(str) then
            line = string.gsub(line, str, "")
            result = line
            break
        end
    end
    f:close()
    if result then
        local r = load("return " .. result, "@" .. protoname, "bt")()
        if type(r) == "function" then
            return r()
        else
            return r
        end
    else
        return {}
    end
end

function M:generate(defines, protofile, protoname)
    if self.mode == "empty" then
        return {}
    end

    if self.mode == "custom" then
        return generate_custom(defines, protofile, protoname)
    end
    
    if self.mode == "random" then
        local randomdata = {}
        self:generate_random(defines, randomdata)
        return randomdata
    end
end

return M