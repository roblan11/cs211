void settings(){
  size(500, 500, P3D);
}
void setup(){
  noStroke();
}
void draw(){
  background(100);
  lights();
  camera(width/2, height/2, 450, 250, 250, 0, 0, 1, 0);
  translate(width/2, height/2, 0);
  rotateX(rotx*PI/8);
  rotateY(roty*PI/8);
  box(150, 150, 150);
  translate(100, 0, 0);
}

/* rotate on keypress */
float rotx = 0;
float roty = 0;

void keyPressed(){
  if(key == CODED){
    if(keyCode == UP){
      rotx += 1;
    } else if (keyCode == DOWN) {
      rotx -= 1;
    } else if (keyCode == LEFT) {
      roty -= 1;
    } else if (keyCode == RIGHT) {
      roty += 1;
    }
  }
}