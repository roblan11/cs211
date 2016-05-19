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
        float[][] gauss5 = {{ 1, 4, 7, 4, 1 }, 
                            { 4, 16, 26, 16, 4 }, 
                            { 7, 26, 41, 26, 7 }, 
                            { 4, 16, 26, 16, 4 }, 
                            { 1, 4, 7, 4, 1 }};
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
      int hue = (int)hue(img.pixels[i]);
      if ( (hue < min) || (hue > max) ) {
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

  void convolute(float[][] kernel) {
    int N = kernel.length;
    int weight = 0;
    for (int i=0; i<N; ++i) {
      for (int j=0; j<N; ++j) {
        weight += kernel[i][j];
      }
    }
    if (weight < 1) { 
      weight = 1;
    }

    int r = 0;
    int g = 0;
    int b = 0;
    for (int i = N/2; i < result.width - N/2; i++) {
      for (int j = N/2; j < result.height - N/2; j++) {
        for (int k = 0; k < N; ++k) {
          for (int l = 0; l < N; ++l) {
            r += red(img.pixels[(j-N/2+l)*img.width + i-N/2+k])*kernel[k][l];
            g += green(img.pixels[(j-N/2+l)*img.width + i-N/2+k])*kernel[k][l];
            b += blue(img.pixels[(j-N/2+l)*img.width + i-N/2+k])*kernel[k][l];
          }
        }
        result.pixels[j*img.width + i] = color(r/weight, g/weight, b/weight);
        r = 0; 
        g = 0; 
        b = 0;
      }
    }
    update();
  }

  void sobel() {
    
    float[][] hKernel = kC(HKERNEL);
    float[][] vKernel = kC(VKERNEL);

    float max=0;
    float[] buffer = new float[img.width * img.height];

    int N = 3;
    PImage result2 = createImage(img.width, img.height, ALPHA);
    float sum_h = 0;
    float sum_v = 0;
    float sum = 0;
    for (int i = N/2; i < result2.width - N/2; i++) {
      for (int j = N/2; j < result2.height - N/2; j++) {
        for (int k = 0; k < N; ++k) {
          for (int l = 0; l < N; ++l) {
            sum_h += img.pixels[(j-N/2+l) * img.width + i-N/2+k]*hKernel[k][l];
            sum_v += img.pixels[(j-N/2+l) * img.width + i-N/2+k]*vKernel[k][l];
          }
        }
        sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        if (max < sum) {
          max = sum;
        }
        buffer[j * img.width + i] = sum;
        sum_h = 0;
        sum_v = 0;
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
    truncate(176);
    truncate_inverted(26);
    clamp_hue(90, 135);
    saturation_threshold(60);
    convolute(kC(GAUSS5));
    threshold_to_zero(150);
    sobel();
  }
  
  /* display result at (x, y) */
  void display(int x, int y) {
    image(result, x, y);
  }
}