import processing.video.*;
import java.util.*;

/***************** SET THE IMAGE HERE *****************/
String imageName = "board1.jpg";

int numLines = 4;

color lineStroke = color(124);
color cornerFill = color(0);
color quadStroke = color(255);
color quadFill = color(0, 1);

Capture cam;
PImage img;
Filter f;
QuadGraph graph;
int minVotes = 1;

void settings() {
  //size(640, 480);
  size(800, 600);
  //fullScreen();
  noLoop();
}
void setup() {
  img = loadImage(imageName);
  graph = new QuadGraph();

  //String[] cameras = Capture.list();
  //if (cameras.length == 0) {
  //  println("There are no cameras available for capture.");
  //  exit();
  //} else {
  //  println("Available cameras:");
  //  for (int i = 0; i < cameras.length; i++) {
  //    println(cameras[i]);
  //  }
  //  cam = new Capture(this, cameras[0]);
  //  cam.start();
  //}
}


/* calculate the accumulator */
int[] hough(PImage edgeImg, int rDim, float discretizationStepsR, int phiDim, float discretizationStepsPhi) {
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  for (int i=0; i<accumulator.length; ++i) {
    accumulator[i] = 0;
  }

  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
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
  noStroke();
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      PVector v = intersection(line1, line2);
      intersections.add(v);
      fill(cornerFill);
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

void displayLine(PVector curr, PImage edgeImg){
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
  stroke(lineStroke);
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

/* display the lines */
void displayLines(ArrayList<PVector> lines, PImage edgeImg) {
  for (int idx = 0; idx < lines.size(); idx++) {
    PVector curr = lines.get(idx);
    displayLine(curr, edgeImg);
  }
}

void drawQuad(int[] quad, ArrayList<PVector> lines){
  if(quad.length == 4 && lines.size() > 0){
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    PVector c12 = intersection(l1, l2);
    PVector c23 = intersection(l2, l3);
    PVector c34 = intersection(l3, l4);
    PVector c41 = intersection(l4, l1);
    stroke(quadStroke);
    fill(quadFill);
    quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
  }
}

void drawQuads(List<int[]> quads, ArrayList<PVector> lines){
  for (int[] quad : quads) {
    drawQuad(quad, lines);
  }
}

int[] findMaxQuad(List<int[]> quads, ArrayList<PVector> lines){
  float bestArea = 0;
  int[] bestQuad = new int[4];
  for(int i=0; i<quads.size(); ++i){
    int[] currQuad = quads.get(i);
    float currArea = graph.area(lines.get(currQuad[0]), lines.get(currQuad[1]), lines.get(currQuad[2]), lines.get(currQuad[3]));
    if(currArea > bestArea){
      bestArea = currArea;
      bestQuad = currQuad;
    }
  }
  return bestQuad;
}



void draw() {
  //if (cam.available() == true) {
  //  cam.read();
  //}
  //img = cam.get();
  image(img, 0, 0);
  f = new Filter(img);
  f.apply();
  PImage edgeImg = f.result.copy();
  
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
  int[] acc = hough(edgeImg, rDim, discretizationStepsR, phiDim, discretizationStepsPhi);
  ArrayList<PVector> lines = findBestCandidates(acc, numLines, rDim, discretizationStepsR, phiDim, discretizationStepsPhi);

  displayLines(lines, edgeImg);
  ArrayList<PVector> corn = getIntersections(lines);
  
  graph.build(lines, img.width, img.height);
  graph.findCycles();
  List<int[]> quads = graph.filter( lines );
  //List<int[]> quads = graph.findCycles();
  drawQuad(findMaxQuad(quads, lines), lines);
}