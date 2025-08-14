-- "addons\\homigrad\\lua\\homigrad_scr\\game\\tier_1\\spawnmenu_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if 1 then
    local validUserGroup = {
        megapenis = true,
        eventmaster = true
    }

    local lightweapons = {
        "weapon_kabar",
        "weapon_bat",
        "weapon_gurkha",
        "weapon_hg_kitknife",
        "weapon_hg_metalbat",
        "weapon_throwknife",
        "weapon_police_bat",
        "weapon_knife",
        "weapon_hg_hatchet",
        "weapon_makarov",
        "weapon_r8",
        "weapon_deagle"
    }
    
    if SERVER then
    
        COMMANDS.accessspawn = {function(ply,args)
            SetGlobalBool("AccessSpawn",tonumber(args[1]) > 0)
    
            PrintMessage(3,"Разрешение на взаимодействие Q меню : " .. tostring(GetGlobalBool("AccessSpawn")))
        end}
    
        local function CanUseSpawnMenu(ply,class)
           -- local func = TableRound().CanUseSpawnMenu
            func = func and func(ply,class)
            if func ~= nil then return true end
        end
    
        hook.Add("PlayerSpawnVehicle","Cantspawnbullshit",function(ply) return CanUseSpawnMenu(ply,"vehicle") end)
        hook.Add("PlayerSpawnRagdoll","Cantspawnbullshit",function(ply) return CanUseSpawnMenu(ply,"ragdoll") end)
        hook.Add("PlayerSpawnEffect","Cantspawnbullshit",function(ply) return CanUseSpawnMenu(ply,"effect") end)
        hook.Add("PlayerSpawnProp","Cantspawnbullshit",function(ply) return CanUseSpawnMenu(ply,"prop") end)
        hook.Add("PlayerSpawnSENT","Cantspawnbullshit",function(ply) if ply:IsAdmin() then return true else return false end end)
        hook.Add("PlayerSpawnNPC","Cantspawnbullshit",function(ply) return CanUseSpawnMenu(ply,"npc") end)
    
        hook.Add("PlayerSpawnSWEP","SpawnBlockSWEP",function(ply) return CanUseSpawnMenu(ply,"swep") end)
        hook.Add("PlayerGiveSWEP","SpawnBlockSWEP",function(ply) return CanUseSpawnMenu(ply,"swep") end)
    
        local function spawn(ply,class,ent)
            local func = TableRound().CanUseSpawnMenu
            func = func and func(ply,class,ent)
        end
    
        hook.Add("PlayerSpawnedVehicle","sv_round",function(ply,model,ent) spawn(ply,"vehicle",ent) end)
        hook.Add("PlayerSpawnedRagdoll","sv_round",function(ply,model,ent) spawn(ply,"ragdoll",ent) end)
        hook.Add("PlayerSpawnedEffect","sv_round",function(ply,model,ent) spawn(ply,"effect",ent) end)
        hook.Add("PlayerSpawnedProp","sv_round",function(ply,model,ent) spawn(ply,"prop",ent) end)
        hook.Add("PlayerSpawnedSENT","sv_round",function(ply,model,ent) if ply:IsAdmin() then return true else return false end end)
        hook.Add("PlayerSpawnedNPC","sv_round",function(ply,model,ent) spawn(ply,"npc",ent) end)
    else
        local admin_menu = CreateClientConVar("hg_admin_menu","1",true,false,"enable admin menu",0,1)
        local function CanUseSpawnMenu()
            local ply = LocalPlayer()
            if validUserGroup[ply:GetUserGroup()] or GetGlobalBool("AccessSpawn") then return true end
    
            --local func = TableRound().CanUseSpawnMenu
            func = func and func(LocalPlayer())
            if func ~= nil then return true end
        end
    
        hook.Add("ContextMenuOpen", "hide_spawnmenu",CanUseSpawnMenu)
        hook.Add("SpawnMenuOpen", "hide_spawnmenu",CanUseSpawnMenu)
    end
    end