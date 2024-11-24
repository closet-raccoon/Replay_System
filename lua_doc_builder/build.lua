local file,_ = io.open([[C:\Users\Keagan\Documents\GitHub\OBS_REPLAY\lua_doc_builder\obslua.lua]],"w")
assert(file)
file:write("return {\n")
for k,v in pairs(obslua) do
    if type(v) == "function" then
        file:write("    "..k..' = function(...) return "" end,\n')
    elseif type(v) == "table" then
        file:write("    "..k.." = {},\n")
    elseif type(v) == "string" then
        file:write("    "..k.." = [["..tostring(v).."]],\n")
    else
        file:write("    "..k.." = "..tostring(v)..",\n")
    end
end
file:write("}")
file:close()
