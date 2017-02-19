// This project uses the brightest point on 
// a screen to add characters from a keyboard
// to a .txt file that can be made into sound by a python script
// We are currently developing how this may also be applied to eye tracking.
// and have added a game that we were able to produce in the time to show how this 
// might work. 

// Our next steps were also to include predictive text features to increase the speed at which a user might be able to use our product. 
// We have also included the development we made on this goal in our project documentation.  

import processing.video.*;
PImage logo;
PrintWriter output;
Capture cam;
boolean on=true;
String keyboard[] = 
  {"I", "Can", "Could", "Yes", "Know", "The", "Was", "Would", "Will", "No", 
  "Won't", "They", "But", "Are", "0", "A", "K", ".", "Please", "There", "1", "B", "L", "?", 
  "This", "With", "2", "C", "N", "U", "For", "Get", "3", "D", "N", "V", "That", "But", 
  "4", "E", "O", "W", "To", "From", "5", "F", "P", "X", "And", "We", "6", "G", "Q", 
  "Y", "She", "US", "7", "H", "R", "Z", "He", "Put", "8", "I", "S", "'", "Food", "Water", 
  "9", "J", "T", ",", "Why", "What", "How", "Bad", "ing", "Thanks", "Where", "Who", "When", 
  "Good", "ed", "Please"};
class Tile {
  int x;
  int y;
  PVector position;
  color clr;
  int bwidth;
  int bheight;
  int alpha;
  Tile(int _x, int _y, int _bwidth, int _bheight) {
    x=_x;
    y=_y;
    position= new PVector (x, y);
    bwidth=_bwidth;
    bheight=_bheight;
    alpha=255;
  }

  void display() {
    pushStyle();
    fill(0);
    rect(position.x, position.y-50, 50, 50);
    popStyle();
  }
}
ArrayList<Tile> tiles= new ArrayList<Tile>();
int xpos = 0;
int ypos = 0;
int vidxpos=0;
int vidypos=0;

void setup () {
  logo=loadImage("logo.png");
  output= createWriter("talk.txt");
  size (960, 720);
  cam = new Capture (this, width, height, 24);
  noFill ();
  strokeWeight (2);
  stroke (255, 0, 102);
  for (int i=50; i<width; i+=50) { 
    for (int j=200; j<500; j+=50) {
      tiles.add(new Tile(i, j, 50, 50));
    }
  }
}

void draw () {
  cam.start();
  background (0);
  float maxCol = 0;
  if (cam.available ()) {
    cam.read ();
  }
  for (int i=0; i<keyboard.length; i++) {
    tiles.get(i).display();
    pushStyle();
    fill(255);
    text(keyboard[i], tiles.get(i).position.x+10, (tiles.get(i).position.y-10));
    popStyle();
  }
  for (int i=0; i < width; i++) {
    for (int j=0; j < height; j++) {
      color c = cam.get (i, j);

      if (brightness (c) > maxCol) {
        maxCol = brightness (c);
        xpos = width-i;
        ypos = j; 
        vidxpos=int(map(i, 0, 320, 0, 960));
        vidypos=int(map(j, 0, 240, 0, 720));
      }
    }
  }
  if (0<=xpos && xpos<=750) {
    for (int i=0; i<tiles.size(); i++) {
      if ((tiles.get(i).x)<=xpos && xpos<=tiles.get(i).x+50) {
        if (tiles.get(i).y<=ypos+50 && ypos+50<=tiles.get(i).y+50) { 
          output.println(keyboard[i]);
          print(keyboard[i]);
        }
      }
    }
  }
  if (xpos>=750 && xpos<=850 & ypos>=350 && ypos<=450) {
    output.flush();
    output.close();
  }

  if (on) {
    image(cam, 0, 0, 320, 240);
  }
  rect (xpos-2, ypos-2, 5, 5);
  pushStyle();
  fill(255, 0, 102);
  rect(750, 350, 100, 100);
  popStyle();
  pushStyle();
  textSize(25);
  fill(255);
  text("Talk", 775, 410);
  popStyle();
  pushStyle();
  fill(255, 0, 102);
  rect(230, 500, 500, 100);
  image(logo, 230, 500, 500, 100); 
}

void keyPressed(){
on=!on;
}
