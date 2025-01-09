local display = false -- El NUI comienza apagado
local isMeterRunning = false
local fare = 0.0
local distance = 0.0
local fareRate = 1.5  -- Tarifa por kilómetro

-- Comando para mostrar/ocultar el taxímetro
RegisterCommand("taximeter", function()
    display = not display
    if display then
        SetNuiFocus(true, true) 
    else
        SetNuiFocus(false, false)
    end
    SendNUIMessage({
        type = "ui",
        status = display -- Envía el estado actual del NUI
    })
end)

-- Callback del NUI (cuando el usuario interactúa desde la interfaz)
RegisterNUICallback("close", function(data, cb)
    display = false -- Apaga el NUI
    SetNuiFocus(false, false) -- Desactiva el control del mouse y teclado
    SendNUIMessage({
        type = "ui",
        status = false -- Oculta el NUI
    })
    cb("ok")
end)

-- Comando para iniciar el taxímetro
RegisterCommand("start_meter", function()
    if not isMeterRunning then
        isMeterRunning = true
        Citizen.CreateThread(function()
            while isMeterRunning do
                distance = distance + 0.1  -- Incrementa la distancia
                fare = distance * fareRate  -- Calcula la tarifa
                SendNUIMessage({
                    type = "update",
                    fare = fare,
                    distance = distance
                })
                Citizen.Wait(1000)  -- Actualiza cada segundo
            end
        end)
    end
end)

-- Comando para detener el taxímetro
RegisterCommand("stop_meter", function()
    isMeterRunning = false  -- Detiene el taxímetro
end)

-- Comando para reiniciar el taxímetro
RegisterCommand("reset_meter", function()
    fare = 0.0
    distance = 0.0
    SendNUIMessage({
        type = "update",
        fare = fare,
        distance = distance
    })
end)
