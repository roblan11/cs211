/* global variables */

boolean removeTrees = false; /* remove "trees" when hit */
boolean isTree = false; /* display tree w/ leafs */

int framerate = 30; /* framerate of the animation */
int windowWidth = 1500; /* window width */
int windowHeight = 1000; /* window height */

int boxSize = 500; /* sidelength of box */
int boxHeight = 20; /* height of box */
float score = 0;
float last = 0;

int ballSize = 12; /* radius of ball */
Mover mover; /* mover for ball */
PVector location; /* ball location vector */
PVector velocity; /* ball velocity vector */
float limit = (boxSize/2.0); /* limit on x and z axis */

float cylinderBaseSize = 10; /* radius of cylinder */
float cylinderHeight = 30; /* height of cylinder */
int cylinderResolution = 20; /* # polygons of cylinders */
PShape openCylinder = new PShape(); /* mantle of cylinder */
PShape cylinderTop = new PShape(); /* top of cylinder */
PShape cylinderBottom = new PShape(); /* bottom of cylinder */
int leafSize = 20; /* size of leafball */

boolean addMode = false; /* adding-cylinders mode */
ArrayList<PVector> cylinders = new ArrayList(); /* positions of cylinders */
int borderHor = (windowHeight - boxSize)/2; /* width of the horizontal border around the beard in adding-cylinders mode */
int borderVer = (windowWidth - boxSize)/2; /* width of the vertical border -''- */

ArrayList<Float> scores = new ArrayList();

PGraphics dataB;
PGraphics topView;
PGraphics scoreBoard;
PGraphics barChart;

PFont f; /* font preset */
boolean showtext = true; /* display text */

color backgroundC = color(240, 240, 240); /* background color */
color boardC = color(255, 255, 255); /* board color */
color ballC = color(200, 0, 0); /* ball color */
color textC = color(0, 0, 0); /* text color */
color cylinderC = color(153, 76, 0); /* cylinder color */
color leafC = color(0, 102, 0); /* leaf color */
color dataC = color(255, 255, 200); /* bottom color */
color topViewC = color(0, 0, 255); /* top view color */



void settings() {
  size(windowWidth, windowHeight, P3D);
}



void setup() {
  f = createFont("Arial", 16, true); /* font preset */
  mover = new Mover(); /* initialize mover */
  frameRate(framerate); /* set the framerate */

  /* preset for creating cylinders */
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] z = new float[cylinderResolution + 1];
  /* get the x and y position on a circle for all the sides */
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    z[i] = cos(angle) * cylinderBaseSize;
  }
  if (isTree) {
    noStroke();
    fill(cylinderC);
  }
  /* mantle */
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  /* top */
  cylinderTop = createShape();
  cylinderTop.beginShape(TRIANGLE_FAN);
  cylinderTop.vertex(0, cylinderHeight, 0);
  /* bottom */
  cylinderBottom = createShape();
  cylinderBottom.beginShape(TRIANGLE_FAN);
  cylinderBottom.vertex(0, 0, 0);

  /* draw the border of the cylinder */
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], 0, z[i]);
    openCylinder.vertex(x[i], cylinderHeight, z[i]);

    cylinderTop.vertex(x[i], cylinderHeight, z[i]);

    cylinderBottom.vertex(x[i], 0, z[i]);
  }
  openCylinder.endShape();

  cylinderTop.endShape();

  cylinderBottom.endShape();

  /* surface ___ */
  dataB = createGraphics(windowWidth, 220, P2D);
  topView = createGraphics(200, 200, P2D);
  scoreBoard = createGraphics(150, 200, P2D);
  barChart = createGraphics(windowWidth - 390, 180, P2D);
}



void draw() {
  pushMatrix(); /* matrix for shapes */

  /* transformations */
  noStroke();
  fill(boardC);
  background(backgroundC);
  lights();
  ambientLight(0, 100, 0, 1, 0, 0);
  camera(windowWidth/2, windowHeight/2, min(windowWidth, windowHeight) - boxSize/6, windowWidth/2, windowHeight/2, 0, 0, 1, 0);

  translate(windowWidth/2, windowHeight/2, 0);

  /* rotate according to current mode */
  if (addMode) {
    rotateX(-PI/2);
    rotateZ(0);
  } else {
    rotateX(rotX);
    rotateZ(rotZ);
  }

  /* box display */
  box(boxSize, boxHeight, boxSize);



  /* cylinder display */
  translate(0, -(cylinderHeight + boxHeight/2), 0);
  for (PVector i : cylinders) {
    translate( (i.x - width/2), 0, (i.y - height/2) );
    shape(openCylinder);
    shape(cylinderTop);
    shape(cylinderBottom);
    if (isTree) {
      translate(0, -(cylinderHeight/2), 0);
      fill(leafC);
      sphere(leafSize);
      translate(0, (cylinderHeight/2), 0);
    }
    translate( -(i.x - width/2), 0, -(i.y - height/2) );
  }
  translate(0, (cylinderHeight + boxHeight/2), 0);



  /* ball display */
  translate(0, -(boxHeight/2 + ballSize), 0);
  if (!addMode) {
    mover.update();
    mover.checkEdges();
    mover.checkCylinderCollision();
  }
  mover.display();
  translate(0, (boxHeight/2 + ballSize), 0);  
  popMatrix();

  pushMatrix();
  fill(255);
  drawData();
  image(dataB, 0, windowHeight - 220);
  drawTop();
  image(topView, 10, windowHeight - 210);
  drawScores();
  image(scoreBoard, 220, windowHeight - 210);
  drawChart();
  image(barChart, 380, windowHeight - 210);
  popMatrix();

  if (showtext) {
    pushMatrix(); /* matrix for text displays */

    /* text display */
    textFont(f);
    fill(textC);
    textAlign(LEFT);

    text(rScale, 0, 20); /* display rscale */
    text("("+mouseX+", "+mouseY+")", 0, 40); /* display mouse pos (X , Y) */
    text("("+(rotZ*180/PI)+"°, "+(rotX*180/PI)+"°)", 0, 60); /* display rotations (Z , X) */
    text(cylinders.size(), 0, 80); /* display current number of cylinders */
    popMatrix();
  }
}

int counter = 10;

void drawChart(){
  barChart.beginDraw();
  barChart.background(255);
  barChart.endDraw();
  if(counter < 10){
    ++counter;
  } else {
    counter = 0;
    scores.add(score);
  }
}
void drawScores() {
  scoreBoard.beginDraw();
  scoreBoard.background(0);
  scoreBoard.text("score", 10, 40);
  scoreBoard.text(score, 10, 55);
  scoreBoard.text("velocity", 10, 90);
  scoreBoard.text(velocity.mag(), 10, 105);
  scoreBoard.text("last change", 10, 140);
  scoreBoard.text(last, 10, 155);
  scoreBoard.endDraw();
}
void drawData() {
  dataB.beginDraw();
  dataB.background(dataC);
  dataB.endDraw();
}
void drawTop() {
  topView.beginDraw();
  topView.noStroke();
  topView.background(topViewC);
  float topBall = ballSize*400.0/boxSize;
  float topCyl = cylinderBaseSize*400/boxSize;
  topView.ellipse((location.x + limit)*200/boxSize, (location.z + limit)*200/boxSize, topBall, topBall);
  for (PVector i : cylinders) {
    topView.ellipse((i.x - borderHor - (boxSize/2))*200/boxSize, (i.y - borderVer + (boxSize/2))*200/boxSize, topCyl, topCyl);
  }
  topView.endDraw();
}

/* variables for functions */
float rotX = 0; /* rotation around x axis [-PI/3 , PI/3] */
float rotZ = 0; /* rotation around z axis [-PI/3 , PI/3] */

float rScale = 1;  /* scale for rotation [0.2 , 1] */

int lastMX = 0; /* previous xpos of mouse */
int lastMY = 0; /* previous ypos of mouse */

float prevRotX = 0; /* value of rotx before activating adding-cylinders mode */
float prevRotZ = 0; /* value of rotz before activating adding-cylinders mode */

/* method to make sure rotations stay in boundaries */
float clampPI(float x) {
  if (x > PI/3) {
    return PI/3;
  } else if (x < -PI/3) {
    return -PI/3;
  } else {
    return x;
  }
}

void mousePressed() {
  /* avoid teleporting rotations after lifting the mouse */
  lastMX = mouseX;
  lastMY = mouseY;

  /* add a new cylinder */
  if (addMode) {
    if ( (mouseX >= borderVer) && (mouseX <= (windowWidth - borderVer) ) && 
      (mouseY >= borderHor) && (mouseY <= (windowHeight - borderHor) ) ) {
      cylinders.add(new PVector(mouseX, mouseY));
    }
  }
}

/* rotate around the x and z axis on mousedrag */
void mouseDragged() {
  float delta = 0.01;
  rotX = clampPI( rotX + rScale * delta * (lastMY - mouseY) );
  rotZ = clampPI( rotZ + rScale * delta * (mouseX - lastMX) );
  lastMX = mouseX;
  lastMY = mouseY;
}



/* update scale of rotations on mwheel */
void mouseWheel(MouseEvent e) {
  if (e.getCount() > 0) {
    if (rScale < 1.5) {
      rScale += 0.01;
    } else {
      rScale = 1.5;
    }
  } else if (e.getCount() < 0) {
    if (rScale > 0.2) {
      rScale -= 0.01;
    } else {
      rScale = 0.2;
    }
  }
}

/* enable adding-cylinders mode */
void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      addMode = true;
      prevRotX = rotX;
      prevRotZ = rotZ;
    }
  }
}

/* disable adding-cylinders mode */
void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      addMode = false;
      rotX = prevRotX;
      rotZ = prevRotZ;
    }
  }
}