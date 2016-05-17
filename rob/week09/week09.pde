import processing.video.*;
import java.util.*;

Capture cam;
PImage img;
Filter f;
QuadGraph graph;
int minVotes = 200;

void settings() {
  //size(640, 480);
  size(800, 600);
  //fullScreen();
}
void setup() {
  img = loadImage("board1.jpg");
  graph = new QuadGraph();

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


ArrayList<PVector> hough(PImage edgeImg, int nLines) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin)
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

  ArrayList<Integer> bestCandidates = new ArrayList();

  for (int i=0; i<accumulator.length; ++i) {
    if (accumulator[i] > minVotes) {
      bestCandidates.add(i);
    }
  }

  // size of the region we search for a local maximum
  int neighbourhood = 10;
  // only search around lines with more than this amount of votes // (to be adapted to your image)
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) { // check we are not outside the image
          if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            // check we are not outside the image
            if (accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if (accumulator[idx] < accumulator[neighbourIdx]) { // the current idx is not a local maximum! bestCandidate=false;
              break;
            }
          }
          if (!bestCandidate) break;
        }
        if (bestCandidate) {
          // the current idx *is* a local maximum
          bestCandidates.add(idx);
        }
      }
    }
  }

  Collections.sort(bestCandidates, new HoughComparator(accumulator));

  ArrayList<PVector> acc1 = new ArrayList();
  for (int i=0; i<min(bestCandidates.size(), nLines); ++i) {
    int idx = bestCandidates.get(i);
    int accPhi = (int) (idx / (rDim + 2)) - 1;
    int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
    float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    acc1.add(new PVector(r, phi));
  }
  return acc1;
}

ArrayList<PVector> getIntersections(List<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      // compute the intersection and add it to ’intersections’
      float d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
      float x = ( line2.x*sin(line1.y) - line1.x*sin(line2.y))/d;
      float y = (-line2.x*cos(line1.y) + line1.x*cos(line2.y))/d;
      // draw the intersection
      fill(255, 128, 0);
      ellipse(x, y, 10, 10);
    }
  }
  return intersections;
}

PVector intersection(PVector line1, PVector line2) {
  float d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
  float x = ( line2.x*sin(line1.y) - line1.x*sin(line2.y))/d;
  float y = (-line2.x*cos(line1.y) + line1.x*cos(line2.y))/d;
  return new PVector(x, y);
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
  f.display();
  PImage edgeImg = f.result.copy();
  // /!\ NLINES == 8  
  ArrayList<PVector> lines = hough(edgeImg, 8);

  for (int idx = 0; idx < lines.size(); idx++) {
    // first, compute back the (r, phi) polar coordinates:
    PVector curr = lines.get(idx);
    float r = curr.x;
    float phi = curr.y;
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
  getIntersections(lines);

  //graph.build(lines, width, height);
  //List<int[]> quads = graph.filter(graph.findCycles());

  //for (int[] quad : quads) {
  // PVector l1 = lines.get(quad[0]);
  // PVector l2 = lines.get(quad[1]);
  // PVector l3 = lines.get(quad[2]);
  // PVector l4 = lines.get(quad[3]);
  // // (intersection() is a simplified version of the
  // // intersections() method you wrote last week, that simply
  // // return the coordinates of the intersection between 2 lines) 
  // PVector c12 = intersection(l1, l2);
  // PVector c23 = intersection(l2, l3);
  // PVector c34 = intersection(l3, l4);
  // PVector c41 = intersection(l4, l1);
  // // Choose a random, semi-transparent colour
  // Random random = new Random();
  // fill(color(min(255, random.nextInt(300)), 
  //   min(255, random.nextInt(300)), 
  //   min(255, random.nextInt(300)), 50));
  // quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
  //}
}