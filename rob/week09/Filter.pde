class Filter {
  PImage img;
  PImage src;
  PImage result;

  Filter(PImage image) {
    src = image.copy();
    result = createImage(src.width, src.height, RGB);
  }

  void threshold_binary(int limit) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) < limit) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = color(255);
      }
    }
    result.updatePixels();
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
    result.updatePixels();
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
    result.updatePixels();
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
    result.updatePixels();
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
    result.updatePixels();
  }

  void convert_hue() {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      result.pixels[i] = color((int)hue(img.pixels[i]));
    }
    result.updatePixels();
  }

  void clamp_hue(int min, int max) {
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      int hue = (int)hue(img.pixels[i]);
      if ( (hue < min) || (hue > max) ) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = color(255);
      }
    }
    result.updatePixels();
  }

  void convolute(float[][] kernel) {
    int N = 3;
    int weight = 0;
    for (int i=0; i<N; ++i) {
      for (int j=0; j<N; ++j) {
        weight += kernel[i][j];
      }
    }
    if (weight < 1) { 
      weight = 1;
    }
    int sum = 0;
    for (int i = N/2; i < result.width - N/2; i++) {
      for (int j = N/2; j < result.height - N/2; j++) {
        for (int k = 0; k < N; ++k) {
          for (int l = 0; l < N; ++l) {
            sum += img.pixels[(j-N/2+l)*img.width + i-N/2+k]*kernel[k][l];
          }
        }
        result.pixels[j*img.width + i] = sum / weight;
        sum = 0;
      }
    }
    result.updatePixels();
  }

  void sobel() {

    float[][] hKernel = { { 0, 1, 0 }, {0, 0, 0}, 
      { 0, -1, 0 } };
    float[][] vKernel = { { 0, 0, 0 }, {1, 0, -1}, 
      {0, 0, 0 }};

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
    result.updatePixels();

    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges 
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max 
          result.pixels[y * img.width + x] = color(255);
        } else {
          result.pixels[y * img.width + x] = color(0);
        }
      }
    }
    result.updatePixels();
  }

  int DEFAULT = 1;
  int GRAIN = 2;
  int GAUSS = 3;
  int HKERNEL = 4;
  int VKERNEL = 5;

  float[][] kC(int i) {
    switch(i) {
    case 2:
      float[][] kernel2 = {{ 0, 1, 0 }, 
        { 1, 0, 1 }, 
        { 0, 1, 0 }};
      return kernel2;
    case 3:
      float[][] gauss = {{ 9, 12, 9 }, 
        {12, 15, 12 }, 
        { 9, 12, 9 }};
      return gauss;
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
    default:
      float[][] kernel1 = {{ 0, 0, 0 }, 
        { 0, 1, 0 }, 
        { 0, 0, 0 }};
      return kernel1;
    }
  }

  void swapAndClear() {
    img = result.copy();
    for (int i=0; i<result.pixels.length; ++i) {
      result.pixels[i] = color(0);
    }
    img.updatePixels();
    result.updatePixels();
  }

  void apply() {
    img = src.copy();
    clamp_hue(115, 133);
    swapAndClear();
    //convolute(kC(GAUSS));
    //swapAndClear();
    convolute(kC(HKERNEL));
    swapAndClear();
    convolute(kC(VKERNEL));
    swapAndClear();
    sobel();
  }

  void display() {
    apply();
    image(result, 0, 0);
  }
}