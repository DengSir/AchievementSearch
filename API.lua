
local ns = select(2, ...)

local strmatch = string.match

local function safefind(source, pattern)
    local ok, result = pcall(strmatch, source, pattern)
    return ok and result
end

ns.safefind = safefind
ns.debug = debug or nop
