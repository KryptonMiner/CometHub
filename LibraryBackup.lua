local lib = {}

getgenv().ReloadScript = true
wait(.1) 
getgenv().ReloadScript = false

lib.new = function(name)
    local uiname = name or "Console Hub"
    local func = {}
    local CurrentPage = ""
    local Layers = {}
    local Value = setmetatable({},{
        __index = function(a,b)
            a[b] = {}
            return a[b]
        end
    })

    local cs = {
        iprint = printconsole, -- internal ui print
        clear = consoleclear,
        setname = consolesettitle,
        input = consoleinput,
        print = function(text,color)
            if not color then color = "white" end
            local Color = ("%s"):format(color:upper():gsub(" ","_"))
            consoleprint(Color)
            consoleprint(text.."\n", "white")
        end,
        line = function(text,color)
            if not color then color = "WHITE" end
            local Color = ("%s"):format(color:upper():gsub(" ","_"))
            consoleprint(Color)
            consoleprint(text.."\n", "white")
        end,
    }
    
    function reload(page)
        if Layers[page] then
            cs.clear()
            cs.setname(uiname.. " : ".. page)
            for i=1,#Layers[page] do v = Layers[page][i]
                v.loadfunc()
            end
        end
    end
    
    cs.setname(uiname)
    cs.clear()
    
    func.Page = function(Name)
        local page_func = {}
        Layers[Name] = {}
        page_func.show = function()
            reload(Name)
        end
        
        page_func.call = function(name,callback)
            Value.call[name] = {
                Callback = callback or function() end
            }
            
            function load()
                cs.line("[","bred")
                cs.line("-","green")
                cs.line("] ","bred")
                cs.line(name,"cyan")
                cs.print(" <call "..name..">")
            end
            load()
            table.insert(Layers[Name],{
                Name = name,
                loadfunc = load,
                value = Value.call[name].Value,
                callback = callback,
            })
        end
        
        page_func.toggle = function(name,default,callback)
            Value.toggle[name] = {
                Value = default,
                Callback = callback or function() end
            }
            
            function load()
                local color = {
                    ["true"] = "green",
                    ["false"] = "red"
                }
                cs.line("[","bred")
                cs.line("*",color[tostring(Value.toggle[name].Value)])
                cs.line("] ","bred")
                cs.line(name,"cyan")
                cs.print((" <toggle %s {true/1,false/0}>"):format(name))
            end
            load()
            table.insert(Layers[Name],{
                Name = name,
                loadfunc = load,
                value = Value.toggle[name].Value,
                callback = callback
            })
        end

        page_func.int = function(name,min,max,default,callback)
            Value.int[name] = {
                Value = default,
                max = max,
                min = min,
                Callback = callback or function() end
            }
            
            function load()
                local color = {}
                color[max] = "red"
                color[min] = "green"
                
                cs.line("[","bred")
                cs.line(Value.int[name].Value,color[tostring(Value.int[name].Value)])
                cs.line("] ","bred")
                cs.line(name,"cyan")
                cs.print((" <int %s {number between %s}>"):format(name,min.."-"..max))
            end
            load()
            table.insert(Layers[Name],{
                Name = name,
                loadfunc = load,
                value = Value.int[name].Value,
                max = max,
                min = min,
                callback = callback
            })
        end
    
        page_func.str = function(name,default,callback)
            Value.str[name] = {
                Value = default,
                max = max,
                min = min,
                Callback = callback or function() end
            }
            
            function load()
                
                cs.line("[","bred")
                cs.line(Value.str[name].Value)
                cs.line("] ","bred")
                cs.line(name,"cyan")
                cs.print((" <str %s {string/text}>"):format(name))
            end
            load()
            table.insert(Layers[Name],{
                Name = name,
                loadfunc = load,
                value = Value.str[name].Value,
                callback = callback
            })
        end
    
        page_func.list = function(name,list,default,callback)
            Value.list[name] = {
                Value = default,
                AllList = list,
                Callback = callback or function() end
            }
            
            function load()
                cs.line("[","bred")
                cs.line(Value.list[name].Value)
                cs.line("] ","bred")
                cs.line(name,"cyan")
                local allist = ""
                for i,v in pairs(list) do
                    allist = allist..v
                    if i ~= #list then
                        allist = allist..", "
                    end
                end
                cs.print((" <list %s {%s}>"):format(name,allist ))
            end
            load()
            table.insert(Layers[Name],{
                Name = name,
                loadfunc = load,
                value = Value.list[name].Value,
                list = list,
                callback = callback
            })
        end
    
        return page_func
    end
    task.spawn(function()
        while wait() do if getgenv().ReloadScript == true then cs.clear() break end -- break the loop when re-exe
            cs.print("")
            local Input = cs.input()
            local splited = Input:split(" ")
            local cmd = splited[1]
            table.remove(splited,1)
            local args = splited
            cs.clear()
            
            if cmd == "toggle" and args[1] and args[2] then -- check cmd
                -- format Value
                
                if args[2] == "true" or args[2] == "1" then
                    args[2] = true
                elseif args[2] == "false" or args[2] == "0" then
                    args[2] = false
                end
            
                -- callback and check is cmd write correctly
                local data = Value.toggle[args[1]]
                if  data and type(data.Value) == type(args[2]) then
                    data.Value = args[2]
                    data.Callback(args[2])
                else
                    cs.error("toggle {name} {value to set}")
                end
            end

            if cmd == "str" and args[1] and args[2] then -- check cmd

                -- callback and check is cmd write correctly
                local data = Value.str[args[1]]
                if  data then
                    data.Value = args[2]
                    data.Callback(args[2])
                else
                    cs.error("str {name} {value to set}")
                end
            end
            
            if cmd == "int" and args[1] and args[2] then -- check cmd
                -- format Value
                if args[2] == "true" then
                    args[2] = 1
                elseif args[2] == "false" then
                    args[2] = 0
                end
                if type(args[2]) == "string" then args[2] = tonumber(args[2]) end
                
                -- callback and check is cmd write correctly
                local data = Value.int[args[1]]
                if  data and type(data.Value) == type(args[2]) then
                    args[2] = math.clamp(args[2],data.min,data.max)
                    data.Value = args[2]
                    data.Callback(args[2])
                else
                    cs.error("int {name} {value to set}")
                end
            end
            
            if cmd == "list" and args[1] and args[2] then -- check cmd
                -- callback and check is cmd write correctly
                local data = Value.list[args[1]]
                if data and table.find(data.AllList,args[2]) then
                    data.Value = args[2]
                    data.Callback(args[2])
                else
                    cs.error("list {name} {value to set}")
                end
            end
        
            if cmd == "show" and args[1] then
                if args[1] == "page" then
                    if args[2] and Layers[args[2]] and #Layers[args[2]] > 0 then
                        CurrentPage = args[2]
                        reload(CurrentPage)
                    else
                        for i,v in pairs(Layers) do
                            if i ~= nil then
                                cs.line(i..", ")
                                cs.print("")
                            end
                        end
                        input.cs()
                    end
                end
                if args[1] == "help" then
                    cs.info("toggle {name} {true/false , 1/0} --Change toggle value")
                    cs.info("str {name} {string/text} --Change String Value")
                    cs.info("int {name} {number between max and min} --Change number value")
                    cs.info("list {name} {select list} --Change list value")
                    cs.info("show {func}")
                    cs.info("   help --show this command")
                    cs.info("   page {page/blank} --Change page or show all pages")
                end
            end
            
            if cmd == "call" and args[1] then
                Value.call[args[1]].Callback()
            end
            reload(CurrentPage)
        end
    end)
    
    return func
end
return lib
