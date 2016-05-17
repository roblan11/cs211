class Ball {

  /* class variables */
  PVector location; /* ball location vector */
  PVector velocity; /* ball velocity vector */
  PVector gravity; /* gravity vector */
  PVector frict; /* friction vector */
  float limit = (boxSize/2.0); /* limit on x and z axis */

  Ball() {
    int y = 0; /* DO NOT CHANGE Y! */

    /* set up vectors, no movement along y axis */
    location = new PVector(0, y, 0);
    velocity = new PVector(0, y, 0);
    gravity  = new PVector(0, y, 0);
  }

  /* update vectors */
  void update() {

    /* friction */
    frict = velocity.copy();
    frict.normalize().mult(0.1);

    /* gravity */
    float grav = 9.81; /* kinda fast, might change later */
    gravity.x = sin(rotZ) * grav;
    gravity.z = sin(-rotX) * grav;

    velocity.add(gravity.copy().mult(1.0/framerate)).sub(frict); /* update velocity : gravity scaled by deltaT (= 1/framerate), -friction */
    location.add(velocity); /* update location : velocity */
  }

  /* draw sphere */
  void display() {
    noStroke();
    fill(ballC);
    translate(location.x, location.y, location.z);
    sphere(ballSize);
  }

  void updateScore(int c){
    scoreboard.last = c*velocity.mag();
    scoreboard.score += scoreboard.last;
    if(scoreboard.score < 0){
      scoreboard.score = 0;
    }
  }

  /* check properties on all edges, bounce off, don't go over */
  void checkEdges() {    
    /* x direction */
    if (location.x > limit) {
      updateScore(-1);
      velocity.x  *= -1;
      location.x = limit;
    } else if (location.x < -limit) {
      updateScore(-1);
      velocity.x  *= -1;
      location.x = -limit;
    }

    /* z direction */
    if (location.z > limit) {
      updateScore(-1);
      velocity.z *= -1;
      location.z = limit;
    } else if (location.z < -limit) {
      updateScore(-1);
      velocity.z *= -1;
      location.z = -limit;
    }
  }

  /* compute the distance of 2 vectors */
  float distance(PVector v1, PVector v2) {
    return sqrt( (v1.x - v2.x)*(v1.x - v2.x) + (v1.z - v2.z)*(v1.z - v2.z) );
  }

  /* check properties on all cylinders, bounce off, don't go in */
  void checkCylinderCollision() {
    for (int i=0; i<cylinder.list.size(); ++i) {
      PVector curr = cylinder.list.get(i);
      float differenceX = borderVer + limit;
      float differenceY = borderHor + limit;
      PVector cyl = new PVector( (curr.x - differenceX), 0, (curr.y - differenceY) );

      if ( distance(location, cyl) < (cylinderBaseSize + ballSize) ) {
        PVector n = new PVector( (location.x - cyl.x), 0, (location.z - cyl.z) ).normalize();

        velocity.sub( n.copy().mult( (velocity.dot(n)) * 2) );
        location = cyl.add(n.copy().mult( (cylinderBaseSize + ballSize) ));
        
        updateScore(1);
  
        if(removeTrees){
          cylinder.list.remove(i);
          --i;
        }
      }
    }
  }
}