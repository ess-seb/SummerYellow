class Tri { 
  color myColor;
  color cornerColor;
  int edit_mode = 0;
  int tolerance = 5;
  int nCorner = 0;
  int ofs = 400;

  PImage img;

  boolean mlocked = false;
  float[][] tD = {
    {
      0+ofs, 0+ofs, 0.5, 0.5
    }
    , {
      -200+ofs, 100+ofs, 0.0, 1.0
    }
    , {
      200+ofs, 100+ofs, 1.0, 1.0
    }
    , {
      0+ofs, -100+ofs, 0.5, 0.0
    }
    , {
      -200+ofs, 100+ofs, 0.0, 1.0
    }
  };
  
  

  Tri(PImage tex) { 
    colorMode(HSB, 360, 100, 100);
    myColor = color(110, 100, 100);
    cornerColor = color(205, 90, 100);
    img = createImage(tex.width, tex.height, RGB);
  }

  void display(PImage texImg, PImage texTre, Boolean showPanel, boolean fTex, boolean tTex) {
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      img.pixels[i] = myColor;
    }
    
    img.updatePixels();
    if (fTex) img.blend(texImg, 0, 0, texImg.width, texImg.height, 0, 0, img.width, img.height, OVERLAY);
    if (tTex) img.blend(texTre, 0, 0, texTre.width, tex.height, 0, 0, img.width, img.height, OVERLAY);
    
    if (showPanel) stroke(153);
    else noStroke();

    beginShape(TRIANGLE_FAN);
    texture(img);
    for (float[] pt : tD) {
      vertex(pt[0], pt[1], pt[2]*img.width, pt[3]*img.height);
    }
    endShape(CLOSE);

    if (!mlocked) nCorner = isCorner();
    if (mousePressed) {
      if (nCorner>0) { 
        mlocked = true;
        tD[nCorner-1][0] = mouseX; 
        tD[nCorner-1][1] = mouseY;
      }
    } else mlocked = false;

    if (mlocked) {
      tD[nCorner-1][0] = mouseX; 
      tD[nCorner-1][1] = mouseY;
    }
  }

  int isCorner() {
    int ret = 0;
    for (int ii=0; ii<tD.length; ii++) {
      if (mouseX > tD[ii][0]-tolerance && mouseX < tD[ii][0]+tolerance && mouseY > tD[ii][1]-tolerance && mouseY < tD[ii][1]+tolerance) {
        fill(cornerColor);
        rectMode(RADIUS);
        rect(tD[ii][0], tD[ii][1], tolerance, tolerance);
        ret = ii+1; 
        return ret;
      } else ret = 0;
    }
    return ret;
  }

  void setBrightness(float bri) {
    myColor = color(50, 100, (float)bri*100);
  }
}


