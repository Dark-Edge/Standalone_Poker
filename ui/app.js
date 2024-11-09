let game

// Fonction pour mettre à jour l'affichage des cartes dans l'interface utilisateur
function updateCards(communityCards, playerCards) {
    const communityCardContainer = document.getElementById("community-card-container");
    communityCardContainer.innerHTML = "";

    // Vérifiez si communityCards est un tableau et s'il n'est pas vide
    if (Array.isArray(communityCards) && communityCards.length > 0) {
        communityCards.forEach(card => {
            const cardElement = document.createElement("div");
            cardElement.className = "card";
            cardElement.innerText = card;
            communityCardContainer.appendChild(cardElement);
        });
    } else {
        const noCardElement = document.createElement("div");
        noCardElement.innerText = "Aucune carte commune";
        communityCardContainer.appendChild(noCardElement);
    }

    const playerCardContainer = document.getElementById("player-card-container");
    playerCardContainer.innerHTML = "";

    // Vérifiez si playerCards est un tableau et s'il n'est pas vide
    if (Array.isArray(playerCards) && playerCards.length > 0) {
        playerCards.forEach(card => {
            const cardElement = document.createElement("div");
            cardElement.className = "card";
            cardElement.innerText = card;
            playerCardContainer.appendChild(cardElement);
        });
    } else {
        const noCardElement = document.createElement("div");
        noCardElement.innerText = "Aucune carte du joueur";
        playerCardContainer.appendChild(noCardElement);
    }
}

// Écoute les messages envoyés par le serveur
window.addEventListener("message", (event) => {
    if (event.data.type === "show") {
			let data = event.data
			game = data.game
			document.getElementById("poker-game").classList.remove("hidden");
			document.getElementById("current-bet").innerText = event.data.currentBet;
			document.getElementById("pot-amount").innerText = event.data.pot;
		    document.getElementById("call").innerText = `Suivre (${event.data.currentBet})`;
			document.getElementById("raise").innerText = `Relancer (${document.getElementById("current-bet").innerText}+${document.getElementById("bet-amount").value})`;
			updateCards(event.data.communityCards, event.data.playerCards);		
    }else if (event.data.type === "hide") {
			document.getElementById("poker-game").classList.add("hidden");
    }
});

// Envoie une action de joueur au serveur
function playerAction(action) {
	const betAmount = parseInt(document.getElementById("bet-amount").value);
    fetch(`https://${GetParentResourceName()}/playerAction`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: action, game : game, betAmount: betAmount })
    });
}

// Fonction pour gérer la relance
function raise() {
    const betAmount = parseInt(document.getElementById("bet-amount").value);
    if (!isNaN(betAmount) && betAmount > 0) {
        playerAction("raise", game, betAmount);
    } else {
        console.log("Veuillez entrer un montant de relance valide.");
    }
}

// Fonction pour mettre a jour en temps rééel le bouton de relance
function UpdateRaiseAmount() {
                document.getElementById("raise").innerText = `Relancer (${document.getElementById("current-bet").innerText}+${document.getElementById("bet-amount").value})`;
        }