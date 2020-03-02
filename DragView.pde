import processing.video.*;
import gab.opencv.*;



Capture webcam;              // webcam input
OpenCV cv;                   // instance of the OpenCV library
ArrayList<Contour> blobs;    // list of blob contours
String[] imagePaths = {
  "1.jpg", "2.jpg", "3.jpg"
};

PVector blobStart;
PVector blobEnd;
boolean blobBeginLeft = false;
boolean blobBeginRight = false;
float minAreaBlob = 0;
PImage[] images = new PImage[imagePaths.length];
int currImage = 0;
boolean delayYes = false;

void setup() {
  size(1280,720);
  
  // create an instance of the OpenCV library
  // we'll pass each frame of video to it later
  // for processing
  cv = new OpenCV(this, width,height);
  
  // start the webcam
  String[] inputs = Capture.list();
  if (inputs.length == 0) {
    println("Couldn't detect any webcams connected!");
    exit();
  }
  webcam = new Capture(this, inputs[0]);
  webcam.start();
  for (int i=0; i<imagePaths.length; i++)
  { 
    images[i] = loadImage(imagePaths[i]);
  }
 
  // text settings (for showing the # of blobs)
  textSize(20);
  textAlign(LEFT, BOTTOM);
}


void draw() {
  
  // don't do anything until a new frame of video
  // is available
  if (webcam.available()) {
    
    // read the webcam and load the frame into OpenCV
    webcam.read();
    cv.loadImage(webcam);
    
    // pre-process the image (adjust the threshold
    // using the mouse) and display it onscreen
    int threshold = int( map(mouseY, 0,height, 0,255) );
    cv.threshold(threshold);
    //cv.invert();    // blobs should be white, so you might have to use this
    cv.dilate();
    cv.erode();
    image(cv.getOutput(), 0,0);
    
    // get the blobs and draw them
    blobs = cv.findContours();
    noFill();
    stroke(255,150,0);
    strokeWeight(3);
    for (Contour blob : blobs) {
      if(blobs.size() == 0){
        continue;
      }
      // optional: reject blobs that are too small
      //map(mouseX, 10,width,0,3000)
      if (blob.area() < map(mouseX, 10,width,0,3000)) {
        continue;
      }
      ArrayList<PVector> pts = blob.getPolygonApproximation().getPoints();
      float centerX = 0;
      float centerY = 0;
      beginShape();
      for (PVector pt : pts) {
        vertex(pt.x, pt.y);
        centerX += pt.x;
        centerY += pt.y;
      }
      endShape(CLOSE);
      centerX /= pts.size();
      centerY /= pts.size();
            
      blobStart= new PVector(centerX,0);
      //println(blobStart.x);
    }
    
    
    if(blobs.size() != 0 && blobBeginRight == true ){
      if(blobStart.x > width/2+100){
        if(currImage == imagePaths.length-1){
          currImage = 0;
        }else{
          currImage++;
          println(currImage);
          delayYes = true;
        }
        println("Screen move request");
        blobBeginRight = false;
      }
    }
    
    
    
    if(blobs.size() != 0 && blobStart.x < width/2 -100){
      blobBeginRight = true;
      println("BlobrightTrue");
    }
    if(blobs.size() != 0 && blobStart.x > width/2+100){
      blobBeginLeft = true;
      println("BlobLEftTrue");
    }
      
    // how many blobs did we find?
    fill(0,150,255);
    noStroke();
    text(blobs.size() + " blobs", 20,height-20);
  }
  if (keyPressed) {
    if (key == 'd' || key == 'd') {
    image(images[currImage], 0, 0, 200, 200);
    }
  } else {
    image(images[currImage], 0, 0, width, height);
  }
  //image(images[currImage], 0, 0, width, height);
  if(delayYes == true){
    delay(500);
    delayYes = false;
  }
  
}
