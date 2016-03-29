class Mover {

  /* class variables */
  PVector location; /* location vector */
  PVector velocity; /* velocity vector */
  PVector gravity; /* gravity vector */
  PVector frict; /* friction vector */

  float limit = (boxSize/2.0); /* limit on x and z axis */

  Mover() {
    int y = 0; /* DO NOT CHANGE Y! */

    /* set up vectors, no movement along y axis */
    location = new PVector(0, y, 0);
    velocity = new PVector(0, y, 0);
    gravity  = new PVector(0, y, 0);
  }

  /* update vectors */
  void update() {

    /* friction */
    float normal = 1;
    float mu = 0.15;
    float frictmag = normal * mu;
    frict = velocity.copy();
    frict.normalize().mult(frictmag);

    /* gravity */
    float grav = 9.81; /* kinda fast, might change later */
    gravity.x = sin(rotZ) * grav;
    gravity.z = sin(-rotX) * grav;

    velocity.add(gravity.mult(1.0/framerate)).sub(frict); /* update velocity : gravity scaled by deltaT (= 1/framerate) */
    location.add(velocity); /* update location : velocity, -friction */
  }

  /* draw sphere */
  void display() {
    noStroke();
    fill(ballC);
    translate(location.x, location.y, location.z);
    sphere(ballSize);
  }

  /* check properties on all edges, bounce off, don't go over */
  void checkEdges() {    
    /* x direction */
    if (location.x > limit) {
      velocity.x  *= -1;
      location.x = limit;
    } else if (location.x < -limit) {
      velocity.x  *= -1;
      location.x = -limit;
    }

    /* z direction */
    if (location.z > limit) {
      velocity.z *= -1;
      location.z = limit;
    } else if (location.z < -limit) {
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
    for (int i=0; i<cylinders.size(); ++i) {
      PVector curr = cylinders.get(i);
      float difference = border + limit;
      PVector cyl = new PVector( (curr.x - difference), 0, (curr.y - difference) );

      if ( distance(location, cyl) <= (cylinderBaseSize + ballSize) ) {
        PVector n = new PVector( (location.x - cyl.x), 0, (location.z - cyl.z) ).normalize();

        velocity.sub( n.copy().mult( (velocity.dot(n)) * 2) );
        location = cyl.add(n.copy().mult( (cylinderBaseSize + ballSize) ));
  
        if(removeTrees){
          cylinders.remove(i);
          --i;
        }
      }
    }
  }
}