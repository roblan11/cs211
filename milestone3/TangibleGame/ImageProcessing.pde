import processing.video.*;
import java.util.*;

class ImageProcessing {
  int mode = 0;

  PImage img;
  Filter f;
  QuadGraph graph = new QuadGraph();
  int minVotes = 130;
  TwoDThreeD t23 = new TwoDThreeD(windowWidth, windowHeight);
  PVector prev = new PVector(0, 0, 1);
  List<PVector> fQuad;
  
  ImageProcessing(){
    
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
    int neighbourhood = 12;
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate=true;
          for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) { 
            if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) { 
              continue;
            }
            for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) { 
              if (accR+dR < 0 || accR+dR >= rDim) { 
                continue;
              }
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
              if (accumulator[idx] < accumulator[neighbourIdx]) { 
                bestCandidate = false;
                break;
              }
            }
            if (!bestCandidate) { 
              break;
            }
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
      float r = (accR - (rDim - 1) / 2) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      acc1.add(new PVector(r, phi));
    }
    return acc1;
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
      }
    }
    return intersections;
  }

  int[] findMaxQuad(List<int[]> quads, ArrayList<PVector> lines) {
    float bestArea = 0;
    int[] bestQuad = new int[4];
    for (int i=0; i<quads.size(); ++i) {
      int[] currQuad = quads.get(i);
      float currArea = graph.area(lines.get(currQuad[0]), lines.get(currQuad[1]), lines.get(currQuad[2]), lines.get(currQuad[3]));
      if (currArea > bestArea) {
        bestArea = currArea;
        bestQuad = currQuad;
      }
    }
    return bestQuad;
  }

  List<PVector> getPvectorQuad(int[] quad, ArrayList<PVector> lines) {
    if (lines.size() > 0) {
      List<PVector> res = new ArrayList();
      for (int i : quad) {
        res.add(lines.get(i));
      }
      return res;
    }
    return new ArrayList<PVector>();
  }

  double radToDeg(float rad) {
    return rad*180/Math.PI;
  }

  void update() {
    if (useCam) {
      if (useVid) {
        mov.read();
        img = mov.get();
      } else {
        if (cam.available() == true) {
          cam.read();
        }
        img = cam.get();
      }
    }
    f = new Filter(img);
    f.apply();

    PImage edgeImg = f.result.copy();

    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f;
    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

    int[] acc = hough(edgeImg, rDim, discretizationStepsR, phiDim, discretizationStepsPhi);
    ArrayList<PVector> lines = findBestCandidates(acc, numLines, rDim, discretizationStepsR, phiDim, discretizationStepsPhi);

    graph.build(lines, img.width, img.height);
    List<int[]> quads = graph.findCycles();

    float min_area = img.width * img.height / 10;
    float max_area = img.width * img.height * 9/10;

    List<PVector> c = new ArrayList<PVector>();
    Boolean found = false;

    for (int[] quad : quads) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
      PVector l4 = lines.get(quad[3]);

      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      float area = graph.area(c12, c23, c34, c41);

      if ( area > min_area  && area < max_area
        && graph.isConvex(c12, c23, c34, c41)
        && graph.nonFlatQuad(c12, c23, c34, c41) ) {
        if (found) {
          c.set(0, c12);
          c.set(1, c23);
          c.set(2, c34);
          c.set(3, c41);
        } else {
          c.add(c12);
          c.add(c23);
          c.add(c34);
          c.add(c41);
        }
        found = true;
        min_area = area;
      }
    }

    if (found) {
      fQuad = graph.sortCorners(c);
    }

    if (fQuad != null) {
      prev = t23.get3DRotations(fQuad);
    }
  }
  
}