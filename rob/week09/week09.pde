import processing.video.*;

Capture cam;
PImage img;
Filter f;

void settings() {
  size(640, 480);
}
void setup() {
  img = loadImage("board1.jpg");

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
   println("There are no cameras available for capture.");
   exit();
  } else {
   println("Available cameras:");
   for (int i = 0; i < cameras.length; i++) {
     println(cameras[i]);
   }
   cam = new Capture(this, cameras[0]);
   cam.start();
  }
}


int[] hough(PImage edgeImg) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  // Fill the accumulator: on edge points (ie, white pixels of the edge // image), store all possible (r, phi) pairs describing lines going // through the point.
  for (int i=0; i<accumulator.length; ++i) {
    accumulator[i] = 0;
  }

  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

        for (float phi = 0; phi < Math.PI; phi += discretizationStepsPhi) {
          float r = x * cos(phi) + y * sin(phi);
          r /= discretizationStepsR;
          r += (rDim - 1)/2;
          accumulator[(int)((1+phi/discretizationStepsPhi)*(rDim + 2) + (r + 1))] += 1;
        }
      }
    }
  }
  return accumulator;
}

PImage displayAcc(int[] accumulator, int rDim, int phiDim) {
  PImage houghImg = createImage(rDim+2, phiDim+2, ALPHA); 
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(400, 400);
  houghImg.updatePixels();
  return houghImg;
}


void draw() {
  if (cam.available() == true) {
   cam.read();
  }
  //img = cam.get();
  image(img, 0, 0);
  f = new Filter(img);
  f.apply();
  PImage edgeImg = f.result.copy();
  f.display();
  int[] accumulator = hough(edgeImg);

  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
  //image(displayAcc(accumulator, rDim, phiDim), 0, 0);

  //image(displayAcc(accumulator, rDim, phiDim), 0, 0);

  //image(edgeImg, 0, 0);
  
  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > 200) {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }
  
  //image(displayAcc(accumulator, rDim, phiDim), 0, 0);
}