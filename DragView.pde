import processing.video.*;
import gab.opencv.*;

//Original vision processing code written by Jeff Thompson github.com/jeffThompson
//Image gallery adaptation by Luke Labenski github.com/splitty

//The following is a program that allows a swipe gesture that is detected via webcam and
//a led to be the controller of scrolling through and image gallery.  

Capture webcam;              // webcam input
OpenCV cv;                   // instance of the OpenCV library
ArrayList<Contour> blobs;    // list of blob contours
String[] imagePaths = {      // creating the array of images to scroll through
  "1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg"
};


PVector blobStart;  //starting location for our main blob to be housed in
PVector blobEnd;  //ending location for our main blob to be housed in
boolean blobBeginLeft = false; // does the blob start on the left side of the screen?
boolean blobBeginRight = false;  // does the blob start on the right side of the screen?
float minAreaBlob = 0;  // optional minimum area for blob to be discovered with
PImage[] images = new PImage[imagePaths.length]; // making out images out of the array
int currImage = 0;  // this decides what image we currently display, will be incremented by swiping
boolean delayYes = false;  // used for testing, the program will delay when the swipe is detected

void setup() {
  //canvas size
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
  //loading in images from our image array
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
    blobStart = new PVector(0,0);
    // read the webcam and load the frame into OpenCV
    webcam.read();
    cv.loadImage(webcam);
    
    // pre-process the image using a set threshhold for my specific presentation set up
    int threshold = int( 240 );
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
      //getting the centroid of the blob
      float centerX = 0;
      //for the sake of future usage and maybe adding different swipe detection, the Y axis is still included
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
      //set the centroid of our blob to the starting position of the blob      
      blobStart= new PVector(centerX,0);
      //println(blobStart.x);
    }
    
   
    //if there are blobs detected and the blobs begin on the right side previously (flipped, so left)
    if(blobs.size() != 0 && blobBeginRight == true ){
      //checking if the blob has now moved to the left side of the screen
      if(blobStart.x > width/2+100){
        //changing the image
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
    
    
    //detecting if the blob has started on the right side of the screen
    if(blobs.size() != 0 && blobStart.x < width/2 -100){
      blobBeginRight = true;
      println("BlobrightTrue");
    }
    //detecting if the blow started on the left side of the screen
    if(blobs.size() != 0 && blobStart.x > width/2+100){
      blobBeginLeft = true;
      println("BlobLEftTrue");
    }
      
    // how many blobs did we find?
    fill(0,150,255);
    noStroke();
    text(blobs.size() + " blobs", 20,height-20);
  }
  //debugging mode (aka, picture in picture)
  if (keyPressed) {
    if (key == 'd' || key == 'd') {
    image(images[currImage], 0, 0, 200, 200);
    }
  } else {
    //displaying our current image
    image(images[currImage], 0, 0, width, height);
  }
  //image(images[currImage], 0, 0, width, height);
  if(delayYes == true){
    delay(0);
    delayYes = false;
  }
  
}
