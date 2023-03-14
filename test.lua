
package.path = package.path .. ";./?.lua"
package.path = package.path .. ";./schema/?.lua"
package.cpath = package.cpath .. ";./libs/?.so"

local mock = require "mock"
array_size = 10
local test = mock:new("protobuf.parse", "custom")
test:run("./test.proto", "TestProto1", function(data)
    -- socket.send(fd, pack(data))
end)
