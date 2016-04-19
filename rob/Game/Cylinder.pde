class Cylinder{

  /* class variables */
  int cylinderResolution = 20; /* # polygons of cylinders */
  PShape openCylinder = new PShape(); /* mantle of cylinder */
  PShape cylinderTop = new PShape(); /* top of cylinder */
  PShape cylinderBottom = new PShape(); /* bottom of cylinder */
  ArrayList<PVector> list = new ArrayList(); /* positions of cylinders */

  Cylinder() {
    /* set up vectors, no movement along y axis */
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
  }
 

  /* draw cylinder */
  void display() {
    for (PVector i : list) {
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
  }
  
  boolean validCylinderPos(){
    if ( (mouseX < borderVer) || (mouseX > (windowWidth - borderVer) ) || 
         (mouseY < borderHor) || (mouseY > (windowHeight - borderHor) ) ) {
      return false;
    }
    for(PVector i: list){
      if(i.dist(new PVector(mouseX, mouseY)) < 2*cylinderBaseSize ){
        return false;
      }
    }
    if(ball.distance(ball.location, new PVector(mouseX - borderVer - ball.limit, 0, mouseY - borderHor - ball.limit)) < cylinderBaseSize + ballSize){
      return false;
    }
    return true;
  }

  void putCylinder(){
    if (addMode) {
      if ( validCylinderPos() ) {
        list.add(new PVector(mouseX, mouseY));
      }
    }
  }
  
  void preview(){
    if(addMode){
      if(cylinder.validCylinderPos()){
        stroke(0, 255, 0);
        noFill();
        strokeWeight(2);
        ellipse(mouseX, mouseY, 2*cylinderBaseSize, 2*cylinderBaseSize);
      } else {
        stroke(255, 0, 0);
        noFill();
        strokeWeight(2);
        float strokeLength = cylinderBaseSize/sqrt(2);
        line(mouseX - strokeLength, mouseY - strokeLength, mouseX + strokeLength, mouseY + strokeLength);
        line(mouseX + strokeLength, mouseY - strokeLength, mouseX - strokeLength, mouseY + strokeLength);
        ellipse(mouseX, mouseY, 2*cylinderBaseSize, 2*cylinderBaseSize);
      }
    }
  }
}