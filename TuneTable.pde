// we need to import the TUIO library
// and declare a TuioProcessing client variable
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

//set resolution to 1280x1024

import java.util.Map.*;
import java.util.Iterator.*;
import java.util.concurrent.*;


// Creates Variable and junk  
Minim minim;
AudioOutput out;
FilePlayer filePlayer;
Delay myDelay;


boolean debug = true;
boolean invertColor = true;
boolean showFPS = true;
boolean hoverDebug = true;
boolean fullscreen = true;
boolean analyticsOn = true;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
int block_diameter = 120;
float table_size = 760;
float scale_factor = 1;
float cur_size = cursor_size*scale_factor;
int bpm = 60;
int beatsPerMeasure = 4;
int millisPerBeat;
int beatNo = 0;
PFont font;

static int display_width = 640;
static int display_height = 480;

PImage lock;
PImage unlock;
PShape beatShadow;
PShape rectangle;


List<Block> allBlocks;
List<Block> missingBlocks;
List<Block> killBlocks;

List<Cursor> cursors;

List<FunctionBlock> allFunctionBlocks;
List<Button> allButtons;
List<PlayHead> allPlayHeads;
List<PlayHead> killPlayHeads;


Cursor mouse;


boolean isInitiated = false;

void setup()
{
  size(displayWidth, displayHeight, P2D);

  noStroke();
  fill(0);

  loop();
  frameRate(60);

  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  beatShadow = sinCircle(0,0, block_diameter/2, 0, 8, block_diameter/20);
  

  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
  minim = new Minim(this);
  SetupClipDict();
  SetupFuncMap();
  SetupBoolMap();
  SetupIdToType();
  SetupBlockMap();
  SetupCursorMap();
  SetupIdToEffect();

  allBlocks = new ArrayList<Block>();
  missingBlocks = new ArrayList<Block>();
  killBlocks = new ArrayList<Block>();
  allFunctionBlocks = new ArrayList<FunctionBlock>();
  allButtons = new ArrayList<Button>();
  allPlayHeads = new ArrayList<PlayHead>();
  killPlayHeads = new ArrayList<PlayHead>();

  cursors = new ArrayList<Cursor>();


  float scaleFactor = 1;
  lock = loadImage("images/lock.png");
  scaleFactor = ((float)block_diameter/3.0) / (float)lock.height;
  lock.resize((int)(lock.width * scaleFactor), (int)(lock.height * scaleFactor));
  unlock = loadImage("images/unlock.png");
  scaleFactor = ((float)block_diameter/3.0) / (float)unlock.height;
  unlock.resize((int)(unlock.width * scaleFactor), (int)(unlock.height * scaleFactor));

  

  isInitiated = true;
  millisPerBeat = 60000/bpm;
  //playButt = new PlayButton(width - 50,height - 50,0,100);

  if (debug) {
    BeatBlock testBeat = new BeatBlock(400,400);
  }
}


void draw()
{
  beatNo = (millis() /millisPerBeat);
  background(invertColor ? 0 : 255);
  if (debug) {
    //cornerBeatGlow();
  }

  if (showFPS) {
    textSize(32);
    textAlign(LEFT, TOP);
    fill(255, 0, 0);
    text((int)frameRate, 10, 10);
  }

  textFont(font, 18*scale_factor);

  killRemoved();
  TuioUpdate();

  strokeWeight(5);
  stroke(0);


  for (Cursor c : cursors) {
    c.Update();
  }

  for (Block b : allBlocks) {
    b.Update();
    if (b.leadsActive)
      b.drawLeads();
    b.drawShadow();
    b.inChain = false;
  }

  for (Button b : allButtons) {
    if (b.isShowing)
      b.drawButton();
  }

  for (PlayHead p : allPlayHeads) {
    p.Update();
    p.draw();
  }
  for (FunctionBlock func : allFunctionBlocks) {
    func.startUpdatePath();
  }



  if (hoverDebug) {
    HoverDebug();
  }
}


boolean sketchFullScreen() {
  return (fullscreen);
}


void keyPressed() {
  if (key == ' ') {
    println("space " + millis());
    for (FunctionBlock func : allFunctionBlocks) {
      func.execute();
    }
  }
}

void Play() {
  for (FunctionBlock func : allFunctionBlocks) {
    func.execute();
  }
}

void mousePressed() {
  mouse = new Cursor();
}

void mouseReleased() {
  mouse.OnRemove();
}

void HoverDebug() {
  Block[] blocks = new Block[allBlocks.size()];
  allBlocks.toArray(blocks); // fill the array  
  for (Block b : blocks) {
    if (b.IsUnder(mouseX, mouseY)) {
      Tooltip(new String[] {
        "symbol id: " + b.sym_id, 
        "x: " + b.x_pos, 
        "y: " + b.y_pos, 
        "rotation: " + b.rotation, 
        "children: " + Arrays.toString(b.children)
      }
      );
    }
  }
}


void killRemoved() {
  for (Block b : killBlocks) {
    b.Die();
  }
  killBlocks.clear();
  for (PlayHead p : killPlayHeads) {
    p.Die();
  }
  killPlayHeads.clear();
}

void cornerBeatGlow(){
  float beatPercent = (1.0 - ((float)(millis() % (millisPerBeat)) / (float)(millisPerBeat)));
    int glowRadius = (int)(beatPercent  * 100);
    color c1 = color(invertColor ? 0 : 255);
    color c2 = color(invertColor ? 255 : 200);
    radialGradient(0, 0, glowRadius, c1, c2);
    radialGradient(width, 0, glowRadius, c1, c2);
    radialGradient(0, height, glowRadius, c1, c2);
    radialGradient(width, height, glowRadius, c1, c2);
}
