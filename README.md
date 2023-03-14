### 在lua中使用protobuf协议进行mock测试

第三方库 : [https://github.com/starwing/lua-protobuf]()

lua版本 : 5.3

**样例**

生成随机测试数据:

```lua
package.path = package.path .. ";./?.lua"
package.path = package.path .. ";./schema/protobuf/?.lua"
package.cpath = package.cpath .. ";./libs/?.so"

local mock = require "mock"
array_size = 10
local test = mock:new("parse", "random")
test:run("./test.proto", "TestProto1", function(data)
    -- socket.send(fd, pack(data))
	end)
```

生成自定义数据:

自定义数据需要在协议文件中添加标签, 标签格式 //@mock 协议名 :

```proto
//@mock TestProto1 : {id = 1, list = {"a", "b", "c"}, sub = {ok = true, value = 1.9}}
message TestProto1 {
	required uint32 id = 1;
	repeated string list = 2;
	message SubMessage {
		optional bool ok = 1;
		optional float value = 2;
	}
	optional SubMessage sub = 3;
}
```

```lua
package.path = package.path .. ";./?.lua"
package.path = package.path .. ";./schema/protobuf/?.lua"
package.cpath = package.cpath .. ";./libs/?.so"

local mock = require "mock"
array_size = 10
local test = mock:new("parse", "custom")
test:run("./test.proto", "TestProto1", function(data)
    -- socket.send(fd, pack(data))
	end)
```

