class Mover {
  
  PVector location; /* location vector */
  PVector velocity; /* velocity vector */
  PVector gravity; /* gravity vector */
  PVector frict; /* friction vector */
  
  float bounce = 0.5; /* scale bounce off the wall (1 = no change on bounce) */

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
    float mu = 0.01;
    float frictmag = normal * mu;
    frict = velocity.copy();
    frict.normalize().mult(frictmag);

    /* gravity */
    float grav = 9.81; /* kinda fast, might change later */
    gravity.x = sin(rotz) * grav;
    gravity.z = sin(-rotx) * grav;
   
    velocity.add(gravity.mult(1.0/framerate)); /* update velocity : gravity scaled by deltaT (= 1/framerate) */
    location.add(velocity).add(frict.mult(-1)); /* update location : volocity, -friction */
  }
  
  /* draw sphere */
  void display() {
    noStroke();
    fill(ballc);
    translate(location.x, location.y, location.z);
    sphere(ballsize);
  }

  /* check propertirs on all edges, bounce off, don't go over */
  void checkEdges() {
    float limit = (boxsize/2.0); /* limit on x and z axis */
    
    /* x direction */
    if (location.x > limit) {
      velocity.x  *= -1*bounce;
      location.x = limit;
    } else if (location.x < -limit) {
      velocity.x  *= -1*bounce;
      location.x = -limit;
    }
    
    /* z direction */
    if (location.z > limit) {
      velocity.z *= -1*bounce;
      location.z = limit;
    } else if (location.z < -limit) {
      velocity.z *= -1*bounce;
      location.z = -limit;
    }
  }
}