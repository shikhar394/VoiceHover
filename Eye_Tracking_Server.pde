//__________________________________LIBARIES____________________________________//
import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
import processing.net.*;

//____________________________________GLOBAL VARIABLES______________________________//

Capture cam;
PImage mirrorCam;

PImage img;

OpenCV opencvEye;
OpenCV opencvFace;
OpenCV opencvBlob;

int scale = 4;

Rectangle[] eyes;
Rectangle[] face;
Rectangle[] blob;      

int m;
int tolerance = 20;
float threshold = .28;

PImage smallerImgEye;
PImage smallerImgFace;
PImage BlobImage;
int pickedColor = color(0, 0, 0);

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

float eyeX = 0;
float eyeY = 0;

Server s;
Client c;
String input;
int data[];
int interval = 20;

void setup() {

  //_____________________________CANVAS SIZE______________________________________//

  size(640, 360);

  //_____________________________SET UP CAMERA______________________________________//


  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("No cameras available.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i + ": " + cameras[i]);
    }
    cam = new Capture(this, cameras[3]); 
    cam.start();
  }
  mirrorCam = createImage(640, 360, RGB);


  //_____________________________OPEN CV SETUP______________________________________//

  opencvEye = new OpenCV(this, 640/scale, 360/scale);
  opencvFace = new OpenCV(this, 640/scale, 360/scale);

  opencvEye.loadCascade("haarcascade_eye.xml"); 
  opencvFace.loadCascade("haarcascade_frontalface_default.xml");

  img = createImage(width, height, RGB);


  //_____________________________Open CV Resizing______________________________________//

  smallerImgEye = createImage(opencvEye.width, opencvEye.height, RGB);
  smallerImgFace = createImage(opencvFace.width, opencvFace.height, RGB);


  //_____________________________Connect the Sketches to Each other______________________________________//
  s = new Server(this, 12345); // Start a simple server on a port
}

//void captureEvent(Capture cam) {
//  cam.read();
//}

void draw() {

  //_____________________________INITIALIZE CAMERA______________________________________//

  if (cam.available()) {
    cam.read();
    mirroring();

    smallerImgEye.copy(mirrorCam, 0, 0, mirrorCam.width, mirrorCam.height, 0, 0, 
      smallerImgEye.width, smallerImgEye.height);
    smallerImgFace.copy(mirrorCam, 0, 0, mirrorCam.width, mirrorCam.height, 0, 0, 
      smallerImgFace.width, smallerImgFace.height);
    smallerImgEye.updatePixels();
  }

  //_____________________________PIXELS______________________________________//

  int h = mirrorCam.height;
  int w = mirrorCam.width;

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int i =  x + y*w; 

      int r = int( red(mirrorCam.pixels[i]) );
      int g = int( green(mirrorCam.pixels[i]) );
      int b = int( blue(mirrorCam.pixels[i]) );

      img.pixels[i] = color(r, g, b);
    }
  }

  //_____________________________DISPLAY IMAGE______________________________________//

  img.updatePixels();

  image(img, 0, 0);


  //_____________________________OPEN CV______________________________________//
  opencvEye.loadImage(smallerImgEye);
  opencvFace.loadImage(smallerImgFace);
  eyes = opencvEye.detect();
  face = opencvFace.detect();


  //____________________________OPEN CV DRAW_____________________________________//
  //image(opencvEye.getInput(), 0, 0);
  //image(opencvFace.getInput(), 0, 0);

  //__________________________FACE RECTANGLE________________________________________//

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3); 
  for ( m = 0; m < face.length; m++) {
    rect(face[m].x *scale, face[m].y *scale, face[m].width *scale, face[m].height*scale);
    //________________________EYE RECTANGLE_____________________________________________// 

    stroke(3, 134, 200);
    strokeWeight(2);
    for (int i = 0; i < eyes.length; i++) {
      int faceSide = ((face[m].x) + (face[m].width));
      //int faceTop = ((face[m].y) ;  // bug
      int faceBottom = ((face[m].y) + (face[m].height));


      int eyeCenterX = eyes[i].x + eyes[i].width/2;
      int eyeCenterY = eyes[i].y + eyes[i].height/2;

      //________________________DEFINE WHERE TO DRAW EYES_________________________________________// 

      if (eyeCenterX > face[m].x && eyeCenterX < faceSide &&
        eyeCenterY > face[m].y + face[m].height *1/8  && eyeCenterY < face[m].y + face[m].height *4/8) {
        /*if ((eyes[i].y > (faceTop + adjustmentTop)) && (eyes[i].y < (face[m].y - adjustmentBottom))
         &&(eyes[i].x < faceSide ) &&(eyes[i].x > face[m].x)) {*/

        //________________________DRAW EYE RECTANGLES_____________________________________________//        
        rect(eyes[i].x *scale, eyes[i].y*scale, eyes[i].width*scale, eyes[i].height*scale);
        PImage a = geteyeImage(mirrorCam, eyes[i].x *scale, eyes[i].y*scale, eyes[i].width*scale, eyes[i].height*scale); 
        a.filter(BLUR, 2);
        a.filter(THRESHOLD, threshold);

        image(a, 0, 0);
        a.loadPixels();

        //________________________COLOR TRACKING_____________________________________________// 

        int sumX = 0;
        int sumY = 0;
        int avgX = 0;
        int avgY = 0;
        int count = 0;

        int ColorTrackw = a.width;
        int ColorTrackh = a.height;

        for (int ColorTracky = 0; ColorTracky < ColorTrackh; ColorTracky++) {
          for (int ColorTrackx = 0; ColorTrackx < ColorTrackw; ColorTrackx++) {
            int ColorTracki =  ColorTrackx + ColorTracky*ColorTrackw; 

            int ColorTrackr = int( red(a.pixels[ColorTracki]) );
            int ColorTrackg = int( green(a.pixels[ColorTracki]) );
            int ColorTrackb = int( blue(a.pixels[ColorTracki]) );
            float avgColor = (ColorTrackr+ColorTrackg+ColorTrackb) /3; // grayscaled

            float focusedEye = 0.35;
            if (avgColor < 100) {
              if (ColorTrackx > ColorTrackw*focusedEye && ColorTrackx < ColorTrackw*(1-focusedEye) &&
                ColorTracky < ColorTrackh*(1-focusedEye) && ColorTracky > ColorTrackw*(focusedEye)) {
                sumX += ColorTrackx;
                sumY += ColorTracky;
                count++;
              }
            }
          }
        }
        a.updatePixels();
        // get average position to get the center position
        if (count != 0) {
          avgX = sumX / count;
          avgY = sumY / count;
        }
        //eyeX = (int)map(avgX, 0, ColorTrackw, 0, 100); 
        //eyeY = (int)map(avgY, 0, ColorTrackh, 0, 100);
        if (avgX != 0 && avgY != 0) { 
          eyeX = lerp(eyeX, map(avgX, 0, ColorTrackw, 0, 1), 0.1); 
          eyeY = lerp(eyeY, map(avgY, 0, ColorTrackh, 0, 1), 0.1);

          String toSend = eyeX + " " +eyeY + "\n";

          if (eyeX != 0 && eyeY != 0) {
            print(toSend);
            s.write(toSend);
          }

          pushStyle();
          if (i == 0) {
            fill(0, 0, 255);
          } else {
            fill(255, 0, 255);
          }
          ellipse((width*eyeX), (height*eyeY), 30, 30);
          popStyle();


          //lerpEyeX = lerp( avgX, eyeX, .1);
          //lerpEyeY = lerp(  avgY, eyeY, .1);
          //_____________SEND VARIABLES TO OTHER SKETCH_____________________________________________//
        }
      }
      println("---------------");
    }
    // show the center position
    stroke(255, 0, 0);
    //line(eyeX, 0, eyeX, a.width);
    //line(0, eyeY, ColorTrackh, eyeY);
    ellipse(eyeX, eyeY, 5, 5);
    //println( " (   " +avgX + " ,  " +avgX + " )   ");
    //println( " (   " +sumX + " ,  " +sumX + " )   ");


    //______________________________Framerate______________________________________________//
    fill(0);
    textSize(10);
    text(frameRate, 30, 60);

    textSize(30);
    text(eyeX, 50, 100);
    text(eyeY, 150, 100);
  }
}
PImage geteyeImage(PImage resource, int x, int y, int w, int h) {
  PImage eyeImage = createImage(w, h, RGB);
  eyeImage.copy(resource, x, y, w, h, 0, 0, w, h);
  return eyeImage;
}
void keyPressed() {
  println("pressed");
  s.write(100 + " " + 100 + "\n");
}


void mirroring() {
  int w = cam.width;
  int h = cam.height;
  cam.loadPixels();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int camIndex =  x + y*w;
      int mirrorCamIndex =  (w-1 - x) + y*w;
      mirrorCam.pixels[mirrorCamIndex] = cam.pixels[camIndex];
    }
  }
  mirrorCam.updatePixels();
}
