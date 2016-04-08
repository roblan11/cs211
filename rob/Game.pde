/* game variables (settings) */

boolean removeTrees = false; /* remove "trees" when hit */
boolean isTree = false; /* display tree w/ leafs */
boolean showtext = false; /* display text */

int framerate = 30; /* framerate of the animation */
int windowWidth = 1500; /* window width */
int windowHeight = 1000; /* window height */

int boxSize = 500; /* sidelength of box */
int boxHeight = 10; /* height of box */

int ballSize = 12; /* radius of ball */

float cylinderBaseSize = 10; /* radius of cylinder */
float cylinderHeight = 30; /* height of cylinder */
int leafSize = 20; /* size of leafball */

int statSize = windowHeight/5; /* size of the bottom bar */
int statBorder = 10; /* size of the border of the bottom bar */
int statGraphBaseBoxSize = 14;

/* color collection */

color backgroundC = color(240); /* background color */
color boardC = color(255); /* board color */
color ballC = color(200, 0, 0); /* ball color */
color textC = color(0); /* text color */
color cylinderC = color(153, 76, 0); /* cylinder color */
color leafC = color(0, 102, 0); /* leaf color */
color dataBackC = color(0); /* bottom color */
color dataBoxC = color(255); /* top view color */
color dataScoreTextC = color(255); /* stat text color */

/* other variables */

float score = 0; /* current score */
float last = 0; /* last score change */

Mover mover; /* mover for ball */
PVector location; /* ball location vector */
PVector velocity; /* ball velocity vector */
float limit = (boxSize/2.0); /* limit on x and z axis */

int cylinderResolution = 20; /* # polygons of cylinders */
PShape openCylinder = new PShape(); /* mantle of cylinder */
PShape cylinderTop = new PShape(); /* top of cylinder */
PShape cylinderBottom = new PShape(); /* bottom of cylinder */

boolean addMode = false; /* adding-cylinders mode */
ArrayList<PVector> cylinders = new ArrayList(); /* positions of cylinders */
int borderHor = (windowHeight - boxSize)/2; /* width of the horizontal border around the beard in adding-cylinders mode */
int borderVer = (windowWidth - boxSize)/2; /* width of the vertical border -''- */

/* TODO ___ */
ArrayList<Float> scores = new ArrayList();

PGraphics dataB;
PGraphics topView;
PGraphics scoreBoard;
PGraphics barChart;
PGraphics infoBar;
boolean moveBoard = true;

PFont f; /* font preset */

HScrollbar scrollBar;

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
  dataB = createGraphics(windowWidth, statSize + 2*statBorder, P2D);
  topView = createGraphics(statSize, statSize, P2D);
  scoreBoard = createGraphics(statSize/2, statSize, P2D);
  barChart = createGraphics((windowWidth - statSize*3/2 - 4*statBorder), statSize - 2*statBorder, P2D);
  infoBar = createGraphics((windowWidth/2 - statSize*3/4 - 3*statBorder), 2*statBorder, P2D);
  
  scrollBar = new HScrollbar((statSize*3/2 + 3*statBorder), windowHeight - (2*statBorder), (windowWidth - (statSize*3/2 + 4*statBorder))/2, statBorder);
}



void draw() {
  pushMatrix(); /* matrix for shapes */

  /* transformations */
  noStroke();
  fill(boardC);
  background(backgroundC);
  lights();
  ambientLight(0, 100, 0, 1, 0, 0);
  camera(windowWidth/2, windowHeight/2, windowHeight*7/8, windowWidth/2, windowHeight/2, 0, 0, 1, 0);  

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
  
  pushMatrix(); /* matrix for bottom bar */
  fill(255);
  noLights();
  drawData();
  image(dataB, 0, windowHeight - (statSize + 2*statBorder));
  drawTop();
  image(topView, statBorder, (windowHeight - statSize - statBorder));
  drawScores();
  image(scoreBoard, (statSize + 2*statBorder), (windowHeight - statSize - statBorder));
  drawChart();
  image(barChart, (statSize*3/2 + 3*statBorder), (windowHeight - statSize - statBorder));
  addInfo();
  image(infoBar, (statSize*3/4 + statBorder*2 + windowWidth/2), windowHeight - (statBorder*5/2));
  scrollBar.update();
  scrollBar.display();
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

int counter = framerate;
int curMaxScore = 1;
float squareSizeX;
float squareSizeY = statGraphBaseBoxSize;
int numBoxes = (statSize - 2*statBorder)/(int)squareSizeY;
int graphWidth = (windowWidth - statSize*3/2 - 4*statBorder);

/* information about the current value of 1 box and the current max in the graph */
void addInfo(){
  infoBar.beginDraw();
  infoBar.background(dataBackC);
  infoBar.textFont(f);
  infoBar.textSize(statBorder*3/2);
  infoBar.fill(ballC);
  infoBar.rect(statGraphBaseBoxSize*2 - squareSizeX, (statBorder*2 - squareSizeY)/2, squareSizeX, squareSizeY);
  infoBar.fill(dataScoreTextC);
  infoBar.textAlign(LEFT);
  infoBar.text(" = " + ceil(curMaxScore/(float)numBoxes), 2*statGraphBaseBoxSize, statBorder*3/2);
  infoBar.textAlign(RIGHT);
  infoBar.text("max display: " + curMaxScore, (windowWidth/2 - statSize*3/4 - 3*statBorder), statBorder*3/2);
  infoBar.endDraw();
}
void drawChart(){
  barChart.beginDraw();
  barChart.background(dataBoxC);
  barChart.fill(ballC);
  barChart.stroke(255);
  squareSizeX = statGraphBaseBoxSize*(scrollBar.getPos() + 0.5);
  /* change to right side on fill-up */
  if(scores.size() > floor(graphWidth/squareSizeX)){
    for(int i = 0; i < floor(graphWidth/squareSizeX) + 1; ++i){
      for(int j = 0; j*squareSizeY <= statSize - 2*statBorder; ++j){
        if(j < scores.get(scores.size() - 1 - i)*numBoxes/curMaxScore){
          barChart.rect(( graphWidth - ceil((i+1)*squareSizeX)), statSize - 2*statBorder - j*squareSizeY, squareSizeX, squareSizeY);
        }
      }
    }
  } else {
    for(int i = 0; i < floor(graphWidth/squareSizeX); ++i){
      for(int j = 0; j*squareSizeY <= statSize - 2*statBorder; ++j){
        if(i < scores.size() && j < scores.get(i)*numBoxes/curMaxScore){
          barChart.rect(i*squareSizeX, statSize - 2*statBorder - j*squareSizeY, squareSizeX, squareSizeY);
        }
      }
    }
  }
  /* always stay left */
  //ArrayList<Float> subScores;
  //if(scores.size() > floor(graphWidth/squareSizeX)){
  //  subScores = new ArrayList(scores.subList(max(scores.size() - floor(graphWidth/squareSizeX), 0), scores.size()));
  //} else {
  //  subScores = scores;
  //}
  //for(int i = 0; i < floor(graphWidth/squareSizeX); ++i){
  //  for(int j = 0; j*squareSizeY <= statSize - 2*statBorder; ++j){
  //    if(i < subScores.size() && j < subScores.get(i)*numBoxes/curMaxScore){
  //      barChart.rect(i*squareSizeX, statSize - 2*statBorder - j*squareSizeY, squareSizeX, squareSizeY);
  //    }
  //  }
  //}
  barChart.endDraw();
  if(!addMode){
    if(counter < framerate/2){
      ++counter;
    } else {
      counter = 0;
      scores.add(score);
      if(score > curMaxScore){
        curMaxScore = (int)score;
      }
    }
  }
}
void drawScores() {
  scoreBoard.beginDraw();
  scoreBoard.background(dataBackC);
  scoreBoard.textFont(f);
  scoreBoard.textSize(statSize/12);
  scoreBoard.textAlign(CENTER);
  scoreBoard.fill(dataScoreTextC);
  scoreBoard.text("score", statSize/4, statSize/4 - 10);
  scoreBoard.text(score, statSize/4, statSize/4 + 10);
  scoreBoard.text("velocity", statSize/4, statSize/2 - 10);
  scoreBoard.text(velocity.mag(), statSize/4, statSize/2 + 10);
  scoreBoard.text("last change", statSize/4, statSize*3/4 - 10);
  scoreBoard.text(last, statSize/4, statSize*3/4 + 10);
  scoreBoard.endDraw();
}
void drawData() {
  dataB.beginDraw();
  dataB.background(dataBackC);
  dataB.endDraw();
}
void drawTop() {
  topView.beginDraw();
  topView.noStroke();
  topView.background(dataBoxC);
  float topBall = ballSize*2*statSize/boxSize;
  float topCyl = cylinderBaseSize*2*statSize/boxSize;
  topView.fill(ballC);
  topView.ellipse((location.x + limit)*statSize/boxSize, (location.z + limit)*statSize/boxSize, topBall, topBall);
  topView.fill(cylinderC);
  for (PVector i : cylinders) {
    topView.ellipse((i.x - windowWidth/2 + boxSize)*statSize/boxSize - statSize/2, (i.y - windowHeight/2)*statSize/boxSize + statSize/2, topCyl, topCyl);
  }
  topView.endDraw();
}

/* additional variables */
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
  if(!scrollBar.isMouseOver()){
    lastMX = mouseX;
    lastMY = mouseY;
  } else {
    moveBoard = false;
  }

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
  if(moveBoard){
    float delta = 0.01;
    rotX = clampPI( rotX + rScale * delta * (lastMY - mouseY) );
    rotZ = clampPI( rotZ + rScale * delta * (mouseX - lastMX) );
    lastMX = mouseX;
    lastMY = mouseY;
  }
}

void mouseReleased(){
  moveBoard = true;
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