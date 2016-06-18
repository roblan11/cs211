class Filter {
  PImage img;
  PImage src;
  PImage result;

  Filter(PImage image) {
    src = image.copy();
    result = createImage(src.width, src.height, RGB);
  }
  
  /* proper collection of kernels with constants to call them */
  int DEFAULT = 1;
  int GRAIN = 2;
  int GAUSS3 = 3;
  int GAUSS5 = 6;
  int HKERNEL = 4;
  int VKERNEL = 5;

  float[][] kC(int i) {
    switch(i) {
      case 2:
        float[][] grain = {{ 0, 1, 0 }, 
                           { 1, 0, 1 }, 
                           { 0, 1, 0 }};
        return grain;
      case 3:
        float[][] gauss3 = {{ 9, 12, 9 }, 
                            {12, 15, 12 }, 
                            { 9, 12, 9 }};
        return gauss3;
      case 4:
        float[][] hKernel = {{ 0, 1, 0 }, 
                             { 0, 0, 0 }, 
                             { 0, -1, 0 }};
        return hKernel;
      case 5:
        float[][] vKernel = {{ 0, 0, 0 }, 
                             { 1, 0, -1 }, 
                             { 0, 0, 0 }};
        return vKernel;
      case 6:
        float[][] gauss5 = {{ 3, 5, 9, 5, 3 }, 
                            { 5, 9, 12, 9, 5 }, 
                            { 9, 12, 15, 12, 9 }, 
                            { 5, 9, 12, 9, 5 }, 
                            { 3, 5, 9, 5, 3 }};
        return gauss5;
      default:
        float[][] other = {{ 0, 0, 0 }, 
                           { 0, 1, 0 }, 
                           { 0, 0, 0 }};
        return other;
    }
  }
  
  /* update the images to continue computations */
  void update() {
    result.updatePixels();
    img = result.copy();
    img.updatePixels();
  }
  
  /************************************** filters **************************************/
  
  void threshold_binary(int limit) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) < limit) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = color(255);
      }
    }
    update();
  }

  void threshold_binary_inverted(int limit) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) < limit) {
        result.pixels[i] = color(255);
      } else {
        result.pixels[i] = color(0);
      }
    }
    update();
  }

  void truncate(int limit) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) < limit) {
        result.pixels[i] = img.pixels[i];
      } else {
        result.pixels[i] = color(limit);
      }
    }
    update();
  }

  void truncate_inverted(int limit) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) > limit) {
        result.pixels[i] = img.pixels[i];
      } else {
        result.pixels[i] = color(limit);
      }
    }
    update();
  }

  void threshold_to_zero(int limit) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) < limit) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = img.pixels[i];
      }
    }
    update();
  }

  void threshold_to_zero_inverted(int limit) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) < limit) {
        result.pixels[i] = img.pixels[i];
      } else {
        result.pixels[i] = color(0);
      }
    }
    update();
  }

  void convert_hue() {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      result.pixels[i] = color((int)hue(img.pixels[i]));
    }
    update();
  }

  void clamp_hue(int min, int max) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      float hue = hue(img.pixels[i]);
      if ( (hue < min) || (hue > max) ) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = img.pixels[i];
      }
    }
    update();
  }
  
  void clamp_bright(int min, int max) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      float br = brightness(img.pixels[i]);
      if ( (br < min) || (br > max) ) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = img.pixels[i];
      }
    }
    update();
  }
  
  void clamp_sat(int min, int max) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      float sat = saturation(img.pixels[i]);
      if ( (sat < min) || (sat > max) ) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = img.pixels[i];
      }
    }
    update();
  }

  void saturation_threshold(int min) {
    for (int i = 0; i < img.width * img.height; i++) {
      if ( saturation(img.pixels[i]) < min ) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = color(255);
      }
    }
    update();
  }

  void convolute(float[][] kernel, int weight) {
    int N = kernel.length;
    if (weight < 1) { 
      weight = 1;
    }
    int h = N/2;
    for (int i = h; i < result.width - h; i++) {
      for (int j = h; j < result.height - h; j++) {
        float sum = 0;
        for (int k = 0; k < N; ++k) {
          for (int l = 0; l < N; ++l) {
            int curr = (j-h+l)*img.width + i-h+k;
            sum += brightness(img.pixels[curr])*kernel[k][l];
          }
        }
        int col = Math.round(min(sum/weight, 255));
        result.pixels[j*img.width + i] = color(col);
      }
    }
    update();
  }

  void sobel() {
    
    float[][] hKernel = kC(HKERNEL);
    float[][] vKernel = kC(VKERNEL);

    float max=0;
    float[] buffer = new float[img.width * img.height];

    PImage result2 = createImage(img.width, img.height, ALPHA);
    for (int i = 1; i < result2.width - 1; i++) {
      for (int j = 1; j < result2.height - 1; j++) {
        float sum_h = 0;
        float sum_v = 0;
        for (int k = 0; k < 3; ++k) {
          for (int l = 0; l < 3; ++l) {
            int curr = (j-1+l)*img.width + i-1+k;
            sum_h += img.pixels[curr]*hKernel[k][l];
            sum_v += img.pixels[curr]*vKernel[k][l];
          }
        }
        float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        if (max < sum) {
          max = sum;
        }
        buffer[j * img.width + i] = sum;
      }
    }

    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges 
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max 
          result.pixels[y * img.width + x] = color(255);
        } else {
          result.pixels[y * img.width + x] = color(0);
        }
      }
    }
    update();
  }
  
  
  /* apply the filters on result */
  void apply() {
    img = src.copy();    
    clamp_hue(80, 130);
    clamp_bright(50, 180);
    clamp_sat(80, 255);
    convolute(kC(GAUSS5), 40);
    clamp_bright(100, 255);
    sobel();
  }
  
  /* display result at (x, y) */
  void display(int x, int y) {
    image(result, x, y);
  }
}