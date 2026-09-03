-- ZwacHub Main Loader
local base = "https://raw.githubusercontent.com/zwac847/lainhub/main/"

local function load(file)
    print("[ZwacHub] Yükleniyor: " .. file)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(base .. file))()
    end)
    if not success then
        warn("[ZwacHub] HATA → " .. file)
        warn(result)
    else
        print("[ZwacHub] Başarılı: " .. file)
    end
end

print("[ZwacHub] Başlatılıyor...")

load("core.lua")
task.wait(0.4)
load("gui.lua")
task.wait(0.4)
load("systems.lua")

print("[ZwacHub] Tüm dosyalar yüklendi!")
