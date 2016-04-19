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

float cylinderBaseSize = 20; /* radius of cylinder */
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

/* other game variables */
Ball ball; /* ball */
Cylinder cylinder; /* cylinder */
HScrollbar scrollBar; /* scrollbar */
Scoreboard scoreboard; /* scoreboard */
boolean addMode = false; /* adding-cylinders mode */
int borderHor = (windowHeight - boxSize)/2; /* width of the horizontal border around the beard in adding-cylinders mode */
int borderVer = (windowWidth - boxSize)/2; /* width of the vertical border -''- */
PFont f; /* font preset */


void settings() {
  size(windowWidth, windowHeight, P3D);
}

void setup() {
  frameRate(framerate); /* set the framerate */
  f = createFont("Arial", 16, true); /* font preset */
  /* initialize classes */
  ball = new Ball();
  cylinder = new Cylinder();
  scrollBar = new HScrollbar((statSize*3/2 + 3*statBorder), windowHeight - (2*statBorder), (windowWidth - (statSize*3/2 + 4*statBorder))/2, statBorder);
  scoreboard = new Scoreboard();
}

void draw() {
  pushMatrix(); /* matrix for shapes */

  /* transformations */
  noStroke();
  fill(boardC);
  background(backgroundC);
  lights();
  ambientLight(0, 100, 0, 1, 0, 0);
  camera(windowWidth/2, windowHeight/2, windowHeight*7/8, 
         windowWidth/2, windowHeight/2, 0, 
         0,             1,              0);  

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
  cylinder.display();
  translate(0, (cylinderHeight + boxHeight/2), 0);

  /* ball display */
  translate(0, -(boxHeight/2 + ballSize), 0);
  if (!addMode) {
    ball.update();
    ball.checkEdges();
    ball.checkCylinderCollision();
  }
  ball.display();
  translate(0, (boxHeight/2 + ballSize), 0);  
  popMatrix();
  
  pushMatrix(); /* matrix for 2D shapes bar */
  scoreboard.display();
  cylinder.preview();
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
    text(cylinder.list.size(), 0, 80); /* display current number of cylinders */
    popMatrix();
  }
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
    scoreboard.moveBoard = false;
  }
  /* add a new cylinder */
  cylinder.putCylinder();
}

/* rotate around the x and z axis on mousedrag */
void mouseDragged() {
  if(scoreboard.moveBoard){
    float delta = 0.01;
    rotX = clampPI( rotX + rScale * delta * (lastMY - mouseY) );
    rotZ = clampPI( rotZ + rScale * delta * (mouseX - lastMX) );
    lastMX = mouseX;
    lastMY = mouseY;
  }
}

void mouseReleased(){
  scoreboard.moveBoard = true;
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