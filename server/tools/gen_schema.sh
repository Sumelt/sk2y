#!/bin/bash

# cd 到当前脚本目录的上层目录
cd "$(dirname "$0")/.."

./bin/lua tools/run.lua 3rd/sproto-orm/tools/sproto2lua.lua common/lualib/orm/schema_define.lua common/schema/*.sproto
./bin/lua tools/run.lua 3rd/sproto-orm/tools/gen_schema.lua common/lualib/orm/schema.lua common/lualib/orm/schema_define.lua
