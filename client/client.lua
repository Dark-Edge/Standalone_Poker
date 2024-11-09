local inPokerGame = false

-- Initialise l'interface de jeu pour le joueur
RegisterNetEvent("poker:playerTurn")
AddEventHandler("poker:playerTurn", function(currentBet, pot, communityCards, playerCards, source, game)
    SendNUIMessage({ type = "show", currentBet = currentBet, pot = pot, communityCards = communityCards, playerCards = playerCards[source], source = source, game = game })
    SetNuiFocus(true, true)
end)

-- Masque l'interface de jeu lorsque le tour est terminé
RegisterNetEvent("poker:endRound")
AddEventHandler("poker:endRound", function()
    SendNUIMessage({ type = "hide" })
    SetNuiFocus(false, false)
end)

-- Mise à jour de l'interface utilisateur avec l'état du jeu
RegisterNetEvent("poker:updateGameState")
AddEventHandler("poker:updateGameState", function(currentBet, pot, communityCards, playerCards, source, game)
SendNUIMessage({ type = "show", currentBet = currentBet, pot = pot, communityCards = communityCards, playerCards = playerCards[source], source = source, game = game })
end)

-- Gère les actions envoyées depuis l'interface NUI
RegisterNUICallback("playerAction", function(data, betAmount)
    local action = data.action
    local betAmount = tonumber(data.betAmount)
	data.game.players[data.game.currentPlayer][2].betAmount = betAmount
    TriggerServerEvent("poker:playerAction", action, betAmount, data)
end)

-- Fin de la partie de poker
RegisterNetEvent("poker:endGame")
AddEventHandler("poker:endGame", function()
    inPokerGame = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "hide" })
    print("[Poker] Partie terminée côté client") -- Debug
end)