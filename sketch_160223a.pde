void settings() { 
  size(400, 800, P2D);
}
void setup() {
  background(255, 255, 200);
  noLoop(); 
}
void draw() { 
  plant(15, 0.4, 0.8, color(100, 180, 120));
}
void leaf() {
  beginShape();
  vertex(100.0, -70.0);
  bezierVertex(90.0, -60.0, 40.0, -100.0, 0.0, 0.0);
  bezierVertex(0.0, 0.0, 100.0, 40.0, 100.0, -70.0);
  endShape();
}
void plant(int numLeaves, float minLeafScale, float maxLeafScale, color plantCol) {
  stroke(plantCol);
  fill(plantCol);
  line(width/2, 0, width/2, height); // the plant's stem
  int gap = height/numLeaves; // vertical spacing between leaves 
  float angle = 0;
  for (int i=0; i<numLeaves; i++) {
    int x = width/2;
    int y = gap*i + (int)random(gap);
    float scale = random(minLeafScale, maxLeafScale);
    pushMatrix();
      // Complete the code!
      noStroke();
      translate(x, y);
      scale(scale);
      rotate(angle);
      leaf();
    popMatrix();
    angle += PI; // alternate the side for each leaf
  }
}


//float x = 0.0;

//void settings(){
//  size(400, 800, P2D);
//}

//void setup(){
//  frameRate(30);
//  background(255, 255, 0);
//  noLoop();
//}

//void draw(){
  //background(255, 200, 0); 
  //ellipse(x, height/2, 40, 40); 
  //x += 2;
  //if (x > width + 40) {
  //  x = -40.0; 
  //}
  
  //noFill(); //a Processing built-in function to avoid filling the shape 
  //beginShape();
  //for (int i=0; i<20; i++) {
  //  int y = i%2;
  //  vertex(i*10, 50+y*10);
  //}
  //endShape();
  
//  translate(width/2, height/2); // position your leaf at the center of the window 
 // leaf();
//}

//void leaf () { 
//  beginShape();
//  vertex(100.0, -70.0);
//  bezierVertex(90.0, -60.0, 40.0, -100.0, 0.0, 0.0);
//  bezierVertex(0.0, 0.0, 100.0, 40.0, 100.0, -70.0);
//  endShape();
//}

//boolean isMoving = true;

//void mousePressed () {
//  if (isMoving) { 
//     noLoop(); 
//     isMoving = false;
//  } else {
//    loop();
//    isMoving = true; 
//  }
//}

//void settings(){
//  size(100, 100);
//}

//void setup(){

//}

//void draw(){
//  background(200, 0, 0);  //RGB
//  float x = 20;
//  noStroke();
//  rectMode(CENTER);
//  rect (50, 50, 20, 60);
//  rect(width/2, height/2, x, 3*x);  //POS.X, POS.Y, WID, HEI
//  rect(width/2, height/2, 3*x, x);
//  rect(mouseX, mouseY, x, x);
//}

//void mouseClicked(){
//  noLoop();
//}