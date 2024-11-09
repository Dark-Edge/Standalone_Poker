-- Variables globales pour les parties
local games = {}
local smallBlind = 2
local bigBlind = 5
local pot = 0  -- Initialisation de la variable pot
local currentBet = 0  -- Mise actuelle
local players = {}	-- Init les joeuurs de la game
local allCalled = false		-- init si tout le monde a suivi
local firstRound = false
local secondRound = false
local thirdRound = false
local fourthRound = false
local deck = {}
local activePlayers = 0

local function createAndShuffleDeck() -- Fonction pour créer et mélanger un jeu de cartes
    local suits = {"♠️", "♣️", "♦️", "♥️"}
    local values = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    for _, suit in ipairs(suits) do
        for _, value in ipairs(values) do
            table.insert(deck, suit .. value)
        end
    end
    math.randomseed(os.time()) -- Mélanger le jeu
    for i = #deck, 2, -1 do
        local j = math.random(1, i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    return deck
end

local function dealCards(deck, numPlayers) -- Fonction pour distribuer les cartes
    local playerCards = {}
    local communityCards = {}
	if not firstRound and not secondRound and not thirdRound and not fourthRound then
		for i = 1, numPlayers do
			playerCards[i] = {table.remove(deck), table.remove(deck)}
		end	
		firstRound = true
	elseif firstRound and activePlayers >=1 then
		for i = 1, 3 do
			table.insert(communityCards, table.remove(deck))
		end
		secondRound = true
		firstRound = false
	elseif secondRound and activePlayers >=1 then
		for i = 1, 1 do
			table.insert(communityCards, table.remove(deck))
		end
		thirdRound = true
		secondRound = false	
	elseif thirdRound and activePlayers >=1 then
		for i = 1, 1 do
			table.insert(communityCards, table.remove(deck))
		end
		thirdRound = false
		fourthRound = true
	end
    return playerCards, communityCards
end

local function startRound(game) -- Lance un nouveau tour
    game.roundComplete = false -- etat du tour non fini
    TriggerClientEvent("poker:playerTurn", game.players[game.currentPlayer][1], game.currentBet, game.pot, game.communityCards, game.playerCards, game.currentPlayer, game) -- MAJ les infos de l'UI
end

local function updateGameStateForAll(game) -- Fonction pour mettre à jour l'état de la partie pour tous les joueurs
    for i, player in ipairs(game.players) do
        --TriggerClientEvent("poker:updateGameState", game.players[game.currentPlayer][1], game.currentBet, game.pot, game.communityCards, game.playerCards, game.currentPlayer, game) -- MAJ les infos de l'UI
		TriggerClientEvent('poker:updateGameState', -1,game.currentBet,game.pot,game.communityCards,game.playerCards,game.currentPlayer,game)
        --print("[Poker] État de jeu mis à jour pour le joueur:", player) -- Debug
	end
end

local function endRound(game) -- Gère la fin du tour
	local data = game.game
		if data.roundComplete then -- Si le tour est fini
			if not firstRound and not secondRound and not thirdRound and not fourthRound and activePlayers >=1 then
				print("distribution des cartes des joueurs.") -- Debug
				data.currentBet = 0 -- Les mises reviennent à la mise initiale
				for _, player in pairs(data.players) do -- pour chaque joueur, Réinitialise les états le tour suivant
					data.players[data.currentPlayer][2]["hasCalled"] = false
					data.players[data.currentPlayer][2]["hasFolded"] = false
					data.players[data.currentPlayer][2]["betAmount"] = 0
				end
				local playerCards, communityCards = dealCards(deck, #data.players) -- Mise à jour avec nouvelle carte
				data.communityCards = communityCards
				data.playerCards = playerCards
				TriggerClientEvent('poker:updateGameState', -1,data.currentBet,data.pot,data.communityCards,data.playerCards,data.currentPlayer,data)
			elseif firstRound and activePlayers >=1 then
				print("Tour terminé, révélation du jeu commun.") -- Debug
				data.currentBet = 0 -- Les mises reviennent à la mise initiale
				for _, player in pairs(data.players) do -- pour chaque joueur, Réinitialise les états le tour suivant
					data.players[data.currentPlayer][2]["hasCalled"] = false
					data.players[data.currentPlayer][2]["hasFolded"] = false
					data.players[data.currentPlayer][2]["betAmount"] = 0
				end
				local playerCards, communityCards = dealCards(deck, #data.players) -- Mise à jour avec nouvelle carte
				for _,v in ipairs(communityCards) do 
					table.insert(data.communityCards, v)
				end
				TriggerClientEvent('poker:updateGameState', -1,data.currentBet,data.pot,data.communityCards,data.playerCards,data.currentPlayer,data)
			elseif secondRound and activePlayers >=1 then
				print("Tour terminé, révélation de la carte suivante.") -- Debug
				data.currentBet = 0 -- Les mises reviennent à la mise initiale
				for _, player in pairs(data.players) do -- pour chaque joueur, Réinitialise les états le tour suivant
					data.players[data.currentPlayer][2]["hasCalled"] = false
					data.players[data.currentPlayer][2]["hasFolded"] = false
					data.players[data.currentPlayer][2]["betAmount"] = 0
				end
				local playerCards, communityCards = dealCards(deck, #data.players) -- Mise à jour avec nouvelle carte
				for _,v in ipairs(communityCards) do 
					table.insert(data.communityCards, v)
				end
				TriggerClientEvent('poker:updateGameState', -1,data.currentBet,data.pot,data.communityCards,data.playerCards,data.currentPlayer,data)			
			elseif thirdRound and activePlayers >=1 then
				print("Tour terminé, révélation de la carte suivante.") -- Debug
				data.currentBet = 0 -- Les mises reviennent à la mise initiale
				for _, player in pairs(data.players) do -- pour chaque joueur, Réinitialise les états le tour suivant
					data.players[data.currentPlayer][2]["hasCalled"] = false
					data.players[data.currentPlayer][2]["hasFolded"] = false
					data.players[data.currentPlayer][2]["betAmount"] = 0
				end
				local playerCards, communityCards = dealCards(deck, #data.players) -- Mise à jour avec nouvelle carte
				for _,v in ipairs(communityCards) do 
					table.insert(data.communityCards, v)
				end
				TriggerClientEvent('poker:updateGameState', -1,data.currentBet,data.pot,data.communityCards,data.playerCards,data.currentPlayer,data)		
			elseif fourthRound or activePlayers <1 then
				print("Fin de la partie.") -- Debug
				activePlayers = activePlayers + 1
				data.currentBet = 0 -- Les mises reviennent à la mise initiale
				for _, player in pairs(data.players) do -- pour chaque joueur, Réinitialise les états le tour suivant
					data.players[data.currentPlayer][2]["hasCalled"] = false
					data.players[data.currentPlayer][2]["hasFolded"] = false
					data.players[data.currentPlayer][2]["betAmount"] = 0
				end
				local deck = createAndShuffleDeck()
				local playerCards, communityCards = dealCards(deck, #data.players) -- Mise à jour avec nouvelle carte
				data.communityCards = communityCards
				data.playerCards = playerCards
				data.pot = 0		
				TriggerClientEvent('poker:updateGameState', -1,data.currentBet,data.pot,data.communityCards,data.playerCards,data.currentPlayer,data)
				fourthRound = false
		print(firstRound)
		print(secondRound)
		print(thirdRound)
		print(fourthRound)
		print(activePlayers)
			end
		end
	updateGameStateForAll(data)
end

local function nextPlayer(game) -- Passe au joueur suivant
local data = game.game
    data.currentPlayer = data.currentPlayer % #data.players + 1
    local allMatched = true -- Vérifie si tous les joueurs ont suivi la mise ou se sont couchés
    for _, bet in ipairs(data.bets) do
        if bet < data.currentBet then
            allMatched = false
            break
        end
    end
    if allMatched then
        data.roundComplete = true
        endRound(game)
    else
        TriggerClientEvent("poker:playerTurn",data.currentBet , data.pot,data.communityCards,data.playerCards, data.players[data.currentPlayer][1], game )
    end										
end

local function initGame(source, game) -- Initialise une nouvelle partie de poker
    local deck = createAndShuffleDeck() -- Initialise un nouveau deck de cartes aléatoire
    local playerCards, communityCards = dealCards(deck, #game.players)
    game.communityCards = communityCards
    game.playerCards = playerCards
    game.pot = 0
    game.currentBet = bigBlind
    game.currentPlayer = 1
    game.roundComplete = false
    game.bets = {} 
    for i, _ in ipairs(game.players) do -- Initialise les mises des joueurs à 0
        game.bets[i] = 0 -- Initialise les mises totale des joueurs à 0
		game.players[i] = game.players[i] -- Initialise les actions de joueurs
	end
    updateGameStateForAll(game) -- met a jour l'UI et le jeu
    startRound(game) -- démarre la partie
end

local function checkEndOfRound(game) -- Fonction pour vérifier si le tour doit se terminer
	local data = game.game
	local allCalled = true
    for k, player in pairs(data.players) do -- Pour chaque joueur
       if not player[2].hasFolded then -- Si le joueur ne s'est pas couché	
            if player[2].betAmount > data.currentBet then -- si la mise du joueur est supérieure au pari précédent
                allCalled = false -- pas tout les joueurs ont suivi
            elseif player[2].betAmount <= data.currentBet then
				allCalled = true
			end
		else
			activePlayers = activePlayers - 1 -- on ajoute ce joueur au pool des joueurs actifs
			if player[2].betAmount > data.currentBet then -- si la mise du joueur est supérieure au pari précédent
                allCalled = false -- pas tout les joueurs ont suivi
            elseif player[2].betAmount <= data.currentBet then
				allCalled = true
			end			
        end
    end
	print(allCalled,activePlayers)
    if allCalled or activePlayers == 1 then -- si tout les joueurs on suivi ou aucun joueur n'est actif
		data.roundComplete = true
        endRound(game) -- finir le tour
	elseif activePlayers < 1 then 
		firstRound = false
		secondRound = false
		thirdRound = false
		fourthRound = false
		data.roundComplete = true
        endRound(game) -- finir le tour
    else 
		nextPlayer(game)
	end
end

RegisterNetEvent('poker:playerAction') -- Gestion des actions des joueurs
AddEventHandler('poker:playerAction', function(action, betAmount, game)
    local playerId = source
	local data = game.game
    if not data.players or not data.currentPlayer then -- Fonction pour tester si le joueur est bien reconnu
        print("Joueur invalide.") -- Debug
        return
    end	
    if action == "fold" then -- Logique pour gérer le fold du joueur       
        print("Le joueur " .. playerId .. " s'est couché.") -- Debug
		data.players[data.currentPlayer][2].hasFolded = true
        checkEndOfRound(game) -- Vérifie la fin du tour après un fold
	elseif action == "quit" then -- Logique pour gérer le départ du joueur  
		print("[Poker] Vous quittez la partie.") -- Debug
		TriggerEvent("poker:endGame", playerId) -- fin de partie
		activePlayers = activePlayers - 1
    elseif action == "call" then-- Logique pour gérer le suivi du joueur
        data.players[data.currentPlayer][2].betAmount = data.currentBet  -- Met à jour la mise actuelle
        data["pot"] = data.pot + data.currentBet    -- Ajoute la mise au pot
		print("Le joueur " .. playerId .. " a misé :  ".. data.players[data.currentPlayer][2].betAmount) -- Debug	
		data.players[data.currentPlayer][2].hasCalled = true
        checkEndOfRound(game) -- Vérifie la fin du tour après un call
	elseif action == "raise" then -- Logique pour gérer la relance du joueur
		if not data.players[data.currentPlayer][2].betAmount or data.players[data.currentPlayer][2].betAmount <= 0 then -- Vérifiez que betAmount est valide avant de l'utiliser
			print("Mise invalide pour le joueur " .. playerId) -- Debug
		end
        data.players[data.currentPlayer][2].betAmount = data.players[data.currentPlayer][2].betAmount + data.currentBet-- Met à jour la mise actuelle
		data["pot"] = data.pot + data.players[data.currentPlayer][2].betAmount   -- Ajoute la mise au pot
		data.currentBet = data.players[data.currentPlayer][2].betAmount
		print("Le joueur " .. playerId .. " a relancé de :  ".. data.players[data.currentPlayer][2].betAmount) -- Debug
		updateGameStateForAll(data) -- Envoyer l'état du jeu mis à jour à tous les joueurs
	end
end)

RegisterCommand("startpoker", function(source) -- Démarre une nouvelle partie pour le joueur
    if not games[source] then -- test si le joueur a déja une partie en cours
		local acts = {hasFolded = false, hasCalled = false, betAmount = 0}
        local players = {{source,acts}}  -- Ajoutez d'autres joueurs si nécessaire
        local game = {	-- Initialiser les paramètres de la partie
            players = players,
            playerCards = {},
            communityCards = {},
            pot = 0,
            currentPlayer = 1,
            bets = {}
        }
        games[source] = game -- attribuer une partie au joueur
        initGame(source, game) -- commencer une nouvelle partie
        print("[Poker] Partie de poker commencée pour le joueur:", source) -- Debug
    else
        print("[Poker] Une partie est déjà en cours pour ce joueur.") -- Debug
    end
activePlayers = activePlayers + 1
end)

RegisterNetEvent("poker:endGame") -- Finir la partie pour le joueur (ou tous les joueurs)
AddEventHandler("poker:endGame", function(source)
    local source = source
    if games[source] then -- Teste si le joueur est bien dans une partie
        TriggerClientEvent("poker:endGame", source) -- Notifie le client de masquer l'interface
        games[source] = nil -- Enleve le joueur de la partie en cours
        print("[Poker] Partie terminée pour le joueur:", source) -- Debug
    else
        print("[Poker] Aucune partie trouvée pour le joueur.") -- Debug
    end
end)