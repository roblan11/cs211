import java.util.*;

/***************** SET THE IMAGE HERE *****************/
String imageName = "board1.jpg";

PImage img;
Filter f;
QuadGraph graph; /* necessary? */
int minVotes = 200;

void settings() {
  size(2000, 600);
}

void setup() {
  img = loadImage(imageName);
  graph = new QuadGraph();
}

/* calculate the accumulator */
int[] hough(PImage edgeImg, int rDim, float discretizationStepsR, int phiDim, float discretizationStepsPhi) {
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
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

/* find the best candidates from the accumulator */
ArrayList<PVector> findBestCandidates(int[] accumulator, int nLines, int rDim, float discretizationStepsR, int phiDim, float discretizationStepsPhi) {
  ArrayList<Integer> bestCandidates = new ArrayList();
  int neighbourhood = 10;
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) { 
          if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) { continue; }
          for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) { 
            if (accR+dR < 0 || accR+dR >= rDim) { continue; }
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if (accumulator[idx] < accumulator[neighbourIdx]) { 
              bestCandidate = false;
              break;
            }
          }
          if (!bestCandidate) { break; }
        }
        if (bestCandidate) {
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

/* find the intersection between 2 lines */
PVector intersection(PVector line1, PVector line2) {
  float d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
  float x = ( line2.x*sin(line1.y) - line1.x*sin(line2.y))/d;
  float y = (-line2.x*cos(line1.y) + line1.x*cos(line2.y))/d;
  return new PVector(x, y);
}

/* find the intersections between lines */
ArrayList<PVector> getIntersections(List<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      PVector v = intersection(line1, line2);
      intersections.add(v);
      fill(255, 128, 0);
      ellipse(v.x, v.y, 10, 10);
    }
  }
  return intersections;
}

/* display the accumulator */
PImage displayAcc(int[] accumulator, int rDim, int phiDim) {
  PImage houghImg = createImage(rDim+2, phiDim+2, ALPHA); 
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  houghImg.resize(400, 600);
  houghImg.updatePixels();
  return houghImg;
}

/* display the lines */
void displayLines(ArrayList<PVector> lines, PImage edgeImg) {
  for (int idx = 0; idx < lines.size(); idx++) {
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

void drawQuads(List<int[]> quads, ArrayList<PVector> lines){
  for (int[] quad : quads) {
  PVector l1 = lines.get(quad[0]);
  PVector l2 = lines.get(quad[1]);
  PVector l3 = lines.get(quad[2]);
  PVector l4 = lines.get(quad[3]);
  PVector c12 = intersection(l1, l2);
  PVector c23 = intersection(l2, l3);
  PVector c34 = intersection(l3, l4);
  PVector c41 = intersection(l4, l1);
  // Choose a random, semi-transparent colour
  Random random = new Random();
  fill(color(min(255, random.nextInt(300)), 
    min(255, random.nextInt(300)), 
    min(255, random.nextInt(300)), 50));
  quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
  }
}

void draw() {
  image(img, 0, 0);
  f = new Filter(img);
  f.apply();
  PImage edgeImg = f.result.copy();
  
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
  int[] acc = hough(edgeImg, rDim, discretizationStepsR, phiDim, discretizationStepsPhi);
  ArrayList<PVector> lines = findBestCandidates(acc, 4, rDim, discretizationStepsR, phiDim, discretizationStepsPhi);

  displayLines(lines, edgeImg);
  getIntersections(lines);
  image(displayAcc(acc, rDim, phiDim), 800, 0);
  f.display(1200, 0);
  
  graph.build(lines, width, height);
  List<int[]> quads = graph.filter(graph.findCycles());
  drawQuads(quads, lines);
}