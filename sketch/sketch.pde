PImage[] playerImages = new PImage[4]; 
int selectedPlayer = -1; 
int frameWidth = 100; 
int frameHeight = 100;

int[][][] pins; 
int currentPlayer = 0; 
int frameNumber = 1; 
int currentAttempt = 1; 
int[] totalScores = {0, 0, 0, 0};

void setup() {
  size(800, 600);
  resetGame();
  textFont(createFont("Arial", 22));
  textAlign(CENTER, CENTER);
  
  // Charger les images des joueurs
  playerImages[0] = loadImage("player1.png");
  playerImages[1] = loadImage("player2.png");
  playerImages[2] = loadImage("player3.png");
  playerImages[3] = loadImage("player4.png");
  
  // Redimensionner les images pour les faire tenir dans le cadre
  for (int i = 0; i < playerImages.length; i++) {
    playerImages[i].resize(100, 0);
  }
}

void draw() {
  background(220);
  
  if (selectedPlayer == -1) {
    displayPlayerSelection();
  } else if (frameNumber <= 10) {
    displayFrameInfo();
  } else {
    displayEndScreen();
  }
}

void resetGame() {
  pins = new int[4][10][2];
  currentPlayer = 0;
  frameNumber = 1;
  currentAttempt = 1;
  for (int i = 0; i < 4; i++) {
    totalScores[i] = 0;
  }
}

void displayPlayerSelection() {
  textSize(24);
  fill(0);
  text("Sélectionnez un joueur en cliquant sur son image", width / 2, height / 2 - 50);
  
  // Afficher les images des joueurs et détecter la sélection
  for (int i = 0; i < 4; i++) {
    if (mouseX > i * (width / 4) && mouseX < (i + 1) * (width / 4) && mouseY > height / 2 && mouseY < height / 2 + frameHeight) {
      noFill();
      stroke(255, 0, 0); // Bordure rouge si la souris est sur l'image
      strokeWeight(3);
      rect(i * (width / 4), height / 2, frameWidth, frameHeight); // Cadre autour de l'image
      if (mousePressed) {
        selectedPlayer = i;
      }
    }
    image(playerImages[i], i * (width / 4), height / 2, frameWidth, frameHeight); // Utiliser la taille redimensionnée
    noStroke();
  }
}

void displayFrameInfo() {
  fill(0);
  text("Joueur : " + (currentPlayer + 1), width / 2, 30);
  text("Tour : " + frameNumber, width / 2, 60);
  
  int pinsKnocked = pins[currentPlayer][frameNumber - 1][0] + pins[currentPlayer][frameNumber - 1][1];
  text("Quilles renversées : " + pinsKnocked, width / 2, height / 2 - 50);

  text("Player 1: " + totalScores[0], 100, height - 120);
  text("Player 2: " + totalScores[1], 300, height - 120);
  text("Player 3: " + totalScores[2], 500, height - 120);
  text("Player 4: " + totalScores[3], 700, height - 120);
  
  if (currentAttempt == 1) {
    text("Appuyez sur ESPACE pour le 1er essai", width / 2, height - 50);
  } else if (currentAttempt == 2) {
    text("Appuyez sur ESPACE pour le 2e essai", width / 2, height - 50);
  }
}

void displayEndScreen() {
  fill(0);
  textSize(32);
  text("Partie terminée !", width / 2, height / 5);
  
  for (int i = 0; i < 4; i++) {
    int totalScore = calculateTotalScore(i, 9);
    textSize(24);
    text("Score Joueur " + (i + 1) + " : " + totalScore, width / 2, height / 2 + (i * 50));
  }
  
  int winner = findWinner();
  text("Le vainqueur est Joueur " + (winner + 1) + " !", width / 2, height / 2 + 200);
  text("Appuyez sur ENTRÉE pour rejouer", width / 2, height - 50);
}

int calculateTotalScore(int player, int frameIndex) {
  int total = 0;
  for (int i = 0; i <= frameIndex; i++) {
    total += pins[player][i][0] + pins[player][i][1];
    if (i > 0 && isStrike(player, i - 1)) {
      total += pins[player][i][0] + pins[player][i][1];
    }
    if (i > 1 && isSpare(player, i - 2)) {
      total += pins[player][i][0];
    }
  }
  return total;
}

boolean isStrike(int player, int frameIndex) {
  return pins[player][frameIndex][0] == 10;
}

boolean isSpare(int player, int frameIndex) {
  return pins[player][frameIndex][0] + pins[player][frameIndex][1] == 10;
}

int findWinner() {
  int maxScore = 0;
  int winner = 0;
  for (int i = 0; i < 4; i++) {
    if (totalScores[i] > maxScore) {
      maxScore = totalScores[i];
      winner = i;
    }
  }
  return winner;
}

void keyPressed() {
  if (keyCode == 32 && frameNumber <= 10 && currentAttempt <= 2) { // ESPACE
    rollBall();
  }
  if (keyCode == ENTER && frameNumber > 10) {
    resetGame();
  }
}

void mouseClicked() {
  if (selectedPlayer == -1) {
    for (int i = 0; i < 4; i++) {
      if (mouseX > i * (width / 4) && mouseX < (i + 1) * (width / 4) && mouseY > height / 2 && mouseY < height) {
        selectedPlayer = i;
      }
    }
  } else if (frameNumber <= 10 && currentAttempt <= 2) {
    rollBall();
  } else if (frameNumber > 10) {
    resetGame();
  }
}

void rollBall() {
  int remainingPins = 10 - pins[currentPlayer][frameNumber - 1][currentAttempt - 1];
  int pinsKnocked = int(random(remainingPins + 1));
  pins[currentPlayer][frameNumber - 1][currentAttempt - 1] = pinsKnocked;

  if (currentAttempt == 1 && pinsKnocked < remainingPins) {
    currentAttempt = 2;
  } else {
    currentAttempt = 1;
    totalScores[currentPlayer] = calculateTotalScore(currentPlayer, frameNumber - 1); // Mettre à jour le score total
    currentPlayer = (currentPlayer + 1) % 4; // Passer au joueur suivant
    if (currentPlayer == 0) {
      frameNumber++;
    }
  }
}