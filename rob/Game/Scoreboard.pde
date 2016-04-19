class Scoreboard{
  /* class variables */
  float score = 0; /* current score */
  float last = 0; /* last score change */
  
  ArrayList<Float> list = new ArrayList();
  
  PGraphics dataB;
  PGraphics topView;
  PGraphics scores;
  PGraphics barChart;
  PGraphics infoBar;
  boolean moveBoard = true;
  int counter = framerate;
  int curMaxScore = 1;
  float squareSizeX;
  float squareSizeY = statGraphBaseBoxSize;
  int numBoxes = (statSize - 2*statBorder)/(int)squareSizeY;
  int graphWidth = (windowWidth - statSize*3/2 - 4*statBorder);
    
  Scoreboard(){
    dataB = createGraphics(windowWidth, statSize + 2*statBorder, P2D);
    topView = createGraphics(statSize, statSize, P2D);
    scores = createGraphics(statSize/2, statSize, P2D);
    barChart = createGraphics((windowWidth - statSize*3/2 - 4*statBorder), statSize - 2*statBorder, P2D);
    infoBar = createGraphics((windowWidth/2 - statSize*3/4 - 3*statBorder), 2*statBorder, P2D);
  }
  
  void display(){
    noFill();
    noLights();
    drawData();
    image(dataB, 0, windowHeight - (statSize + 2*statBorder));
    drawTop();
    image(topView, statBorder, (windowHeight - statSize - statBorder));
    drawScores();
    image(scores, (statSize + 2*statBorder), (windowHeight - statSize - statBorder));
    drawChart();
    image(barChart, (statSize*3/2 + 3*statBorder), (windowHeight - statSize - statBorder));
    addInfo();
    image(infoBar, (statSize*3/4 + statBorder*2 + windowWidth/2), windowHeight - (statBorder*5/2));
    scrollBar.update();
    scrollBar.display();
  }
  
  /* information about the current value of 1 box and the current max in the graph */
  void addInfo(){
    infoBar.beginDraw();
    infoBar.background(dataBackC);
    infoBar.textFont(f);
    infoBar.textSize(statBorder*3/2);
    infoBar.fill(ballC);
    infoBar.rect(statGraphBaseBoxSize*2 - squareSizeX, (statBorder*2 - squareSizeY)/2, squareSizeX, squareSizeY);
    infoBar.fill(dataScoreTextC);
    infoBar.textAlign(LEFT);
    infoBar.text(" = " + ceil(curMaxScore/(float)numBoxes), 2*statGraphBaseBoxSize, statBorder*3/2);
    infoBar.textAlign(RIGHT);
    infoBar.text("max display: " + curMaxScore, (windowWidth/2 - statSize*3/4 - 3*statBorder), statBorder*3/2);
    infoBar.endDraw();
  }
  
  void drawChart(){
    barChart.beginDraw();
    barChart.background(dataBoxC);
    barChart.fill(ballC);
    barChart.stroke(255);
    squareSizeX = statGraphBaseBoxSize*(scrollBar.getPos() + 0.5);
    /* change to right side on fill-up */
    if(list.size() > floor(graphWidth/squareSizeX)){
      for(int i = 0; i < floor(graphWidth/squareSizeX) + 1; ++i){
        for(int j = 0; j*squareSizeY <= statSize - 2*statBorder; ++j){
          if(j < list.get(list.size() - 1 - i)*numBoxes/curMaxScore){
            barChart.rect(( graphWidth - ceil((i+1)*squareSizeX)), statSize - 2*statBorder - j*squareSizeY, squareSizeX, squareSizeY);
          }
        }
      }
    } else {
      for(int i = 0; i < floor(graphWidth/squareSizeX); ++i){
        for(int j = 0; j*squareSizeY <= statSize - 2*statBorder; ++j){
          if(i < list.size() && j < list.get(i)*numBoxes/curMaxScore){
            barChart.rect(i*squareSizeX, statSize - 2*statBorder - j*squareSizeY, squareSizeX, squareSizeY);
          }
        }
      }
    }
    barChart.endDraw();
    if(!addMode){
      if(counter < framerate/2){
        ++counter;
      } else {
        counter = 0;
        list.add(score);
        if(score > curMaxScore){
          curMaxScore = (int)score;
        }
      }
    }
  }
  
  void drawScores() {
    scores.beginDraw();
    scores.background(dataBackC);
    scores.textFont(f);
    scores.textSize(statSize/12);
    scores.textAlign(CENTER);
    scores.fill(dataScoreTextC);
    scores.text("score", statSize/4, statSize/4 - 10);
    scores.text(score, statSize/4, statSize/4 + 10);
    scores.text("velocity", statSize/4, statSize/2 - 10);
    scores.text(ball.velocity.mag(), statSize/4, statSize/2 + 10);
    scores.text("last change", statSize/4, statSize*3/4 - 10);
    scores.text(last, statSize/4, statSize*3/4 + 10);
    scores.endDraw();
  }
  
  void drawData() {
    dataB.beginDraw();
    dataB.background(dataBackC);
    dataB.endDraw();
  }
  
  void drawTop() {
    topView.beginDraw();
    topView.noStroke();
    topView.background(dataBoxC);
    float topBall = ballSize*2*statSize/boxSize;
    float topCyl = cylinderBaseSize*2*statSize/boxSize;
    topView.fill(ballC);
    topView.ellipse((ball.location.x + ball.limit)*statSize/boxSize, 
                    (ball.location.z + ball.limit)*statSize/boxSize, 
                    topBall, topBall);
    topView.fill(cylinderC);
    for (PVector i : cylinder.list) {
      topView.ellipse((i.x - windowWidth/2 + boxSize)*statSize/boxSize - statSize/2, 
                      (i.y - windowHeight/2)*statSize/boxSize + statSize/2, 
                      topCyl, topCyl);
    }
    topView.endDraw();
  }
}