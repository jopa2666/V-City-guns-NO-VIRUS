-- "addons\\homigrad\\lua\\homigrad_scr\\game\\tier_1\\cl_hudtarget.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if not 1 then return end
nodraw_players = nodraw_players or {}

local pressedalredi = false

hook.Add("Think","ShouldDrawNoclipe",function()
	local lply = LocalPlayer()

	for i,ply in pairs(player.GetAll()) do
		if ply == lply then continue end

		if ply:GetNWBool("scared") or (ply:Alive() and not ply:InVehicle() and ply:GetMoveType() == MOVETYPE_NOCLIP) then
			ply:SetNoDraw(true)
			for i,wep in pairs(ply:GetWeapons()) do wep:SetNoDraw(true) end
			nodraw_players[ply] = true
		elseif nodraw_players[ply] then
			ply:SetNoDraw(false)
			for i,wep in pairs(ply:GetWeapons()) do wep:SetNoDraw(false) end
			nodraw_players[ply] = nil
		end
	end
end)

hook.Add("DrawPhysgunBeam","gg",function(ply)
	if nodraw_players[ply] then return false end
end)

local red = Color(125,0,0)

local hg_customname = CreateClientConVar("hg_customname","",true)

cvars.AddChangeCallback("hg_customname",function(_,_,value)
    net.Start("custom name")
	net.WriteString(value)
	net.SendToServer()
end)

net.Start("custom name")
net.WriteString(hg_customname:GetString())
net.SendToServer()

hook.Add("HUDPaint","homigrad-huynyui",function()
	local lply = LocalPlayer()

	if not lply:Alive() then return end
	
	if roundActiveName == "zombieinfection" then
		local text

		local ply = lply
		local t = {}
		local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
		
		t.start = eye and eye.Pos or ply:EyePos()
		t.endpos = t.start + ply:GetAngles():Forward() * 60
		t.filter = lply
		local Tr = util.TraceLine(t)

		local Size = math.Clamp(1 - ((Tr.HitPos -lply:GetShootPos()):Length() / 60) ^ 2, .1, .3)

		local ent = Tr.Entity
 
	if IsValid(ent) then
		if ent:GetClass() == "player" then
		if IsValid(lply:GetActiveWeapon()) and lply:GetActiveWeapon():GetClass() != "weapon_hands" then
			surface.SetDrawColor(Color(255, 255, 255, 255 * Size/0.5))
			Circle(Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y, 105 * Size, 32)
			Circle(Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y, 75 * Size, 32)
		end
		if ply:KeyPressed(IN_USE) and not pressedalredi and not ent:GetNWBool("InTeam") then
			pressedalredi = true
			ply:ChatPrint(ent:Name().." Приглашён в команду")
			timer.Simple(0.5,function ()
				pressedalredi = false
			end)
			net.Start("InvitePlayer")
			net.WriteEntity(ply)
			net.WriteEntity(ent)
			net.SendToServer()
		end
		if ent:GetNWBool("InTeam") then return end
		draw.DrawText("Пригласить "..ent:Name().." в команду.","HomigradFont",Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y + 135, Color(255,255,255), TEXT_ALIGN_CENTER )
		end
	end
	end

	if IsValid(lply:GetActiveWeapon()) and lply:GetActiveWeapon():GetClass() != "weapon_hands" then
		local ply = lply
		local t = {}
		local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
		
		t.start = eye and eye.Pos or ply:EyePos()
		t.endpos = t.start + ply:GetAngles():Forward() * 60
		t.filter = lply
		local Tr = util.TraceLine(t)

		local Size = math.Clamp(1 - ((Tr.HitPos -lply:GetShootPos()):Length() / 60) ^ 2, .1, .3)

		local ent = Tr.Entity

		local col
		if ent:IsPlayer() then
			col = ent:GetPlayerColor():ToColor()
		elseif ent.GetPlayerColor ~= nil then
			col = ent.playerColor:ToColor()
		else
			return
		end

		if nodraw_players[Tr.Entity] then
			if math.random(1,25) == 25 then
				draw.DrawText(string.rep("?",math.random(1,4)) .. "you scared me" .. string.rep("?",math.random(1,4)),"DefaultFixedDropShadow",Tr.HitPos:ToScreen().x + math.random(-125,125),Tr.HitPos:ToScreen().y + math.random(-125,125), red, TEXT_ALIGN_CENTER )

				local head = Tr.Entity:GetBonePosition(Tr.Entity:LookupBone("ValveBiped.Bip01_Head1"))
				head = head:ToScreen()

				draw.DrawText(string.rep("c",math.random(1,12)) .. ":","DefaultFixedDropShadow",head.x + math.random(-25,25),head.y + math.random(-25,25), red, TEXT_ALIGN_CENTER )
			end

			return
		end

		col.a = 255 * Size * 2
		draw.DrawText(ent:GetNWString("Nickname",false) or (ent:IsPlayer() and ent:Name()) or "", "HomigradFontLarge", Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y + 30, col, TEXT_ALIGN_CENTER )
	end
end)