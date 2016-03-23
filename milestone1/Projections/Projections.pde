void settings() {
  size(1000, 1000, P2D);
}

void setup() {
  background(0);
}

void draw() {

  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  
  //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();
  
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();
  
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

class My2DPoint{
  float x;
  float y;
  My2DPoint(float x, float y){
    this.x = x;
    this.y = y;
  }
}

class My3DPoint{
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p){
  //  P*T ==
  //  [  1  0  0      -ex  ]
  //  [  0  1  0      -ey  ]
  //  [  0  0  1      -ez  ]
  //  [  0  0  -1/ez   1    ]
  // 
  float[] res = new float[4]; 
  res[0] = (p.x - eye.x);
  res[1] = (p.y - eye.y);
  res[2] = (p.z - eye.z);
  res[3] = (-p.z/eye.z + 1);
  return new My2DPoint(res[0]/res[3], res[1]/res[3]);
}

class My2DBox{
  My2DPoint[] s;
  My2DBox(My2DPoint[] s){
    this.s = s;
  }
  void render(){
    strokeWeight(3);
    stroke(0, 0, 255);
    line(s[4].x, s[4].y, s[5].x, s[5].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[7].x, s[7].y);
    line(s[7].x, s[7].y, s[4].x, s[4].y);
    stroke(0, 255, 0);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    stroke(255, 0, 0);
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[1].x, s[1].y, s[2].x, s[2].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[3].x, s[3].y, s[0].x, s[0].y);
  }
}

class My3DBox{
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x,y+dimY,z+dimZ),
                             new My3DPoint(x,y,z+dimZ),
                             new My3DPoint(x+dimX,y,z+dimZ),
                             new My3DPoint(x+dimX,y+dimY,z+dimZ),
                             new My3DPoint(x,y+dimY,z),
                             origin,
                             new My3DPoint(x+dimX,y,z),
                             new My3DPoint(x+dimX,y+dimY,z)
                           };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DBox projectBox(My3DPoint eye, My3DBox box){
  My2DPoint[] res = new My2DPoint[8];
  My3DPoint[] b = box.p;
  for(int i=0; i<8; ++i){
    res[i] = projectPoint(eye, b[i]);
  }
  return new My2DBox(res);
}

float[] homogeneous3DPoint(My3DPoint p) {
  float[] result = {p.x, p.y, p.z , 1};
  return result;
}

float[][]  rotateXMatrix(float angle) {
  return(new float[][] {{1, 0 , 0 , 0},
                        {0, cos(angle), sin(angle) , 0},
                        {0, -sin(angle) , cos(angle) , 0},
                        {0, 0 , 0 , 1}});
}

float[][] rotateYMatrix(float angle) { 
  return(new float[][] {{cos(angle), 0, sin(angle), 0}, 
                        {0, 1, 0, 0},
                        {-sin(angle), 0, cos(angle), 0}, 
                        {0, 0, 0, 1}});
}

float[][] rotateZMatrix(float angle) { 
  return(new float[][] {{cos(angle), -sin(angle), 0, 0}, 
                        {sin(angle), cos(angle), 0, 0},
                        {0, 0, 1, 0}, 
                        {0, 0, 0, 1}});
}

float[][] scaleMatrix(float x, float y, float z) { 
  return(new float[][] {{x, 0, 0, 0}, 
                        {0, y, 0, 0},
                        {0, 0, z, 0}, 
                        {0, 0, 0, 1}});
}

float[][] translationMatrix(float x, float y, float z) { 
  return(new float[][] {{1, 0, 0, x}, 
                        {0, 1, 0, y},
                        {0, 0, 1, z}, 
                        {0, 0, 0, 1}});
}

float[] matrixProduct(float[][] a, float[] b) {
  int max = b.length;
  float[] res = new float[max];
  for(int i=0; i<max; ++i){
    float cur = 0;
    for(int j=0; j<max; ++j){
      cur += a[i][j]*b[j];
    }
    res[i] = cur;
  }
  return res;
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] b = box.p;
  My3DPoint[] res = new My3DPoint[8];
  for(int i=0; i<8; ++i){
    res[i] = euclidian3DPoint(matrixProduct(transformMatrix,
                                            homogeneous3DPoint(b[i])));
  }
  return new My3DBox(res);
}