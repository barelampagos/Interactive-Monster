// Author: Bryan Relampagos
// CyWorm Interactive Monster
// Interaction Design
// Fall 2015

// Tweakable Parameters
int maxBody = 20;                    
int numBody = 2;
int totalSquid = 8;
int numFoodSquid = totalSquid / 2;
int numPSquid = totalSquid / 2;

// Easing for following the mouse
float easing = 0.06;
float xEasing = 0;
float yEasing = 0;

// Body segments
float[] xBody = new float[maxBody];
float[] yBody = new float[maxBody];
float segLength = 20;
color bodyFill = color(0, 220, 50);

// Movement - either randomized or following
boolean follow = false;
boolean xDirection = false; // False = left, True = right
boolean yDirection = false; // False = down, True = up
float x = width/2;
float y = height/2;

// Handles Red Squid = Food
int foodSquidR = 40;
int[] foodSquidX = new int[numFoodSquid];
int[] foodSquidY = new int[numFoodSquid];
int[] foodSquidSpeed = new int[numFoodSquid];
boolean[] activeFoodSquid = new boolean[numFoodSquid];

// Handles Purple Squid = Poisonous
int[] pSquidX = new int[numPSquid];
int[] pSquidY = new int[numPSquid];
int[] pSquidSpeed = new int[numPSquid];
boolean[] activePSquid = new boolean[numPSquid];

// Other Variables
int numBubbles = 15;
boolean lightOn = false;
int[] bubblesX = new int[numBubbles];
int[] bubblesY = new int[numBubbles];
int[] bubbleSize = new int[numBubbles];
int rotation = 0;
boolean dead = false;
int resetWorm = 0;

void setup() {
  size(displayWidth, displayHeight);
  noStroke();
  noCursor();
}

void draw() {
  drawBackground();
  drawCursor();
  drawBubbles();

  // If following
  if (follow == true && dead == false) {
    xEasing += (mouseX - xEasing) * easing;
    yEasing += (mouseY - yEasing) * easing;

    drawBody(xEasing, yEasing);
    drawFace(xEasing, yEasing);
    checkCollision(xEasing, yEasing);
  }
  // Else - Randomize movement
  else if (follow != true && dead == false) {
    drawBody(x, y);
    drawFace(x, y);

    checkCollision(x, y);
    calculateMovement();
  } 

  // Plays death animation if dead
  if (follow == true && dead == true) {
    drawBody(xEasing, yEasing);
    drawFace(xEasing, yEasing);
    yEasing += 5;
  } else if (follow == false && dead == true) {
    drawBody(x, y);
    drawFace(x, y);
    y += 5;
  }
  
  // Generate new Squids or update current Squid positions
  generateFoodSquid();
  generatePSquid();
}

// dragSegment, segment, and drawBody functions adapted from Follow 3 example
// Follow 3 based on code from Keith Peters
// From the Processing Reference Website: https://processing.org/examples/follow3.html
// Peters, K (2015) Follow 3 (Processing Version 3.0) [Example]. https://processing.org/
void dragSegment(int i, float xin, float yin) {
  float dx = xin - xBody[i];
  float dy = yin - yBody[i];
  float angle = atan2(dy, dx); 
  xBody[i] = xin - cos(angle) * segLength;
  yBody[i] = yin - sin(angle) * segLength;
  segment(xBody[i], yBody[i], angle);
}

void segment(float x, float y, float a) {
  pushMatrix();
  translate(x, y);
  rotate(a);
  line(0, 0, segLength, 0);
  popMatrix();
}

void drawBody(float x, float y) {
  dragSegment(0, x, y);
  strokeWeight(40);
  stroke(bodyFill, 100);

  for (int i = 0; i < numBody-1; i++) {
    dragSegment(i+1, xBody[i], yBody[i]);
  }
}

//End Referenced Material---------------------------------------------------------------//

// Draws head and the eyeball of main head node
void drawFace(float x, float y) { 
  pushMatrix();
  strokeWeight(0.5);
  translate(x, y);

  // Head
  fill(200);
  rect(18, -30, 10, 40);
  rect(-28, -30, 10, 40);
  fill(bodyFill);
  ellipse(0, 0, 60, 60);
  strokeWeight(1);

  // Mouth
  stroke(0);
  // Neutral 
  if (numBody < maxBody && numBody >= 5) {
    line(-5, 25, 5, 25);
  }
  // Sad 
  else if (numBody < 5) {
    line(-8, 25, 8, 23);
  } 
  // Happy 
  else {
    line(-5, 25, -15, 20);
    line(-5, 25, 5, 25);
    line(5, 25, 15, 20);
  }
  strokeWeight(0.5);
  noStroke();

  // Eye
  if (dead == true) {
    stroke(0);
    strokeWeight(2);
    line(-15, -15, 15, 15);
    line(-15, 15, 15, -15);
  } else if (lightOn || numBody == maxBody) {
    fill(255);
    ellipse(0, 0, 40, 40);
    fill(0);
    ellipse(0, 0, 10, 10);
  } else {
    fill(255);
    ellipse(0, 0, 40, 20);
    fill(0);
    ellipse(0, 0, 10, 10);
  }

  popMatrix();
}

// Calculates randomized movement
void calculateMovement() {
  float xRand = random(1, 10);
  float yRand = random(1, 5);

  if (xDirection) {
    x -= xRand;
    if (x <= 0) {
      xDirection = !xDirection;
    }
  } else {
    x += xRand;
    if (x >= width) {
      xDirection = !xDirection;
    }
  }

  if (yDirection) {
    y -= yRand;
    if (y <= 0) { 
      yDirection = !yDirection;
    }
  } else {
    y += yRand;
    if (y >= height) {
      yDirection = !yDirection;
    }
  }
}

// Generates a food squid that can be eaten
void generateFoodSquid() {
  for (int i = 0; i < numFoodSquid; i++) {
    if (activeFoodSquid[i] == false) {
      foodSquidX[i] = 0;
      foodSquidY[i] = (int) random(0, height);
      foodSquidSpeed[i] = (int) random(3, 8);
      activeFoodSquid[i] = true;
    } else { 
      // Draw Squid at generated location
      fill(255, 0, 0);
      stroke(255, 0, 0);
      strokeWeight(4); 
      drawSquid(foodSquidX[i], foodSquidY[i]);

      // Moves with assigned speed
      foodSquidX[i] += foodSquidSpeed[i];

      // If it reaches the end, draw a new one
      if (foodSquidX[i] > width) {
        activeFoodSquid[i] = false;
      }
    }
  }
}

void generatePSquid() {
  for (int i = 0; i < numPSquid; i++) {
    // Generates a poison squid that can be eaten
    if (activePSquid[i] == false) {
      pSquidX[i] = 0;
      pSquidY[i] = (int) random(0, height);
      pSquidSpeed[i] = (int) random(3, 8);
      activePSquid[i] = true;
    } else { 
      // Draw Squid at generated location
      color squidFill = color(106, 42, 184);
      fill(squidFill);
      stroke(squidFill);
      strokeWeight(4); 
      drawSquid(pSquidX[i], pSquidY[i]);

      // Moves with assigned speed
      pSquidX[i] += pSquidSpeed[i];

      // If it reaches the end, draw a new one
      if (pSquidX[i] > width) {
        activePSquid[i] = false;
      }
    }
  }
}

// Handles the Drawing of the Squid Sprite
void drawSquid(int x, int y) {
  pushMatrix();
  translate(x, y);

  // Body
  ellipse(0, 0, foodSquidR, foodSquidR);

  // Tentacles
  line(-10, 10, -15, 25); 
  line(0, 10, 0, 25); 
  line(10, 10, 15, 25); 

  // Eyes
  strokeWeight(.05);
  fill(255);
  ellipse(-10, -5, 15, 15); 
  ellipse(10, -5, 15, 15); 
  stroke(0);
  fill(0);
  ellipse(-10, -5, 5, 5); 
  ellipse(10, -5, 5, 5);

  popMatrix();
}

// Handles Collision Logic 
void checkCollision(float x, float y) {
  for (int i = 0; i < numFoodSquid; i++) {
    // If collide with the food
    if (checkCollision(x, y, foodSquidX[i], foodSquidY[i], foodSquidR)) {
      if (numBody < maxBody) {
        numBody++;
      } else {
        bodyFill = color(random(0, 255), random(0, 255), random(0, 255));
      }
      activeFoodSquid[i] = false;
    } 
    // Handles collision with poison squid
    else if (checkCollision(x, y, pSquidX[i], pSquidY[i], foodSquidR)) {
      if (numBody >= 3) {
        numBody--;
      } else {
        println("Cyworm is dead. Good job :(");
        dead = true;
      }
      activePSquid[i] = false;
    }
  }
}

// Checks if any two objects collide
boolean checkCollision(float x, float y, float x2, float y2, float r) {
  if (dist(x, y, x2, y2) < r) {
    return true;
  } else {
    return false;
  }
}

// Draws the Submarine Sprite at mouseX and mouseY
void drawCursor() {
  pushMatrix();
  translate(mouseX, mouseY);
  strokeWeight(1);

  // Draw light
  noStroke();
  if (lightOn) {
    fill(255, 255, 0);
  } else {
    fill(255, 50);
  }
  ellipse(0, -20, 10, 20);

  // Draw Ship
  fill(96, 96, 96);
  ellipse(0, 0, 120, 50);

  // Propeller
  fill(80, 80, 80);
  strokeWeight(.5);
  pushMatrix();
  translate(-60, 0);
  rotate(radians(rotation));
  rotation += 15;
  ellipse(0, 0, 10, 25);
  ellipse(0, 0, 25, 10);
  popMatrix();

  // Ship Light
  if (lightOn) {
    fill(255);
  } else {
    fill(255, 50);
  }

  // Windows
  ellipse(30, -5, 40, 25);
  ellipse(0, -5, 10, 10);
  ellipse(-15, -5, 10, 10);
  ellipse(-30, -5, 10, 10);

  // Main window + Sub Driver
  stroke(0);
  ellipse(30, -7, 10, 10);
  line(30, -3, 30, 7);
  line(30, -3, 34, 5);
  line(30, -3, 26, 5);
  popMatrix();
}

// Draws Bubbles to provide
void drawBubbles() {
  fill(102, 178, 255, 90);
  noStroke();
  for (int i = 0; i < numBubbles; i++) {
    if (bubblesY[i] < 0) {
      bubblesX[i] = (int) random(0, width);
      bubblesY[i] = (int) random(height / 1.1, height * 1.4);
      bubbleSize[i] = (int) random(5, 20);
    } else {
      ellipse(bubblesX[i], bubblesY[i], bubbleSize[i], bubbleSize[i]);
      bubblesY[i] -= 2;
    }
  }
}

// Draws gradient background
void drawBackground() {
  rectMode(CENTER);
  noStroke();
  int g = 136;
  int b = 220;
  int gradientMax = b;

  for (int i = 0; i < gradientMax; i++) {
    fill(0, g, b);
    rect(0, 8 * i, width * 2, 8);

    if (g > 0) {
      g -= 2;
    }
    b -= 2;
  }

  rectMode(CORNER);
}

void mouseClicked() {
  // Switch - CyWorm follows the mouse cursor
  if (mouseButton == LEFT) {
    if (dead == false) {
      follow = !follow;
      x = mouseX;
      y = mouseY;
    }
    // Switch for Light
    lightOn = !lightOn;
    
    // Allows user to reset CyWorm when killed
    if (dead == true) {
      resetWorm++;
      if (resetWorm == 4) {
        dead = false;
        resetWorm = 0;
      }
    }
  }
}

