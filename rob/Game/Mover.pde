class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  PVector frict;
  Mover() {
    // DO NOT CHANGE Y!
    int y = 0;
    location = new PVector(0, y, 0);
    velocity = new PVector(0, y, 0);
    gravity = new PVector(0, y, 0);
  }
  void update() {
    velocity.add(gravity);
    location.add(velocity);

    float normal = 1;
    float mu = 0.01;
    float frictmag = normal * mu;
    frict = velocity.copy();
    frict.normalize();
    frict.mult(frictmag);
    
    float grav = 9.81;
    gravity.x = sin(rotz) * grav;
    gravity.z = sin(-rotx) * grav;
    
  }
  void display() {
    noStroke();
    fill(0, 130, 0);
    translate(location.x, location.y, location.z);
    sphere(ballsize);
  }
  void checkEdges() {
    float limit = (boxsize/2.0 - ballsize);
    if (location.x > limit) {
      velocity.x  *= -1;
      location.x = limit;
    } else if (location.x < -limit) {
      velocity.x  *= -1;
      location.x = -limit;
    }
    if (location.z > limit) {
      velocity.z *= -1;
      location.z = limit;
    } else if (location.z < -limit) {
      velocity.z *= -1;
      location.z = -limit;
    }
  }
}