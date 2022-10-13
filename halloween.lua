-- delay loaded tables fail to deserialize cross [C] boundaries (such as when having to read files that cause yields)
local local_pairs = function(tbl)
    local mt = getmetatable(tbl)
    return (mt and mt.__pairs or pairs)(tbl)
  end
  -- Important: pretty formatting will allow presenting non-serializable values
  -- but may generate output that cannot be unserialized back.
  function serialize(value, pretty)
    local kw =  {["and"]=true, ["break"]=true, ["do"]=true, ["else"]=true,
                 ["elseif"]=true, ["end"]=true, ["false"]=true, ["for"]=true,
                 ["function"]=true, ["goto"]=true, ["if"]=true, ["in"]=true,
                 ["local"]=true, ["nil"]=true, ["not"]=true, ["or"]=true,
                 ["repeat"]=true, ["return"]=true, ["then"]=true, ["true"]=true,
                 ["until"]=true, ["while"]=true}
    local id = "^[%a_][%w_]*$"
    local ts = {}
    local result_pack = {}
    local function recurse(current_value, depth)
      local t = type(current_value)
      if t == "number" then
        if current_value ~= current_value then
          table.insert(result_pack, "0/0")
        elseif current_value == math.huge then
          table.insert(result_pack, "math.huge")
        elseif current_value == -math.huge then
          table.insert(result_pack, "-math.huge")
        else
          table.insert(result_pack, tostring(current_value))
        end
      elseif t == "string" then
        table.insert(result_pack, (string.format("%q", current_value):gsub("\\\n","\\n")))
      elseif
        t == "nil" or
        t == "boolean" or
        pretty and (t ~= "table" or (getmetatable(current_value) or {}).__tostring) then
        table.insert(result_pack, tostring(current_value))
      elseif t == "table" then
        if ts[current_value] then
          if pretty then
            table.insert(result_pack, "recursion")
            return
          else
            FormERROR("tables with cycles are not supported")
          end
        end
        ts[current_value] = true
        local f
        if pretty then
          local ks, sks, oks = {}, {}, {}
          for k in local_pairs(current_value) do
            if type(k) == "number" then
              table.insert(ks, k)
            elseif type(k) == "string" then
              table.insert(sks, k)
            else
              table.insert(oks, k)
            end
          end
          table.sort(ks)
          table.sort(sks)
          for _, k in ipairs(sks) do
            table.insert(ks, k)
          end
          for _, k in ipairs(oks) do
            table.insert(ks, k)
          end
          local n = 0
          f = table.pack(function()
            n = n + 1
            local k = ks[n]
            if k ~= nil then
              return k, current_value[k]
            else
              return nil
            end
          end)
        else
          f = table.pack(local_pairs(current_value))
        end
        local i = 1
        local first = true
        table.insert(result_pack, "{")
        for k, v in table.unpack(f) do
          if not first then
            table.insert(result_pack, ",")
            if pretty then
              table.insert(result_pack, "\n" .. string.rep(" ", depth))
            end
          end
          first = nil
          local tk = type(k)
          if tk == "number" and k == i then
            i = i + 1
            recurse(v, depth + 1)
          else
            if tk == "string" and not kw[k] and string.match(k, id) then
              table.insert(result_pack, k)
            else
              table.insert(result_pack, "[")
              recurse(k, depth + 1)
              table.insert(result_pack, "]")
            end
            table.insert(result_pack, "=")
            recurse(v, depth + 1)
          end
        end
        ts[current_value] = nil -- allow writing same table more than once
        table.insert(result_pack, "}")
      else
        FormERROR("unsupported type: " .. t)
      end
    end
    recurse(value, 1)
    local result = table.concat(result_pack)
    if pretty then
      local limit = type(pretty) == "number" and pretty or 10
      local truncate = 0
      while limit > 0 and truncate do
        truncate = string.find(result, "\n", truncate + 1, true)
        limit = limit - 1
      end
      if truncate then
        return result:sub(1, truncate) .. "..."
      end
    end
    return result
  end
  
  function unserialize(data)
    local result, reason = load("return " .. tostring(data), "=data", nil, {math={huge=math.huge}})
    if not result then
      return nil, reason
    end
    local ok, output = pcall(result)
    if not ok then
      return nil, output
    end
    return output
  end


















abs = math.abs
-----------------Настройки--------------------

------ Список тех кто может что либо изменять в ПУ. ------
        ---ВНИМАНИЕ!!!--- Менять ники во всех полях.

adminListNoAccos = { "3_1415926535", "myself", "Kristallik__", "oorr", "DrZip", "Francuzz214", "ValkyrieFX", "busa"}

------ Список тех кто может что либо изменять в ПУ. ------ 

--------------------Настройки--------------------

gpu.setResolution(146, 42)

function is_admin(nickName)
    for i = 1, #adminListNoAccos do
        if adminListNoAccos[i] == nickName then return true end 
    end
    return false
end


resW, resH = gpu.getResolution()

function clear() gpu.fill(1, 1, resW, resH, " ") end

pim_userName = ""

playersListTBL = {}

candyListTBL = {[1] = {["candyLabel"] = " [0xdb5c01]Конфетка: [0x00dbf0]", ["cost"] = 1, ["itemName"] = "hw:Candy", ["itemDamage"] = 0, ["nbt_hash"] = nil },
                [2] = {["candyLabel"] = "   [0xdb5c01]Чупачупс: [0x00dbf0]", ["cost"] = 2, ["itemName"] = "hw:Lollipop", ["itemDamage"] = 0, ["nbt_hash"] = nil },
                [3] = {["candyLabel"] = "   [0xdb5c01]Шоколадка: [0x00dbf0]", ["cost"] = 3, ["itemName"] = "hw:Chocolate", ["itemDamage"] = 0, ["nbt_hash"] = nil }}


-- softVersion = "ocelot"
softVersion = "pim"

local function proxyNoError(comp_name)
    local address = component.list(comp_name)()
    if address then
        return component.proxy(address)
    else
        return nil
    end
end

pim = proxy("pim")

pim.getInventoryName()
--https://color.romanuke.com/czvetovaya-palitra-4269/

local color = {
    pattern = "%[0x(%x%x%x%x%x%x)]",
    background = 0x000000,
    -- pim = 0xcbb796,
    pim = 0xb4b4b4, 

    gray = 0x303030,
    lightGray = 0x999999,
    blackGray = 0x1a1a1a,
    lime = 0x68f029,
    blackLime = 0x4cb01e,
    orange = 0xf2b233,
    blackOrange = 0xc49029,
    blue = 0x4260f5,
    blackBlue = 0x273ba1,
    red = 0xff0000,
    indigo = 0x6610f2,
    purple = 0x6f42c1,
    pink = 0xd63384,
    orange_500 = 0xfd9843,
    yellow = 0xffc107,
    green = 0x198754,
    teal = 0x20c997,
    cyan = 0x0dcaf0,
    white = 0xfff,
    bond = 0xdee2e6,
}

greyColors = { --grey colors
      [1] = 0x0f0f0f, [9]  = 0x878787,
      [2] = 0x1e1e1e, [10] = 0x969696,  
      [3] = 0x2d2d2d, [11] = 0xa5a5a5,
      [4] = 0x3c3c3c, [12] = 0xb4b4b4,
      [5] = 0x4b4b4b, [13] = 0xc3c3c3,
      [6] = 0x5a5a5a, [14] = 0xd2d2d2,
      [7] = 0x696969, [15] = 0xe1e1e1,
      [8] = 0x787878, [16] = 0xf0f0f0,
}


local pimGeometry = {
    x = resW / 2 - 8,
    y = resH - 11,

    "⡏⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⢹",
    "⡇              ⢸",
    "⡇              ⢸",
    "⡇              ⢸",
    "⡇              ⢸",
    "⡇              ⢸",
    "⡇              ⢸",
    "⣇⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣸"

}

local function drawPim()
    for str = 1, #pimGeometry do 
        gpuSet(pimGeometry.x, pimGeometry.y + str, pimGeometry[str], color.background, color.pim)
    end
end
function findFilesystem()
    for address in component.list("filesystem") do
        if address ~= computer.tmpAddress() and not component.invoke(address, "isReadOnly") then
            filesystem = component.proxy(address)
            return true
        end
    end
    if not filesystem then
        FormERROR("Component FileSystem not found!")
    end
end

findFilesystem()

writeFS = function(path, mode, data)
    local handle = filesystem.open(path, mode)
    filesystem.write(handle, data)
    filesystem.close(handle)
end

readFS = function(path, mode)
    if not filesystem.exists(path) then return false end
    local handle = filesystem.open(path, mode)
    local data = ""
    local chunk = ""
    repeat
        chunk = filesystem.read(handle, 1000)
        if chunk then 
            data = data..chunk
        end
    until not chunk
    if chunk then 
        handle.close(handle)
    end
    return data
end

listFS = function(path)
    return filesystem.list(path)
end

log = function(data, name)
    
    function time(raw)
        tmpfs = component.proxy(computer.tmpAddress())
        local handle = tmpfs.open("/time", "w")
        tmpfs.write(handle, "time")
        tmpfs.close(handle)
        local timestamp = tmpfs.lastModified("/time") / 1000 + 3600 * 3
    
        return raw and timestamp or os.date("%d.%m.%Y %H:%M:%S", timestamp)
    end

    local timestamp = time(true)

    local date = os.date("%d.%m.%Y", timestamp)
    local path = "/logs/" .. date .. "/"
    local days = {
        date .. "/",
        os.date("%d.%m.%Y/", timestamp - 86400),
        os.date("%d.%m.%Y/", timestamp - 172800),
        os.date("%d.%m.%Y/", timestamp - 259200)
    }
    local data = os.date("[%H:%M:%S]", timestamp) .. tostring(data) .. "\n"

    for day = 1, #days do
        days[days[day]], days[day] = true, nil
    end
    if not filesystem.exists(path) then
        filesystem.makeDirectory(path)
    end

    local paths = filesystem.list("/logs/")
    for oldPath = 1, paths.n do
        local checkPath = "/logs/" .. paths[oldPath]

        if not days[paths[oldPath]] and filesystem.isDirectory(checkPath) and checkPath:match("%d+.%d+.%d+.log") then
            filesystem.remove(checkPath)
        end
    end

    if name then
        writeFS(path .. name .. ".log", "a", data)
    else
        writeFS(path .. "main.log", "a", data)
    end
end

authSystem = {}

function authSystem:new()
    
    local obj = {}

    -- obj.session = ""

    function obj:writeUserData(userName, session)

        writeFS("/playersData/"..userName, "w", serialize((session)))
    end

    function obj:readUserData()
        local tblToReturn = {}

        local resultFS, errorResult = filesystem.list("/playersData/")

        if not resultFS then FormERROR(errorResult) end 
        if resultFS.n == 0 then return {} end

        for i = 1, resultFS.n do
            local data = unserialize(readFS("/playersData/"..resultFS[i], "r"))
            if data ~= nil and data ~= false and type(data) == "table" then
                tblToReturn[i] = tableCopy(data)
            end

        end

        return tableCopy(tblToReturn)
    end
    
    function obj:login(name)

        if name ~= nil and name ~= "no such component" then

            local signal = {computer.pullSignal(0)}

            if signal and signal[1] == "player_off" then
                main_loop()
            else
                local userData = self:readUserData()  
                pim_userName = name
                -- printTable(userData)
                -- sleep(10)
                for i=1, #userData do --Поиск зарегестрированного пользователя, если не нашёл, иду ниже.
                    -- local ok, result = pcall( function() return userData[i][name] end)
                    if userData[i] ~= nil and userData[i]["userName"] == name then 
                        playersListTBL = {} playersListTBL = tableCopy(userData)
                        FormMainMenu() 
                    end
                end
                     -- Событие регистрации нового пользователя.
                    playersListTBL = {}
                    playersListTBL = tableCopy(userData)
                    table.insert(playersListTBL, playersListTBL[1] == nil and 1 or #playersListTBL, {["userName"] = name, ["factor"] = 0, ["expiration_time"] = {["year"] = 2022, ["month"] = 09, ["day"] = 30, ["hour"] = 20, ["min"] = 60}, ["totalScore"] = 0})
                    FormMainMenu()  
            end
        else
            main_loop()
        end
    end

    if softVersion == "pim" then
        function obj:getPlayerName(signal)
            local err, name = pcall(pim.getInventoryName)
            if err and name ~= "pim" then
                return name
            else
                return false
            end
        end

    elseif softVersion == "ocelot" then
        function obj:getPlayerName(signal)
            return "myself"
        end
    end

    function obj:is_login(signal)
        local name = self:getPlayerName(signal)
        if not name then
            return false
        end
        return name
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

authSystem = authSystem:new()

inventory = {}

function inventory:new()

    local obj = {}
    obj.playerInventory = ""
    
    obj.lastErrorString = ""

    obj.playerInventory = pim

    
    if softVersion == "ocelot" then
        function obj:getQtyItems(itemName, itemDamage, nbt_hash)
            return 1000
        end

        function obj:takeItem(id, nbt_hash, dmg, count)
            if (count == 0) then
                return 0
            end
            local sum = count
            log(tostring("takeItem:".." У игрока: "..pim_userName..", забран предмет количеством: "..math.modf(sum)..", с id: "..id), pim_userName)
            return sum
        end

        
    else
        
        function obj:takeItem(id, nbt_hash, dmg, count)

            if (count == 0) then
                return 0
            end

            local inventorySize = 36
            
            local sum = 0
            if nbt_hash == nil then 
                for i = 1, inventorySize do
                    local err, item = pcall(self.playerInventory.getStackInSlot,i)
                    if err == false then break end
                    if item ~= nil and item.id == id and item.dmg == dmg and item.nbt_hash == nil then
                        local ok, result = pcall(function () return self.playerInventory.pushItem("DOWN", i, count - sum) end)
                        if not ok or result == nil then break end
                        -- gpuSet(nil, 9, tostring(math.modf(result)), color.gray_900, 0x0dcaf0)
                        -- sleep(3)
                        sum = sum + result
                    end
                    if (count == sum) then
                        if sum ~= 0 then
                            log(tostring("takeItem:".." У игрока: "..pim_userName..", забран предмет количеством: "..math.modf(sum)..", с id: "..id), pim_userName) end
                        return sum
                    end
                end
            else
                for i = 1, inventorySize do
                    local err, item = pcall(self.playerInventory.getStackInSlot,i)
                    if err == false then break end
                    if item ~= nil and item.id == id and item.dmg == dmg  and item.nbt_hash == nbt_hash then
                        local ok, result = pcall(function () return self.playerInventory.pushItem("DOWN", i, count - sum) end)
                        -- gpuSet(nil, 9, tostring(math.modf(res)), color.gray_900, 0x0dcaf0)
                        -- sleep(3)
                        if not ok or result == nil then break end
                        sum = sum + result
                    end
                    if (count == sum) then
                        if sum ~= 0 then
                            log(tostring("takeItem:".." У игрока: "..pim_userName..", забран предмет количеством: "..math.modf(sum)..", с id: "..id), pim_userName)
                        end
                        return sum
                    end
                end
            end
        
            if sum ~= 0 then
                log(tostring("takeItem:".." У игрока: "..pim_userName..", забран предмет количеством: "..math.modf(sum)..", с id: "..id), pim_userName)
            end
            return sum
        end
        
            function obj:getQtyItems(itemName, itemDamage, nbt_hash)

                local count = 0
                local allStacks = self.playerInventory.getAllStacks(false)
                local inventorySize = 36
                if type(nbt_hash) == "string" then
                    for i = 1, inventorySize do
                        if allStacks[i] ~= nil and allStacks[i].id ~= nil and allStacks[i].dmg ~= nil then
                            if allStacks[i].id == itemName and allStacks[i].dmg == itemDamage then
                                count = count + allStacks[i].qty
                            end
                        end
                    end
                else
                    for i = 1, inventorySize do
                        if allStacks[i] ~= nil and allStacks[i].id ~= nil and allStacks[i].dmg ~= nil then
                            if allStacks[i].id == itemName and allStacks[i].dmg == itemDamage then
                                count = count + allStacks[i].qty
                            end
                        end
                    end
                end
                return count
            end
    end

    setmetatable(obj, self)
    self.__index = self
    return obj

end

inventory = inventory:new()

--if not component.isAvailable("redstone") or not pcall(function() component.data.random(100) end) then error("Компонент красный контроллер не найден рядом с компьютером! Он нужен для автозапуска и автозагрузки программы, при смерти самого комптьюера, установи этот блок в плотную к системному блоку!") end
--
--component.redstone.setWakeThreshold(15)
--component.redstone.setWakeThreshold(15)
--component.redstone.setWakeThreshold(15)
--dataCard = component.data
--
globalCount = 0

signalHandler = function(canToMainLoopStatus)
    pcall(computer.pushSignal,"fakeEvent")
    globalCount = globalCount + 1
    if globalCount == 512 then
        sleep(0)
        globalCount = 0
    end

    local singal_one, signal_two, signal_three, signal_four, signal_five, signal_six = computer.pullSignal(0)
    local signal = {[1] = singal_one, [2] = signal_two, [3] = signal_three, [4] = signal_four, [5] = signal_five, [6] = signal_six}

    if signal[1] == "fakeEvent" then 
           local singal_one, signal_two, signal_three, signal_four, signal_five, signal_six = computer.pullSignal(0)
        signal = {[1] = singal_one, [2] = signal_two, [3] = signal_three, [4] = signal_four, [5] = signal_five, [6] = signal_six}
    end
    signal[0] = authSystem:is_login(signal)
    
    if signal and signal[1] == "touch" and is_admin(pim_userName) then
        gpuFill(2, 1, 20, 1, " ", color.gray_900)
        gpuSet(2, 1, tostring("L: " .. signal[3] .. " T: " .. signal[4]), color.gray_900, 0x198754)
    end
        if not signal[0] and not canToMainLoopStatus then main_loop() end

        local signalUserName = signal[6] == nil and signal[5] or signal[6]
        if pim_userName == signalUserName or is_admin(signalUserName) then
            return signal
        end
    return {[0] = signal[0], [1] = "none", [2] = "", [3] = 0, [4] = 0, [5] = 0, [6] = 0}
end


function tableCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tableCopy(orig_key)] = tableCopy(orig_value)
        end
        setmetatable(copy, tableCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

 
gpuFill = function (x, y, w, h, symbol, background, foreground)
    if background ~= nil then
        gpu.setBackground(background)
    end

    if foreground ~= nil then
        gpu.setForeground(foreground)
    end
    local newX = x == nil and w / 2 - resW or x
    gpu.fill(newX, y, w, h, symbol)
end


guiFillColorBackground = function(colorToFeelBgrn)
    gpuFill(1, 1, resW, resH, " ", colorToFeelBgrn)
end


gpuSet = function (x, y, str, background, foreground)
    if background ~= nil then
        gpu.setBackground(background)
    end

    if foreground ~= nil then
        gpu.setForeground(foreground)
    end

    gpu.set(x or math.floor(math.abs(resW / 2 + 1 - unicode.len(str) / 2)), y, str)
end

gpuSetColorText = function(x, y, str, background)
    gpu.setBackground(background)
    if not x then
        x = math.floor(math.abs(resW / 2 + 1 - unicode.len(str:gsub("%[%w+]", "")) / 2))
    end

    local begin = 1

    while true do
        local b, e, color = str:find('%[0x(%x%x%x%x%x%x)]', begin)
        local precedingString = str:sub(begin, b and (b - 1))

        if precedingString then
            gpu.set(x, y, precedingString)
            x = x + unicode.len(precedingString)
        end

        if not color then
            break
        end

        gpu.setForeground(tonumber(color, 16))
        begin = e + 1
    end
end

gpuSetAdmin = function (x, y, str, background, foreground, setBackgroundDirect, setForgroundDirect)
    if not is_admin(pim_userName) then
        return
    end

    if background ~= nil then 
        if  bufferBackGroundColor ~= background or setBackgroundDirect then
            bufferBackGroundColor = background
            gpu.setBackground(background)
        end
    end

    if foreground ~= nil then 
        if bufferForeGroundColor ~= foreground or setForgroundDirect then
            bufferForeGroundColor = foreground
            gpu.setForeground(foreground)
        end
    end

    gpu.set(x or math.floor(math.abs(resW / 2 + 1 - unicode.len(str) / 2)), y, str)
end

button = {}

function button:new(tbl, x, y, buttonWidth, buttonHeight, textOnButton, backgroundToFill, foreground, eventToFunctionExec)
    -- свойства
    local obj= {}
    obj.x = x == nil and abs(resW / 2 - buttonWidth / 2) or x 
    obj.y = y
    obj.buttonHeight = buttonHeight
    obj.textOnButton = textOnButton
    obj.lenTextOnButton = unicode.len(tostring(obj.textOnButton))
    obj.buttonWidth = buttonWidth == nil and obj.lenTextOnButton or buttonWidth
    obj.backgroundToFill = backgroundToFill
    obj.foreground = foreground
    obj.eventTrapSignalMath = {["touch"] = {["xWithButtonWidth"] = x == nil and abs(resW / 2 - (obj.buttonWidth / 2) + obj.buttonWidth - 1) or abs(obj.x + obj.buttonWidth - 1),
                                            ["yWithButtonHeight"] = abs((obj.y + obj.buttonHeight ) - 1)}}
    obj.xCordTextOnButton = x == nil and math.floor(obj.x + (obj.buttonWidth / 2) - obj.lenTextOnButton / 2) or 
                                       math.floor(obj.x + (obj.buttonWidth / 2) - obj.lenTextOnButton / 2)
                                       obj.eventToFunctionExec = eventToFunctionExec
    function obj:getTextOnButton()
        return self.textOnButton 
    end

    function obj:draw()
        gpuFill(self.x, self.y, self.buttonWidth, self.buttonHeight, " ", self.backgroundToFill, self.foreground)
        gpuSet(self.xCordTextOnButton, abs(self.y + self.buttonHeight / 2), self.textOnButton, self.backgroundToFill, self.foreground)
    end

    function obj:eventTrap(signal)
        if signal[1] == "touch" and signal[3] >= self.x and signal[3] <= self.eventTrapSignalMath["touch"]["xWithButtonWidth"] 
        and signal[4] >= self.y and signal[4] <= self.eventTrapSignalMath["touch"]["yWithButtonHeight"] then
            return true
        end
        return false
    end

    function obj:onEvent(signal)
        if self:eventTrap(signal) then
            local result = eventToFunctionExec == nil and true or eventToFunctionExec(self)
            return result
        end
        return false
    end

    function obj:reDrawTextOnButton(foreground)
        gpuSet(self.xCordTextOnButton, abs(self.y + self.buttonHeight / 2), self.textOnButton, self.backgroundToFill, foreground)
    end

    function obj:destroy(fillColorBackground)
        gpuFill(self.x, self.y, self.buttonWidth, self.buttonHeight, " ", fillColorBackground)
        self = {}
    end

    obj:draw()
    setmetatable(obj, self)
    self.__index = self; 
    return obj
end

printTable = function (t)
    clear()

    guiFillColorBackground(0x0f0f0f)
    local step = 1
    local printTable_cache = {}
 
    local function sub_printTable( t, indent )
        
        if ( printTable_cache[tostring(t)] ) then
            gpuSet(3, step, indent .. "*" .. tostring(t), 0x1e1e1e, 0xffa500)
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos, val in pairs( t ) do
                    step = step + 1
                    if ( type(val) == "table" ) then
                    gpuSet(3, step,  indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" , 0x1e1e1e, 0xffa500)
                    sub_printTable( val, indent .. string.rep( " ", unicode.len(pos)+8 ) )
                    gpuSet(3,  step,   indent .. string.rep( " ", unicode.len(pos)+6 ) .. "}"  , 0x1e1e1e, 0xffa500)
                    elseif ( type(val) == "string" ) then
                    gpuSet(3,  step,indent .. "[" .. pos .. '] => "' .. val .. '"' , 0x1e1e1e, 0xffa500)
                    else
                        gpuSet(3, step,indent .. "[" .. pos .. "] => " .. tostring(val) , 0x1e1e1e, 0xffa500)
                    end
                end
            else
                gpuSet(3, step,indent..tostring(t)  , 0x1e1e1e, 0xffa500)
            end
        end
    end
 
    if ( type(t) == "table" ) then
        gpuSet(3,step, tostring(t) .. " {" , 0x1e1e1e, 0xffa500)

        sub_printTable( t, "  " )
        gpuSet(3, step, "}" , 0x1e1e1e, 0xffa500)

    else
        sub_printTable( t, "  " )
    end

    
    -- while true do
    --     signalHandler()
    -- end
end



FormERROR = function(reason, reason2) 
    guiFillColorBackground(0x212529)
    gpuSet(nil, 12, "Произошла ошибка!", 0x212529, color.cyan)

    if reason ~= nil then
        gpuSet(nil, 14, reason, 0x212529, 0x0d6efd)
    end

    if reason2 ~= nil then
        gpuSet(nil, resH - 3, reason2, 0x212529, 0x198754)
    end
    local counter = 5
    while true do
        gpuSet(nil, 2, "                           ", 0x212529)
        gpuSet(nil, 2, "До авто выхода: " .. tostring(counter) .. " c", 0x212529, color.indigo)
        signalHandler()
        sleep(1)
        counter = counter - 1
        if counter == 1 then
            gpuSet(nil, 2, "                                     ", 0x212529)
            gpuSet(nil, 2, "До авто выхода: " .. tostring(counter) .. " c", 0x212529, color.indigo)
            sleep(1)
            main_loop()
        end
    end
end


function getPlayerDataElement()
    for i = 1, #playersListTBL do
        if playersListTBL[i]["userName"] == pim_userName then return playersListTBL[i], i end
    end
    return false
end

function FormMainMenu()

    function space(str, max_size, if_too_long, separator)
        local str = tostring(str)
        local strLen = unicode.len(str)
        if strLen > max_size then
            return unicode.sub(str, 0, max_size - unicode.len(if_too_long)) .. if_too_long
        else
            return str .. string.rep(separator, max_size - strLen)
        end
    end

    guiFillColorBackground(greyColors[2])

    gpuFill(1, 1, resW, 3, " ", greyColors[3])
    gpuSet(math.floor(math.abs(resW / 2 + 17 -
    unicode.len("ТОП-10 игроков по очкам") / 2)), 2, "ТОП-10 игроков по очкам", greyColors[3], 0xdb5c01)

    gpuSet(math.floor(math.abs(resW / 2 + 17 -
    unicode.len("[МЕСТО]  [Ник]                                 [Кол. Очков]") / 2)), 8, "[МЕСТО]  [НИК]                                 [КОЛ. ОЧКОВ]", greyColors[2], greyColors[12])

    local function drawScoreBoard()
        gpuFill(1, 9, resW, 18, " ", greyColors[2])
        pcall(function() table.sort(playersListTBL, function(a, b) return a.totalScore > b.totalScore end) end)

        for i = 1, #playersListTBL do
            gpuSetColorText(65, i + 9,
                i == 10 and "[0x00dbf0]" .. tostring(i) .. ". [0xdb5c01]" .. playersListTBL[i]["userName"] or
                "[0x00dbf0]" .. tostring(i) .. ".  [0xdb5c01]" .. playersListTBL[i]["userName"], greyColors[2])
            gpuSetColorText(109, i + 9, "[0x00dbf0]" .. playersListTBL[i]["totalScore"], greyColors[2])

            if playersListTBL[i]["userName"] == pim_userName then
                gpuSetColorText(58, i + 9, "[0xdb5c01]Вы [0xa5a5a5]->", greyColors[2])
            end

            if i == 10 then break end
        end


        local userData, userData_placeInTop = getPlayerDataElement()
        if userData_placeInTop > 10 then
            if userData then
                gpuSetColorText(65, 20,
                    "[0x00dbf0]" .. tostring(userData_placeInTop) .. ".  [0xdb5c01]" .. userData["userName"],
                    greyColors[2])
                gpuSetColorText(109, 20, "[0x00dbf0]" .. userData["totalScore"], greyColors[2])
                gpuSetColorText(58, 20, "[0xdb5c01]Вы [0xa5a5a5]->", greyColors[2])
            end
        end
    end

    drawScoreBoard()

    local function drawQtyCandys()
        gpuSet(math.floor(math.abs(resW / 2 + 17 -
        unicode.len("Сколько конфет у вас в инвентаре? ") / 2)), resH - 9, "Сколько конфет у вас в инвентаре? ", greyColors[2], 0xb4b4b4)

        local strCandysLabel = ""

        for i = 1, #candyListTBL do
            strCandysLabel = strCandysLabel ..
                candyListTBL[i]["candyLabel"] ..
                tostring(inventory:getQtyItems(candyListTBL[i]["itemName"],
                candyListTBL[i]["itemDamage"], nil))
        end
        gpuFill(1, 21, resW, 1, " ", greyColors[2])
        gpuSetColorText(math.floor(math.abs(resW / 2 + 1 -
            unicode.len(strCandysLabel:gsub('%[0x(%x%x%x%x%x%x)]', "")) / 2)) + 17, resH - 7, strCandysLabel, greyColors[2])


        gpuSet(resW / 6 - 1 - unicode.len("ИНФОРМАЦИЯ"), 8, "ИНФОРМАЦИЯ", greyColors[2], 0x66b6f0)
        
        -- gpuSet(15, 10, "* * * ", greyColors[2], greyColors[4])

        gpuSet(resW / 7 - 2 - unicode.len("Убивайте мобов,") / 2, 10, "Убивайте мобов,", greyColors[2], 0xc3c3c3)
        gpuSet(resW / 7 - 2 - unicode.len("получайте сладости,") / 2, 11, "получайте сладости,", greyColors[2], 0xc3c3c3)
        gpuSet(resW / 7 - 2 - unicode.len("И обменивайте их на очки.") / 2, 12, "И обменивайте их на очки.", greyColors[2], 0xc3c3c3)

        gpuFill(35, 4, 1, resH, "|", greyColors[2], greyColors[3])


        gpuSet(resW / 6 - 1 - unicode.len("ВЫ ВОШЛИ КАК:"), 34, "ВЫ ВОШЛИ КАК:", greyColors[2], 0x66b6f0)

        gpuSet(resW / 6 - 1 - unicode.len(pim_userName), 36, pim_userName, greyColors[2], 0xdb5c01)


        gpuFill(4, 35, 28, 1, "—", greyColors[2], greyColors[4])
        gpuFill(35, 4, 1, resH, "|", greyColors[2], greyColors[4])

        gpuFill(35, 4, 1, resH, "|", greyColors[2], greyColors[4])


    end

    local tabeCandyFromInvButton = button:new(nil, resW / 2 + 8, resH - 4, 20, 3, "Отдать конфеты", 0xd2d2d2,
        0x2d2d2d, function(self)

        local userData, userData_placeInTop = getPlayerDataElement()

        for i = 1, #candyListTBL do
            local totalQtyItemInPlayerInventory = inventory:getQtyItems(candyListTBL[i]["itemName"],
                candyListTBL[i]["itemDamage"], nil)

            local totalQtyTaked = inventory:takeItem(candyListTBL[i]["itemName"], candyListTBL[i]["nbt_hash"],
                candyListTBL[i]["itemDamage"], totalQtyItemInPlayerInventory)

            playersListTBL[userData_placeInTop]["totalScore"] = playersListTBL[userData_placeInTop]["totalScore"] +
                (totalQtyTaked * candyListTBL[i]["cost"])
        end

        drawScoreBoard()
        drawQtyCandys()

        local userData = getPlayerDataElement()
        authSystem:writeUserData(userData["userName"], userData)
        session = {}

        local name = authSystem:getPlayerName()
        -- local name = "3_1415926535"

        if name then
            authSystem:login(name)
        end
        main_loop()
    end)


    drawQtyCandys()
    while true do
        local signal = signalHandler()
        tabeCandyFromInvButton:onEvent(signal)
    end
end


function symbol(a,b,symbol,c,d,e,f)local g=gpu.set;local h={["a"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█▄▄▄█")g(a+1,b+2,"█   █")end,["b"]=function()g(a+1,b,"▄▄▄▄")g(a+1,b+1,"█▄▄█▄")g(a+1,b+2,"█▄▄▄█")end,["c"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█")g(a+1,b+2,"█▄▄▄▄")end,["d"]=function()g(a+1,b,"▄▄▄▄")g(a+1,b+1,"█   █")g(a+1,b+2,"█▄▄▄▀")end,["e"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█▄▄▄")g(a+1,b+2,"█▄▄▄▄")end,["f"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█▄▄")g(a+1,b+2,"█")end,["g"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█  ▄▄")g(a+1,b+2,"█▄▄▄█")end,["h"]=function()g(a+1,b,"▄   ▄")g(a+1,b+1,"█▄▄▄█")g(a+1,b+2,"█   █")end,["i"]=function()gpu.set(a+2,b,"▄▄▄")gpu.set(a+2,b+1," █")gpu.set(a+2,b+2,"▄█▄")end,["j"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"    █")g(a+1,b+2,"█▄▄▄█")end,["k"]=function()g(a+1,b,"▄  ▄")g(a+1,b+1,"█▄▀")g(a+1,b+2,"█ ▀▄")end,["l"]=function()g(a+1,b,"▄")g(a+1,b+1,"█")g(a+1,b+2,"█▄▄▄")end,["m"]=function()g(a+1,b,"▄   ▄")g(a+1,b+1,"█▀▄▀█")g(a+1,b+2,"█   █")end,["n"]=function()g(a+1,b,"▄▄  ▄")g(a+1,b+1,"█ █ █")g(a+1,b+2,"█  ▀█")end,["o"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█   █")g(a+1,b+2,"█▄▄▄█")end,["p"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█▄▄▄█")g(a+1,b+2,"█")end,["q"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█   █")g(a+1,b+2,"█▄▄██")end,["r"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█▄▄▄█")g(a+1,b+2,"█  ▀▄")end,["s"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"█▄▄▄▄")g(a+1,b+2,"▄▄▄▄█")end,["t"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1,"  █")g(a+1,b+2,"  █")end,["u"]=function()g(a+1,b,"▄   ▄")g(a+1,b+1,"█   █")g(a+1,b+2,"▀▄▄▄▀")end,["v"]=function()g(a+1,b,"▄   ▄")g(a+1,b+1,"█   █")g(a+1,b+2," ▀▄▀")end,["w"]=function()g(a+1,b,"▄   ▄")g(a+1,b+1,"█ █ █")g(a+1,b+2,"▀▄█▄▀")end,["x"]=function()g(a+1,b,"▄   ▄")g(a+1,b+1," ▀▄▀")g(a+1,b+2,"▄▀ ▀▄")end,["y"]=function()g(a+1,b,"▄   ▄")g(a+1,b+1," ▀▄▀ ")g(a+1,b+2,"  █")end,["z"]=function()g(a+1,b,"▄▄▄▄▄")g(a+1,b+1," ▄▄▄▀")g(a+1,b+2,"█▄▄▄▄")end}if e==true then gpu.setBackground(f)gpu.setForeground(f)gpu.set(a,b,"███████")gpu.set(a,b+1,"███████")gpu.set(a,b+2,"███████")gpu.set(a,b+3,"▀▀▀▀▀▀▀")end;gpu.setBackground(c)gpu.setForeground(d)h[unicode.lower(symbol)]()end

if not filesystem.exists("/playersData/") then
    filesystem.makeDirectory("/playersData/")
end

main_loop = function() 
    gpu.setResolution(resW, resH)
    guiFillColorBackground(greyColors[1])
    
    if pim_userName ~= "" then
        local userData = getPlayerDataElement()
        authSystem:writeUserData(userData["userName"], userData)
        pageNum = 1
        session = {}
    end
    
    local userData = authSystem:readUserData()

    local totalScoreAllUsers = 0

    for i = 1, #userData do

        totalScoreAllUsers = totalScoreAllUsers + userData[i]["totalScore"]
    end

    local strTotalScoreAllUsers = "[0xb4b4b4]Всего заработано сервером: [0x00dbf0]" .. tostring(totalScoreAllUsers) 

    gpuSetColorText(math.floor(math.abs(resW / 2 + 1 -
    unicode.len(strTotalScoreAllUsers:gsub('%[0x(%x%x%x%x%x%x)]', "")) / 2)), 13, strTotalScoreAllUsers, greyColors[1])

    pcall(function() table.sort(userData, function(a, b) return a.totalScore > b.totalScore end) end)

    for i = 1, #userData do
        gpuSetColorText(50, i + 15,
            i == 10 and "[0x00dbf0]" .. tostring(i) .. ". [0xdb5c01]" .. userData[i]["userName"] or
            "[0x00dbf0]" .. tostring(i) .. ".  [0xdb5c01]" .. userData[i]["userName"], greyColors[1])
        gpuSetColorText(93, i + 15, "[0x00dbf0]" .. userData[i]["totalScore"], greyColors[1])

        if i == 10 then break end
    end

    local halloween = "h a l l o w e e n"
    local xCord = 38

    for smb in halloween:gmatch("%S+") do  
        symbol(xCord, 6, smb, 0x1b1612, 0xdb5c01, true, 0x1b1612) 
        xCord = xCord + 8 
    end

        gpuSet(nil, resH - 13, "Встаньте на ПИМ и нажмите пкм по экрану!", greyColors[1], 0x99998f)
        
        drawPim()

        while true do
            sleep(0)
            local name = authSystem:getPlayerName()
            -- local name = "3_1415926535"

            if name then
                -- checkMeAvailable("main")
                 authSystem:login(name)
            end
        end
end

main_loop()
