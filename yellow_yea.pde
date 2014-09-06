//import hypermedia.video.*;
import gab.opencv.*; //https://github.com/atduskgreg/opencv-processing
import processing.video.*; //p5
//import java.awt.*; //p5

import controlP5.*; //http://www.sojamo.de/libraries/controlP5/
import ddf.minim.*;  //p5

  Tri myTri;

  int timer = 0;
  int deadTime = 1;
  int motionSize = 0;
  int motionPixels = 0;
  float motionRatio = 0;
  
  float funLevel = 0;
  float chillLevel = 0;
  float funThreshold = 0.1;
  int pixDim;
  
  
  
  Capture video;
  OpenCV opencv;
  PImage tex, tex2, frame, frameMem, pixs;

  PFont myFont;
  
  ControlP5 controlP5;
  
  float funVolume = -10;
  float chillVolume = -10;
  AudioPlayer player_fun;
  AudioPlayer player_chill;
  Minim minim;
  
  
void setup() {

   tex2 = loadImage("fto.jpg"); 
  
    size( 1280, 800, P2D);
    noSmooth();
    background(0);
    //noStroke();
    stroke(153);
    
    frameRate(20);

    
    myFont = loadFont("redalert.vlw");
    textFont(myFont);
    
    opencv = new OpenCV(this, 640/2, 480/2);
    video = new Capture(this, 640/2, 480/2);
    video.start();
    opencv.loadImage(video);
    frameMem = getFrame(opencv, video);
    opencv.loadImage(frameMem);
    
    motionSize = opencv.width*opencv.height;
    tex = new PImage(opencv.width, opencv.height);
    
    myTri = new Tri(tex);
    
    minim = new Minim(this);
    player_fun = minim.loadFile("fun.wav", 1024);
    player_fun.setGain(-10);
    player_fun.play();
    player_fun.loop(100);
    player_chill = minim.loadFile("chill2.wav", 1024);
    player_chill.setGain(-10);
    player_chill.play();
    player_chill.loop(100);
    
    controlP5 = new ControlP5(this);
    controlP5.addSlider("deadTime",0,25,8,10,130,100,12).setNumberOfTickMarks(26);
    controlP5.addSlider("funVolume",-60,6,-10,10,170,100,12);
    controlP5.addSlider("chillVolume",-60,6,-10,10,190,100,12);
    
//    https://github.com/atduskgreg/opencv-processing/blob/master/examples/BackgroundSubtraction/BackgroundSubtraction.pde
}

void draw() {
  background(0);
    frame = getFrame(opencv, video);
    image(frame, 0, 0 );
    opencv.loadImage(frameMem);
    opencv.diff(frame);
    opencv.threshold(40);
    //opencv.brightness(50);
    //opencv.contrast(100);

    //image( opencv.image(OpenCV.MEMORY), 160, 0 );  // display the image in memory on the right
    image( opencv.getSnapshot(), 260, 0 );    
    if (timer >= deadTime)
    {
      frameMem = getFrame(opencv, video);  // store the actual image in memory    
      timer = 0; 
      print("Yo"); 
    }
    timer++;
    
  
    motionPixels = 0;
    pixs = opencv.getSnapshot();
    pixDim = pixs.width * pixs.height;
    pixs.loadPixels();
    
    /*
    for (int i = 0; i < pixDim; i++)
    {
      if ( brightness(pixels[i]) > 0)
      {
        motionPixels++;
      }
    }
    motionRatio = (float)motionPixels/motionSize;
    //println("motionRatio" + motionRatio + " chillLevel:" + chillLevel + " funLevel:" + funLevel);
    
    if (motionRatio>=0.05 && funLevel<100) funLevel+=2;
    if (motionRatio<0.05 && funLevel>0) funLevel-=1;
    
    if (funLevel>50 && chillLevel>0) chillLevel-=3;
    if (funLevel<=50 && chillLevel<100) chillLevel+=3;

    tex.pixels = pixels;
    tex.updatePixels();
    
    
    myTri.setBrightness(funLevel/100);
    myTri.display(tex);
    player_fun.setGain(((funLevel/100*66)-60));
    player_chill.setGain(((chillLevel/100*66)-60));
    
    controlP5.draw();
    */
}

void stop()
{
  player_fun.close();
  player_chill.close();
}

PImage getFrame(OpenCV opencv, Capture video) {
    opencv.loadImage(video);
    opencv.blur(10); 
    return opencv.getSnapshot();
}
  

void keyPressed() {
    
    getFrame(opencv, video);  // store the actual image in memory
}

void controlEvent(ControlEvent theControlEvent)
{
  if(theControlEvent.controller().name().equals("slideTime")) 
  {
  //colorMin = int(theControlEvent.controller().arrayValue()[0]);
  //deadTime = slideTime;
  }
  
  if(theControlEvent.controller().name().equals("chillVolume") || theControlEvent.controller().name().equals("funVolume"))
  {  
    player_fun.setGain(funVolume);
    player_chill.setGain(chillVolume); 
  }
  
}



