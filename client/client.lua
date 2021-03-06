ESX = nil
local PlayerData = {}

CreateThread(function() while ESX == nil do 
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Wait(0) end
    while ESX.GetPlayerData().job == nil do Wait(10) end
    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

CreateThread(function() while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Wait(0) end
end)

CreateThread(function() while true do
    local sleep = 5000
    local _source = source
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    for i = 1, #Config.Doktori, 1 do
        local doctor = Config.Doktori[i]
        local userDst = GetDistanceBetweenCoords(pedCoords, doctor.x, doctor.y, doctor.z, true)

        if userDst <= 15 then
            sleep = 2
            if userDst <= 5 then
                DrawText3D(doctor.x, doctor.y, doctor.z, 'Pritisnite [E] Da se ozivite $'.. Config.cjenaDoktora)
                DrawMarker(20, doctor.x, doctor.y, doctor.z-0.100, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 195, 18, 100, false, true, 2, false, false, false, false)
                if userDst <= 1.5 then
                if IsControlJustPressed(0, 38) then
                      ESX.TriggerServerCallback('premium:gettajMedikale', function(cb)
                            canEms = cb
                        end, i)
                        while canEms == nil do
                                Wait(0)
                            end
                            if Config.DoktoriLimit then
                                if canEms == true then
                                    
                                    ESX.TriggerServerCallback('premium-doctor:kontrola', function(hasEnoughMoney)
                                        if hasEnoughMoney then
                                            local formattedCoords = {
                                                x = ESX.Math.Round(pedCoords.x, 1),
                                                y = ESX.Math.Round(pedCoords.y, 1),
                                                z = ESX.Math.Round(pedCoords.z, 1)
                                            }
                                            TriggerEvent('esx_ambulancejob:revive', formattedCoords)
                                            TriggerServerEvent('premium-doctor:novac')
                                        else
                                            exports['mythic_notify']:DoHudText('error', 'Nemate dovoljno novca!')
                                        end
                                    end)

                                elseif canEms == 'no_ems' then
                                    exports['mythic_notify']:DoHudText('error', 'U gradu ima dovoljno Doktora da vas ljece !')                          
                                end 
                            else
                                ESX.TriggerServerCallback('premium-doctor:kontrola', function(hasEnoughMoney)
                                    if hasEnoughMoney then
                                        local formattedCoords = {
                                            x = ESX.Math.Round(pedCoords.x, 1),
                                            y = ESX.Math.Round(pedCoords.y, 1),
                                            z = ESX.Math.Round(pedCoords.z, 1)
                                        }
                                        TriggerEvent('esx_ambulancejob:revive', formattedCoords)
                                        TriggerServerEvent('premium-doctor:novac')
                                    else
                                        exports['mythic_notify']:DoHudText('error', 'Nemate dovoljno novca.!')
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function DrawText3D(x,y,z,text,size)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

CreateThread(function()
    RequestModel(GetHashKey("s_m_m_doctor_01"))
    while not HasModelLoaded(GetHashKey("s_m_m_doctor_01")) do
        Wait(1)
    end
	if Config.UkljuciPedove then
        for _, doctor in pairs(Config.Doktori) do
			local npc = CreatePed(4, 0xD47303AC, doctor.x, doctor.y, doctor.z-1.0, doctor.heading, false, true)
			SetEntityHeading(npc, doctor.heading)
			FreezeEntityPosition(npc, true)
			SetEntityInvincible(npc, true)
			SetBlockingOfNonTemporaryEvents(npc, true)
		end
	end
end)

CreateThread(function()
    if Config.UkljuciBlipove then
        for k,v in pairs(Config.Doktori) do
            local blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite (blip, 403)
            SetBlipDisplay(blip, 2)
            SetBlipScale  (blip, 1.0)
            SetBlipColour (blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Bolnicar')
            EndTextCommandSetBlipName(blip)
        end
    end
end)
