// we need to import the TUIO library
// and declare a TuioProcessing client variable
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

//set table resolution to 1280x960

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
boolean analyticsOn = false;
boolean simulateBlocks = true;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
int block_diameter = 120;

// used for beat calculations
int bpm = 60;
int beatsPerMeasure = 4;
int millisPerBeat;
int beatNo = 0;

PFont font;

PImage lock;
PImage unlock;
PImage lock_reg;
PImage unlock_reg;
PImage lock_inv;
PImage unlock_inv;
PShape beatShadow;
PShape dashCircle;
PShape playShadow;
PShape circleShadow;


List<Block> allBlocks;
List<Block> missingBlocks;
LinkedList<Block> killBlocks;

List<Cursor> cursors;

List<FunctionBlock> allFunctionBlocks;
List<Button> allButtons;
List<PlayHead> allPlayHeads;
LinkedList<PlayHead> killPlayHeads;


Cursor mouse;

boolean isInitiated = false;

void setup()
{
  size(displayWidth, displayHeight, P2D);

  noStroke();
  fill(0);

  loop();
  frameRate(60);

  font = createFont("Arial", 32);

  //SHAPE Setup
  beatShadow = sinCircle(0, 0, block_diameter/2, 0, 8, block_diameter/20);
  dashCircle = dashedCircle(0, 0, block_diameter, 10);
  playShadow = polygon(block_diameter * .62, 6);
  playShadow.disableStyle();
  ellipseMode(CENTER);
  circleShadow = createShape(ELLIPSE, 0, 0, block_diameter + 10, block_diameter +10);
  circleShadow.disableStyle();



  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
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
  killBlocks = new LinkedList<Block>();
  allFunctionBlocks = new ArrayList<FunctionBlock>();
  allButtons = new ArrayList<Button>();
  allPlayHeads = new ArrayList<PlayHead>();
  killPlayHeads = new LinkedList<PlayHead>();

  cursors = new ArrayList<Cursor>();

  //ICONS
  float scaleFactor = 1;
  lock_reg = loadImage("images/lock.png");
  lock_inv = loadImage("images/lock_inv.png");
  scaleFactor = ((float)block_diameter/3.0) / (float)lock_reg.height;
  lock_reg.resize((int)(lock_reg.width * scaleFactor), (int)(lock_reg.height * scaleFactor));
  lock_inv.resize((int)(lock_inv.width * scaleFactor), (int)(lock_inv.height * scaleFactor));

  unlock_reg = loadImage("images/unlock.png");
  unlock_inv = loadImage("images/unlock_inv.png");
  scaleFactor = ((float)block_diameter/3.0) / (float)unlock_reg.height;
  unlock_reg.resize((int)(unlock_reg.width * scaleFactor), (int)(unlock_reg.height * scaleFactor));
  unlock_inv.resize((int)(unlock_inv.width * scaleFactor), (int)(unlock_inv.height * scaleFactor));

  lock = (invertColor? lock_inv : lock_reg);
  unlock = (invertColor ? unlock_inv : unlock_reg);

  isInitiated = true;
  millisPerBeat = 60000/bpm;

  if (simulateBlocks) {
    FunctionBlock funcTest = new FunctionBlock(500,500, 0);
    StartLoopBlock testLoop = new StartLoopBlock(700,500);
    ClipBlock testClip = new ClipBlock(700, 700, 10);
    //ConditionalBlock testCond = new ConditionalBlock(900,500);
    //BooleanBlock testBool = new BooleanBlock(900, 200);
  }
}


void draw()
{
  beatNo = (millis() /millisPerBeat);
  background(invertColor ? 0 : 255);
  //cornerBeatGlow();

  if (debug) {

    //shape(playShadow, 400,400);
  }

  if (showFPS) {
    textSize(32);
    textAlign(LEFT, TOP);
    fill(255, 0, 0);
    text((int)frameRate, 80, 80);
  }


  textFont(font, 18);

  killRemoved();
  TuioUpdate();


  for (Cursor c : cursors) {
    c.Update();
  }

  for (Block b : allBlocks) {
    b.inChain = false;
    if (!(b instanceof FunctionBlock))b.blockColor = color(255);
  }

  for (FunctionBlock func : allFunctionBlocks) {
    func.startUpdatePath();
  }

  for (Block b : allBlocks) {

    b.Update();

    if (b.leadsActive) {
      b.drawLeads();
    }

    b.drawShadow();
  }

  //println("end block update loop");
  //testClip.Update();




  for (Button b : allButtons) {
    if (b.isShowing)
      b.drawButton();
  }


  for (PlayHead p : allPlayHeads) {
    p.Update();
    p.draw();
  }






  if (hoverDebug) {
    HoverDebug();
  }
  
  
}


boolean sketchFullScreen() {
  return (fullscreen);
}

/*
  Space can be used to play all Start blocks
 'i' can be used to invert black/white
 */
void keyPressed() {
  if (key == ' ') {
    println("space " + millis());
    for (FunctionBlock func : allFunctionBlocks) {
      func.execute();
    }
  }
  if (key == 'i') {
    invertColor = !invertColor;   
    if (invertColor) {
      lock = lock_inv;
      unlock = unlock_inv;
    } else {
      lock = lock_reg;
      unlock = unlock_reg;
    }
  }
}

/*
  Will cause all Start blocks to play simultaneously, useful for debugging
 */
void Play() {
  for (FunctionBlock func : allFunctionBlocks) {
    func.execute();
  }
}

/*
  Mouse clicks will simulate finger cursors, useful for debugging
 */
void mousePressed() {
  mouse = new Cursor();
}

void mouseReleased() {
  mouse.OnRemove();
}

/*
  Will create an informative tooltip when the mouse is hovering over a block, useful for debugging
 */
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
        "in chain? " + b.inChain, 
        "children: " + Arrays.toString(b.children)
      }
      );
    }
  }
}

/*
Destroys blocks and playhead that have been marked for removal. This can't be done during Update() calls because it tends to cause a concurrent modification exception.
 */
void killRemoved() {
  while (killBlocks.peek () != null) {
    killBlocks.pop().Die();
  }
  while (killPlayHeads.peek () != null) {
    killPlayHeads.pop().Die();
  }
}

/*
  Creates pulses in the screen corners to visualize the beat
 */
void cornerBeatGlow() {
  float beatPercent = (1.0 - ((float)(millis() % (millisPerBeat)) / (float)(millisPerBeat)));
  int glowRadius = (int)(beatPercent  * 300);
  color innerCol = color(invertColor ? 0 : 255);
  color outerCol = color(invertColor ? 100 : 150);

  fill(outerCol);
  noStroke();
  ellipse(0, 0, glowRadius, glowRadius);
  ellipse(width, 0, glowRadius, glowRadius);
  ellipse(0, height, glowRadius, glowRadius);
  ellipse(width, height, glowRadius, glowRadius);
}

