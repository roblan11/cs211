Mover mover;
int boxsize = 300;
int boxheight = 20;
int ballsize = 10;
void settings() {
  size(500, 500, P3D);
}
void setup() {
  f = createFont("Arial", 16, true);
  mover = new Mover();
}
void draw() {
  pushMatrix();
  noStroke();
  fill(255);
  background(200, 230, 200);
  lights();
  camera(width/2, height/2, 450, 250, 250, 0, 0, 1, 0);
  translate(width/2, height/2, 0);
  rotateX(rotx);
  rotateZ(rotz);
  box(boxsize, boxheight, boxsize);
  
  translate(0, -(boxheight/2 + ballsize), 0);
  mover.update();
  mover.checkEdges();
  mover.display();
  popMatrix();

  pushMatrix();
  stroke(175);
  textFont(f);       
  fill(0);
  textAlign(LEFT);
  text(rscale, 0, 20);
  text("("+mouseX+", "+mouseY+")", 0, 40);
  text("("+(rotz*180/PI)+"°, "+(rotx*180/PI)+"°)", 0, 60);
  popMatrix();
}

PFont f;
float rotx = 0;
float rotz = 0;
float rscale = 1;
int lastmx = 0;
int lastmy = 0;

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
  lastmx = mouseX;
  lastmy = mouseY;
}

void mouseDragged() {
  // 60° PI/3
  float delta = 0.01;
  rotx = clampPI( rotx + rscale * delta * (mouseY - lastmy) );
  rotz = clampPI( rotz + rscale * delta * (mouseX - lastmx) );
  lastmx = mouseX;
  lastmy = mouseY;
}

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