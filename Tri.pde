class Tri { 
  color myColor;
  color cornerColor;
  int edit_mode = 0;
  int tolerance = 5;
  int nCorner = 0;

  int ofs = 400;

  boolean mlocked = false;
  int[][] tD = {
    {
      -101+ofs, -58+ofs
    }
    , {
      101+ofs, -58+ofs
    }
    , {
      0+ofs, 0+ofs
    }
    , {
      116+ofs, 0+ofs
    }
  };
  PImage tex2 = loadImage("fto.jpg"); 
  PImage img;

  // The Constructor is defined with arguments.
  Tri(PImage tex) { 
    colorMode(HSB, 360, 100, 100);
    myColor = color(110, 100, 100);
    cornerColor = color(205, 90, 100);
    img = createImage(tex.width, tex.height, RGB);
  }

  void display(PImage tex) {
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      img.pixels[i] = myColor;
    }
    img.updatePixels();
    img.blend(tex, 0, 0, tex.height, tex.width, 0, 0, tex.height, tex.width, OVERLAY);
    //img.blend(tex2, 0, 0, tex2.height, tex2.width, 0, 0, tex2.height, tex2.width, OVERLAY);
    stroke(153);
    //fill(myColor);
    //textureMode(NORMALIZED);
    beginShape(TRIANGLE_FAN);
    texture(img);
    for (int p = 0; p < tD.length; p++) {
      vertex(tD[p][0], tD[p][1], tD[p][2], tD[p][3]);
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


