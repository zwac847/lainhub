-- ZwacHub Main Loader
local base = "https://raw.githubusercontent.com/zwac847/lainhub/main/"

local function load(file)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(base .. file))()
    end)
    if not success then
        warn("[ZwacHub] Hata yüklenirken: " .. file .. " | " .. tostring(result))
    end
end

print("[ZwacHub] Yükleniyor...")

load("core.lua")
task.wait(0.3)
load("gui.lua")
task.wait(0.3)
load("systems.lua")

print("[ZwacHub] Tüm dosyalar yüklendi!")
