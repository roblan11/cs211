class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  Mover() {
    location = new PVector(width/2, height/2);
    velocity = new PVector(0, 10);
    gravity = new PVector(0, 3);
  }
  void update() {
    velocity.add(gravity);
    location.add(velocity);
  }
  void display() {
    stroke(0);
    strokeWeight(2);
    fill(127);
    ellipse(location.x, location.y, 48, 48);
  }
  void checkEdges() {
    if (location.x > width) {
      velocity.x  *= -1;
      location.x = width;
    } else if (location.x < 0) {
      velocity.x  *= -1;
      location.x = 0;
    }
    if (location.y > height) {
      velocity.y *= -1;
      location.y = height;
    } else if (location.y < 0) {
      velocity.y *= -1;
      location.y = 0;
    }
  }
}