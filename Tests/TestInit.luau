local Stdio = require("@lune/stdio")
local Fs = require("@lune/fs")

local TestName: string = Stdio.prompt("text", "What test would you like to run? ")
local Tests = Fs.readDir("./Tests")

for _, Test in Tests do
    if Test:lower() ~= string.lower(`{TestName}.luau`) then
        continue
    end

    print(TestName)
    print(Test)

    local Path = require(`./{string.lower(TestName)}`)
    Path.Test()
end
