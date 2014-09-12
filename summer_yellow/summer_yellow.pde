import gab.opencv.*; //https://github.com/atduskgreg/opencv-processing
import processing.video.*; //p5

import controlP5.*; //http://www.sojamo.de/libraries/controlP5/
import ddf.minim.*;  //p5

Tri myTri;

int timer = 0, deadTime = 1;
int motionSize = 0;
int diffPixels = 0, diffMax = 0;
float motionRatio = 0;

//leaf texture
float incLeaf = 20, noiseBaseLeaf = 0, tempoLeaf = 34, detailLeaf = 30;
boolean thresLeaf = true;

float funLevel = 0;
float chillLevel = 0;
float funThreshold = 0.1;
int pixDim;


Capture video;
OpenCV opencv;
PImage texFile, frame, frameMem, diffImg, leafImg;
ArrayList<PImage> texLayers = new ArrayList<PImage>();

PFont myFont;

ControlP5 controlP5;

float funVolume = -10, chillVolume = -10;
int blur = 10, tresh = 74;
boolean showPanel = true, tTex = false, fTex = false, lTex = true, diffTex = false;
AudioPlayer player_fun, player_chill;
Minim minim;


void setup() {


  size( 1280, 800, P3D);
  noSmooth();
  background(0);
  frameRate(20);


  myFont = loadFont("redalert.vlw");
  textFont(myFont);

  opencv = new OpenCV(this, 640/2, 480/2);
  video = new Capture(this, 640/2, 480/2);
  video.start();
  opencv.loadImage(video);
  leafImg = getFrame(opencv, video);
  frameMem = getFrame(opencv, video);
  diffImg = getMovement(opencv, video);
  opencv.loadImage(frameMem);

  motionSize = opencv.width*opencv.height;
  texFile = loadImage("texture.jpg");

  myTri = new Tri(640/2, 480/2);

  minim = new Minim(this);
  player_fun = minim.loadFile("fun.wav", 1024);
  player_fun.setGain(-10);
  player_fun.play();
  player_fun.loop(100);
  player_chill = minim.loadFile("chill.wav", 1024);
  player_chill.setGain(-10);
  player_chill.play();
  player_chill.loop(100);

  controlP5 = new ControlP5(this);
  Group g1 = controlP5.addGroup("SETUP").setPosition(800, 20);
  controlP5.addSlider("deadTime", 0, 25, 8, 0, 120, 100, 12)
    .setNumberOfTickMarks(26)
    .setGroup(g1);
  controlP5.addSlider("blur", 1, 30, 10, 0, 40, 100, 12)
    .setGroup(g1);
  controlP5.addSlider("tresh", 1, 255, 74, 0, 60, 100, 12)
    .setGroup(g1);
  controlP5.addSlider("funVolume", -60, 6, -10, 0, 80, 100, 12)
    .setGroup(g1);
  controlP5.addSlider("chillVolume", -60, 6, -10, 0, 100, 100, 12)
    .setGroup(g1);
  controlP5.addTextlabel("showP", "To show/hide GUI push the SPACE key", 0, 10)
    .setGroup(g1);
  controlP5.addToggle("tTex", false, 0, 150, 24, 12)
   .setGroup(g1); 
  controlP5.addToggle("fTex", false, 36, 150, 24, 12)
   .setGroup(g1);
  controlP5.addToggle("lTex", true, 72, 150, 24, 12)
   .setGroup(g1);
  controlP5.addToggle("diffTex", false, 108, 150, 24, 12)
   .setGroup(g1); 
   
  Group gLeaf = controlP5.addGroup("LeafTexture")
    .setPosition(200, 20)
    .setGroup(g1);
  controlP5.addSlider("incLeaf", 0, 100, 5, 0, 40, 100, 12)
    .setGroup(gLeaf);
  controlP5.addSlider("tempoLeaf", 0, 100, 30, 0, 60, 100, 12)
    .setGroup(gLeaf);
  controlP5.addSlider("detailLeaf", 0, 100, 80, 0, 80, 100, 12)
    .setGroup(gLeaf);
  controlP5.addToggle("thresLeaf", false, 0, 100, 24, 12)
   .setGroup(gLeaf); 
    
}



void draw() {
  println(frameRate);
  getFrame(opencv, video);
  if (showPanel) {
    image( opencv.getSnapshot(), 0, 0 );
    image( diffImg, diffImg.width, 0 );
  }
  
  if (timer >= deadTime) {
    diffImg = getMovement(opencv, video);
    timer = 0; 
    println(frameRate);
  }
  timer++;


  diffPixels = 0;
  diffMax = diffImg.width * diffImg.height;
  diffImg.loadPixels();

  for (int px : diffImg.pixels) {
    if ( brightness(px) > 0) {
      diffPixels++;
    }
  }
  
  
  
    motionRatio = (float)diffPixels/motionSize;
   
   if (motionRatio>=0.05 && funLevel<100) funLevel+=3;
   if (motionRatio<0.05 && funLevel>0) funLevel-=1;
   
   if (funLevel>50 && chillLevel>0) chillLevel-=3;
   if (funLevel<=50 && chillLevel<100) chillLevel+=3;
   
   texLayers.clear();
   if (fTex) texLayers.add(texFile);
   if (tTex) {
     PImage imgTex = getTexture(opencv, video);
     texLayers.add(imgTex);
     if (showPanel) image( imgTex, 0, imgTex.height);
   }
   
   if (lTex) {
     PImage imgTex = getLeafTexture(detailLeaf, tempoLeaf, incLeaf, thresLeaf);
     texLayers.add(imgTex);
     if (showPanel) image( imgTex, imgTex.width*2, imgTex.height*2);
   }
   
   if (diffTex) texLayers.add(diffImg);
   

   
   
   myTri.setBrightness(funLevel/100);
   myTri.display(texLayers, showPanel);
   player_fun.setGain(((funLevel/100*66)-60));
   player_chill.setGain(((chillLevel/100*66)-60));
   
   controlP5.draw();
}

void stop()
{
  player_fun.close();
  player_chill.close();
}

PImage getFrame(OpenCV opencv, Capture video) {
  opencv.loadImage(video);
  opencv.blur(blur); 
  return opencv.getSnapshot();
}

PImage getMovement(OpenCV opencv, Capture video) {
  PImage diff;
  frame = getFrame(opencv, video);
  opencv.diff(frameMem);
  opencv.threshold(tresh);
  diff = opencv.getSnapshot();
  frameMem = getFrame(opencv, video);
  return diff;
}

PImage getTexture(OpenCV opencv, Capture video) {
  opencv.loadImage(video);
  opencv.threshold(tresh);
  opencv.blur(150);
  return opencv.getSnapshot();
}

PImage getLeafTexture(float detail, float tempo, float inc, boolean thres) {
  detail = map(detail, 0, 100, 0.5, 1);
  tempo = map(tempo, 0, 100, 0.0, 0.05);
  inc = map(inc, 0, 100, 0.0001, 0.008);
  
  PImage leafTex = createImage(640, 480, RGB);
  leafTex.loadPixels();
  
  float xoff = 0.0;
//  detail = map(mouseX, 0, width, 0.1, 0.6);
  noiseDetail(4, detail);
  
  for (int x = 0; x < leafTex.width; x++) {
    xoff += inc;
    float yoff = 0.0;
    for (int y = 0; y < leafTex.height; y++) {
      yoff += inc;
      float bright = noise(xoff, yoff, noiseBaseLeaf) * 255;
      leafTex.pixels[x+y*leafTex.width] = color(bright);
    }
  }
  leafTex.updatePixels();
  noiseBaseLeaf += tempo;
  if (thres) leafTex.filter(THRESHOLD);
  return leafTex;
}  


void keyPressed() {
  if (key == ' ') {
    showPanel = !showPanel;
    
    if (showPanel) {
      controlP5.show();
    } else if (!showPanel) {
      controlP5.hide();
    }
  }
}

void controlEvent(ControlEvent theControlEvent)
{
  if (theControlEvent.controller().name().equals("slideTime")) 
  {
    //colorMin = int(theControlEvent.controller().arrayValue()[0]);
    //deadTime = slideTime;
  }

  if (theControlEvent.controller().name().equals("chillVolume") || theControlEvent.controller().name().equals("funVolume"))
  {  
    player_fun.setGain(funVolume);
    player_chill.setGain(chillVolume);
  }
}


