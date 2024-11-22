-- Exports
local QBCore = exports['qb-core']:GetCoreObject()
local jacket_var = -1
local shirt_var = -1
local arms_var =  -1
local pants_var =  -1
local feet_var = -1
local mask_var = -1
local vest_var = -1
local hair_var = -1
local hat_prop = -1
local glass_prop = -1
local pickedupDrugs = false
local JobStarted = false
local drugsPickedUp = false
local cutsceneCoords = vector3(-1025.4, 694.62, 161.27)


-- Admin Menu

RegisterCommand('admin_fjern', function (source, args, raw)
    local options = {}
    QBCore.Functions.TriggerCallback('nt_drugdelivery_getcoords_all', function(result)
        for _, row in ipairs(result) do
            local option = {
                title = "ID: "..row.id,
                icon = 'fa-solid fa-trash',
                description = "\nTryk for at fjerne.\nX: "..row.x.."\nY: "..row.y.."\nZ: "..row.z,
                onSelect = function()
                    QBCore.Functions.TriggerCallback('nt_druglocation_remove', function (result)
                        if result then
                            lib.notify({
                                title = 'System - Fjernet',
                                description = 'Du har fjernet location: '.. row.id,
                                type = 'success'
                            })
                        else
                            lib.notify({
                                title = 'System - ERROR',
                                description = 'Der er en fejl!',
                                type = 'error'
                            })
                        end
                    end, row.id)
                end,
            }
            table.insert(options, option)
            lib.registerContext({
                id = 'nt_druglocation_admin_database',
                title = 'Admin - Location',
                options = options
            })
        end
        lib.showContext('nt_druglocation_admin_database')
    end, result)
end)

-- Cutsceen


function cutscene()
    blip2 = CreateJobBlip2(cutsceneCoords)
    CreateThread(function()
        while true do
            Wait(500)
            if pickedupDrugs then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)


            local distance = #(playerCoords - cutsceneCoords)
            if distance <= 10 and not JobStarted then
                JobStarted = true
                QBCore.Functions.TriggerCallback('nt_drugdelivery_checks_task', function(result)
                    if result then
                        PlayCutscene(Config.Cutscenes["1"])
                        QBCore.Functions.TriggerCallback('nt_drugdelivery_task_completed', function(result)
                        end, result)
                        TriggerServerEvent('nt_drugdelivery_deliverd')
                        RemoveBlip(blip2)
                    else
                        PlayCutscene(Config.Cutscenes["2"])
                        TriggerServerEvent('nt_drugdelivery_deliverd')
                        RemoveBlip(blip2)
                    end
                end, result)
            elseif distance > 10 and JobStarted then
                JobStarted = false
                pickedupDrugs = false
                drugsPickedUp = false
                end
            end
        end
    end)
end

-- Debug Commands
RegisterCommand('testcutscene', function (source, args, raw)
	if Config.Debug then
    		cutscene()
    		drugsPickedUp = true
    		pickedupDrugs = true
    end
end)
RegisterCommand('testpakke', function (source, args, raw)
	if Config.Debug then
    QBCore.Functions.TriggerCallback('nt_drugdelivery_getcoords', function(result)
        CreatePakke(result[1].x,result[1].y,result[1].z)
    end, result)
    end
end)


function startDrugDelivery()
    QBCore.Functions.TriggerCallback('nt_drugdelivery_checksplayer', function(result)
        if result ~= true then
            QBCore.Functions.TriggerCallback('nt_drugdelivery_addplayer', function()
                QBCore.Functions.TriggerCallback('nt_drugdelivery_getcoords', function(result)
                    CreatePakke(result[1].x,result[1].y,result[1].z)
                end, result)
            end)
        else
            QBCore.Functions.TriggerCallback('nt_drugdelivery_getcoords', function(result)
                CreatePakke(result[1].x,result[1].y,result[1].z)
            end, result)
        end
    end, result)
end


-- Job Blip
function CreateJobBlip2(x,y,z)
	local blip = AddBlipForCoord(x,y,z)
	SetBlipSprite(blip, 51)
	SetBlipColour(blip, 2)
	AddTextEntry('MYBLIP', "Aflever Stoffer")
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.75)
	SetBlipAsShortRange(blip, true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, 2)
	return blip
end

function CreateJobBlip(x,y,z)
	local blip = AddBlipForCoord(x,y,z)
	SetBlipSprite(blip, 51)
	SetBlipColour(blip, 2)
	AddTextEntry('MYBLIP', "Pakke Stoffer")
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.75)
	SetBlipAsShortRange(blip, true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, 2)
	return blip
end

-- Opretter drug pakke 
function CreatePakke(x,y,z)
    local pakke = CreateObject(Config.Prop, x,y,z -1, true, true, 1)
    local blip = CreateJobBlip(vec3(x,y,z))
    SetEntityAsMissionEntity(pakke, 1,1)
    lib.notify({
        title = 'Martin',
        description = 'Jeg har sat en GPS til det sted hvor du skal samle stofferne.',
        type = 'information'
    })
    CreateThread(function()
        while true do
            Wait(0)
            if drugsPickedUp ~= true then
                dis = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), x,y,z, false)
                if not IsPedInAnyVehicle(PlayerPedId()) then
                    if dis <= 10 and dis >= 2.0 then
                        DrawMarker(20, x,y,z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 52, 103, 235, 100, false, true, 2, false, false, false, false)
                        lib.hideTextUI()
                    elseif dis <= 2.0 then
                        lib.showTextUI('Tag Pakken', {
                            icon = 'hand'
                        })
                        if IsControlJustPressed(0, 38) then
                            RemoveBlip(blip)
                            pickupPackage()
                            Wait(600)
                            DeleteEntity(pakke)
                            lib.hideTextUI()
                            drugsPickedUp = true
                            pickedupDrugs = true
                            lib.notify({
                                title = 'Martin',
                                description = 'Jeg har sat en GPS til det sted hvor du skal aflevere stofferne.',
                                type = 'information'
                            })
                            cutscene()
                        end
                    end
                end
            end
        end
    end)
end

-- Pickup Pakage
function pickupPackage()
    loadAnimDict('pickup_object')
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'pickup_low',5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
    tjekket = false
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end


-- Cutscene Settings
function SaveCloth()
    local ped = PlayerPedId()

    jacket_var = GetPedDrawableVariation(ped, 11)
    shirt_var = GetPedDrawableVariation(ped, 8)
    arms_var = GetPedDrawableVariation(ped, 3)
    pants_var = GetPedDrawableVariation(ped, 4)
    feet_var = GetPedDrawableVariation(ped, 6)
    mask_var = GetPedDrawableVariation(ped, 1)
    vest_var = GetPedDrawableVariation(ped, 9)
    hair_var = GetPedDrawableVariation(ped, 2)
    hat_prop = GetPedPropIndex(ped, 0)
    glass_prop = GetPedPropIndex(ped, 1)

    
    jacket_tex = GetPedTextureVariation(ped, 11)
    shirt_tex = GetPedTextureVariation(ped, 8)
    arms_tex = GetPedTextureVariation(ped, 3)
    pants_tex = GetPedTextureVariation(ped, 4)
    feet_tex = GetPedTextureVariation(ped, 6)
    mask_tex = GetPedTextureVariation(ped, 1)
    vest_tex = GetPedTextureVariation(ped, 9)
    hair_tex = GetPedTextureVariation(ped, 2)
    hat_tex = GetPedPropTextureIndex(ped, 0)
    glass_tex = GetPedPropTextureIndex(ped, 1)

    
    jacket_pal = GetPedPaletteVariation(ped, 11)
    shirt_pal = GetPedPaletteVariation(ped, 8)
    arms_pal = GetPedPaletteVariation(ped, 3)
    pants_pal = GetPedPaletteVariation(ped, 4)
    feet_pal = GetPedPaletteVariation(ped, 6)
    mask_pal = GetPedPaletteVariation(ped, 1)
    vest_pal = GetPedPaletteVariation(ped, 9)
    hair_pal = GetPedPaletteVariation(ped, 2)
end

function PlayCutscene(cutscene)
    local ped = PlayerPedId()

    SaveCloth()
    RequestCutscene(cutscene, 8)

    while not (HasCutsceneLoaded()) do
        Wait(0)
        RequestCutscene(cutscene, 8)
    end

    SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
    RegisterEntityForCutscene(PlayerPedId(-1), 'MP_1', 0, 0, 64)
    SetCutsceneEntityStreamingFlags('MP_2',0,1)
    SetCutsceneEntityStreamingFlags('MP_3',0,1)
    SetCutsceneEntityStreamingFlags('MP_4',0,1)
    RegisterEntityForCutscene(0, 'MP_2', 3, GetHashKey('mp_f_freemode_01'), 0)
    RegisterEntityForCutscene(0, 'MP_3', 3, GetHashKey('mp_f_freemode_01'), 0)
    RegisterEntityForCutscene(0, 'MP_4', 3, GetHashKey('mp_f_freemode_01'), 0)

    StartCutscene(0)
    DoScreenFadeIn(0)

    while not (DoesCutsceneEntityExist('MP_1', 0)) do
        Wait(0)
    end

    SetCutscenePedComponentVariationFromPed(PlayerPedId(), ped, GetHashKey('mp_m_freemode_01'))
    SetPedComponentVariation(ped, 11, jacket_var, jacket_tex, jacket_pal)
    SetPedComponentVariation(ped, 8, shirt_var, shirt_tex, shirt_pal)
    SetPedComponentVariation(ped, 3, arms_var, arms_tex, arms_pal)
    SetPedComponentVariation(ped, 4, pants_var, pants_tex,pants_pal)
    SetPedComponentVariation(ped, 6, feet_var, feet_tex,feet_pal)
    SetPedComponentVariation(ped, 1, mask_var, mask_tex,mask_pal)
    SetPedComponentVariation(ped, 9, vest_var, vest_tex,vest_pal)
    SetPedComponentVariation(ped, 2, hair_var, hair_tex,hair_pal)
    SetPedPropIndex(ped, 2, hair_var,  hair_tex, hair_pal)
    SetPedPropIndex(ped, 0, hat_prop, hat_tex, 0)
    SetPedPropIndex(ped, 1, glass_prop, glass_tex, -1)

    while not (HasCutsceneFinished()) do
        Wait(0)
    end
    tjekket = false
end

CreateThread(function()
    local boss = Config.NpcData
    local animation
    if boss.Animation then
        animation = boss.Animation
    else
        animation = "WORLD_HUMAN_STAND_IMPATIENT"
    end
    
    RequestModel(boss.Model)
    while not HasModelLoaded(boss.Model) do
        Wait(1)
    end
    
    local options = {}
    local option = { 
        type = "client",
        event = "",
        icon = "fas fa-circle",
        label = "Hent stoffer - Martin",
        action = function()
            startDrugDelivery()
        end,
    }
    table.insert(options, option)

    exports['qb-target']:SpawnPed({
        model = boss.Model,
        coords = boss.Coords,
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = animation,
        target = {
            options = options,
            distance = 1.0
        },
        spawnNow = true,
    })
end)
