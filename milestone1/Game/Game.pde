/* global variables */

int framerate = 30; /* framerate of the animation */
int window = 500; /* window size (square) */

int boxSize = 300; /* sidelength of box */
int boxHeight = 20; /* height of box */

int ballSize = 12; /* radius of ball */
Mover mover; /* mover for ball */

float cylinderBaseSize = 10; /* radius of cylinder */
float cylinderHeight = 30; /* height of cylinder */
int cylinderResolution = 20; /* # polygons of cylinders */
PShape openCylinder = new PShape(); /* mantle of cylinder */
PShape cylinderTop = new PShape(); /* top of cylinder */
PShape cylinderBottom = new PShape(); /* bottom of cylinder */
int leafSize = 20;

boolean addMode = false; /* adding-cylinders mode */
ArrayList<PVector> cylinders = new ArrayList(); /* positions of cylinders */
int elems = 0; /* total number of cylinders */
int border = (window - boxSize)/2; /* width of the border around the beard in adding-cylinders mode */


color backgroundC = color(200, 230, 200); /* background color */
color boardC = color(255, 255, 255); /* board color */
color ballC = color(200, 0, 0); /* ball color */



void settings() {
  size(window, window, P3D);
}



void setup() {
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
}



void draw() {
  pushMatrix(); /* matrix for shapes */

  /* transformations */
  noStroke();
  fill(boardC);
  background(backgroundC);
  lights();
  camera(width/2, height/2, 450, 250, 250, 0, 0, 1, 0);

  translate(width/2, height/2, 0);

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
    if ( (mouseX >= border) && (mouseX <= (window - border) ) && 
      (mouseY >= border) && (mouseY <= (window - border) ) ) {
      cylinders.add(new PVector(mouseX, mouseY));
      ++elems;
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