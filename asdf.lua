local cacheStep = {
    {
        "***",
        "* *",
        "***",
    },
    {
        "*********",
        "* ** ** *",
        "*********",
        "***   ***",
        "* *   * *",
        "***   ***",
        "*********",
        "* ** ** *",
        "*********",
    }
}
local rep = string.rep
local concat = table.concat

local function buildStep(n)
    if cacheStep[n] then return cacheStep[n] end

    local child = cacheStep[n-1]
    if not child then
        child = buildStep(n-1)
    end

    local newStep = {}
    local childSizeX = 3^(n-1)
    local lastLineOffset = childSizeX*2
    local space = rep(" ",childSizeX)

    for i=1,childSizeX do
        local line = child[i]
        local lineRep = rep(line,3)
        newStep[i] = lineRep
        newStep[i+lastLineOffset] = lineRep

        newStep[childSizeX+i] = concat(line,space,line)
    end

    cacheStep[n] = newStep

    return newStep
end

local N = io.read'n'
local K = math.floor(math.log(N,3)+0.5)
-- for _,str in ipairs(buildStep(K)) do
--     print(str)
-- end
io.write(table.concat(buildStep(K),'\n'))
