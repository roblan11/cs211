class Filter {
  PImage img;
  PImage result;
  Filter(){
    img = loadImage("board1.jpg");
    result = createImage(width, height, RGB);
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

  PImage convolute(PImage img, float[][] kernel) {
    int N = 3;
    float weight = 1;
    PImage result = createImage(img.width, img.height, ALPHA);
    int sum = 0;
    for (int i = N/2; i < result.width - N/2; i++) {
      for (int j = N/2; j < result.height - N/2; j++) {
        for (int k = 0; k < N; ++k) {
          for (int l = 0; l < N; ++l) {
            sum += img.pixels[(j-N/2+l) * img.width + i-N/2+k]*kernel[k][l];
          }
        }
        if (sum < 0) { 
          sum = 0;
        }
        result.pixels[j*img.width + i] = color((int)(sum / weight));
        sum = 0;
      }
    }
    return result;
  }

  PImage sobel(PImage img) {

    float[][] hKernel = { { 0, 1, 0 }, {0, 0, 0}, 
      { 0, -1, 0 } };
    float[][] vKernel = { { 0, 0, 0 }, {1, 0, -1}, 
      {0, 0, 0 }};

    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
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
    return result;
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

  void display() {
    //background(color(0, 0, 0));

    //limit1 = (int)(scrollbar.getPos()*255);
    //limit2 = (int)(scrollbar2.getPos()*255);

    //clamp_hue(limit1, limit2);
    //image(result, 0, 0);
    //scrollbar.update();
    //scrollbar.display();
    //scrollbar2.update();
    //scrollbar2.display();

    image(sobel(img), 0, 0);
  }
}