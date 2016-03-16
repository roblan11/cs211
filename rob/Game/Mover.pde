class Mover {
  
// necessary vectors
  PVector location;
  PVector velocity;
  PVector gravity;
  PVector frict;
// constant for bounce off the wall
  float bounce = 2.0;

// sets pos and vel of sphere
  Mover() {
// DO NOT CHANGE Y!
    int y = 0;
    location = new PVector(0, y, 0);
    velocity = new PVector(0, y, 0);
    gravity  = new PVector(0, y, 0);
  }

// updates values of mover
  void update() {
// computation of the friction
    float normal = 1;
    float mu = 0.01;
    float frictmag = normal * mu;
    frict = velocity.copy();
    frict.normalize().mult(frictmag);

// computation of the gravity
    float grav = 9.81;
    gravity.x = sin(rotz) * grav;
    gravity.z = sin(-rotx) * grav;
   
// update velocity and location
    velocity.add(gravity.mult(1.0/framerate));
    location.add(velocity).add(frict.mult(-1));
  }
  
// draw sphere
  void display() {
    noStroke();
    fill(0, 130, 0);
    translate(location.x, location.y, location.z);
    sphere(ballsize);
  }

// check properties on the edges
  void checkEdges() {
    float limit = (boxsize/2.0);
    if (location.x > limit) {
      velocity.x  *= -1/bounce;
      location.x = limit;
    } else if (location.x < -limit) {
      velocity.x  *= -1/bounce;
      location.x = -limit;
    }
    if (location.z > limit) {
      velocity.z *= -1/bounce;
      location.z = limit;
    } else if (location.z < -limit) {
      velocity.z *= -1/bounce;
      location.z = -limit;
    }
  }
}