Mover mover; /* mover for ball */

int boxsize = 300; /* sidelength of the box */
int boxheight = 20; /* height of the box */

int ballsize = 12; /* radius of the ball */

int framerate = 30; /* framerate of the animation */
int window = 500; /* window size (square) */

PFont f; /* font preset */

color backgroundc = color(200, 230, 200); /* background color */
color boardc = color(255, 255, 255); /* board color */
color ballc = color(0, 200, 0); /* ball color */
color textc = color(0, 0, 0); /* text color */

void settings() {
  size(window, window, P3D);
}

void setup() {
  f = createFont("Arial", 16, true); /* set up font preset */
  mover = new Mover(); /* initialize mover */
  frameRate(framerate); /* set the framerate */
}

void draw() {
  pushMatrix(); /* matrix for shapes */
  
  /* transformations */
  noStroke();
  fill(boardc);
  background(backgroundc);
  lights();
  camera(width/2, height/2, 450, 250, 250, 0, 0, 1, 0);
  translate(width/2, height/2, 0);
  rotateX(rotx);
  rotateZ(rotz);
  
  /* box display */
  box(boxsize, boxheight, boxsize);
  
  /* ball display */
  translate(0, -(boxheight/2 + ballsize), 0);
  mover.update();
  mover.checkEdges();
  mover.display();
  popMatrix();

  pushMatrix(); /* matrix for text displays */
  
  /* setup */
  textFont(f);
  fill(textc);
  textAlign(LEFT);
  
  text(rscale, 0, 20); /* display rscale */
  text("("+mouseX+", "+mouseY+")", 0, 40); /* display mouse pos (X , Y) */
  text("("+(rotz*180/PI)+"°, "+(rotx*180/PI)+"°)", 0, 60); /* display rotations (Z , X) */
  popMatrix();
}

float rotx = 0; /* rotation around x axis [-PI/3 , PI/3] */
float rotz = 0; /* rotation around z axis [-PI/3 , PI/3] */

float rscale = 1;  /* scale for rotation [0.2 , 1] */

int lastmx = 0; /* previous xpos of mouse */
int lastmy = 0; /* previous ypos of mouse */

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

/* avoid teleporting rotations after lifting the mouse */
void mousePressed() {
  lastmx = mouseX;
  lastmy = mouseY;
}

/* rotate around the x and z axis on mousedrag */
void mouseDragged() {
  float delta = 0.01;
  rotx = clampPI( rotx + rscale * delta * (mouseY - lastmy) );
  rotz = clampPI( rotz + rscale * delta * (mouseX - lastmx) );
  lastmx = mouseX;
  lastmy = mouseY;
}

/* update scale of rotations on mwheel */
void mouseWheel(MouseEvent e) {
  if (e.getCount() > 0) {
    if (rscale < 1) {
      rscale += 0.01;
    } else {
      rscale = 1;
    }
  } else if (e.getCount() < 0) {
    if (rscale > 0.2) {
      rscale -= 0.01;
    } else {
      rscale = 0.2;
    }
  }
}