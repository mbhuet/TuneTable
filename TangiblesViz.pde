// we need to import the TUIO library
// and declare a TuioProcessing client variable

//set resolution to 1280x1024

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.util.Map.*;
import java.util.concurrent.*;


// Creates Variable and junk  
Minim minim;
AudioOutput out;
FilePlayer filePlayer;
Delay myDelay;


Player player;
boolean debug = false;
boolean fullscreen = true;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float block_height = 115;
//float block_width = 60;
float table_size = 760;
float scale_factor = 1;
//float obj_size = object_size*scale_factor; 
float cur_size = cursor_size*scale_factor; 
PFont font;

static int display_width = 640;
static int display_height = 480;

List<Block> allBlocks;
List<Chain> allChains;
List<Button> allButtons;

List<Block> recentlyRemovedBlocks;


Chain[] fakeChains;




boolean isInitiated = false;

void setup()
{
  if (fullscreen)  size(displayWidth, displayHeight);
  else    size(display_width,display_height);
  
  noStroke();
  fill(0);

  loop();
  frameRate(30);

  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;

  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
  minim = new Minim(this);
  SetupClipDict();
  SetupIdToArg();
  SetupIdToType();
  SetupBlockMap();
  SetupIdToEffect();

  player = new Player();
  allBlocks = new ArrayList<Block>();
  //playBlocks = new ArrayList<Block>();
  allChains = new ArrayList<Chain>();
  allButtons = new ArrayList<Button>();
  
  recentlyRemovedBlocks = new ArrayList<Block>();
  
  

  isInitiated = true;

  PlayButton pB = new PlayButton(100,displayHeight-100, 0, 100);

  if (debug) {
    //Block b = new Block(0);
    fakeChains = CreateFakeChains();
  }
}


void draw()
{
  //println("start update");
    background(255);

  textFont(font, 18*scale_factor);
  TuioUpdate();

  

  if (player.isPlaying) {
    player.Update();
    
  
  } else {


    for (Chain c : allChains) {
      c.drawChain();
    }
    
    for (Button b : allButtons) {
      b.drawButton();
    }
    
  } 
  for (Block b : allBlocks) {
    b.drawBlock();
  }
  

  if (debug) {
    fill(255, 0, 0);
    ellipse(width/2, height/2, 10, 10);
  }
  //println("stop update");
}


boolean sketchFullScreen(){
  return (fullscreen);
}


void keyPressed() {
  if (key == ' ') {
    //println("play");
    //Play();
  }
}



void mousePressed() {
  if (true) {
     //Click(mouseX,mouseY);
  }
}


void Click(int x, int y){
  if (true){
  fill(255,0,0);
  ellipse(x,y,10,10);
  }
Button[] buttons = new Button[allButtons.size()];
allButtons.toArray(buttons); // fill the array  
for (Button b : buttons) {
      if (b.IsUnder(x, y)) {
        b.Trigger();
      }
    }
}



void Play() { 

  if (!player.isPlaying) {
    
    for (Block b : allBlocks) {
    b.OnPlay();
  }
    //println("play");
    List<Block>[] lists;
        lists = new List[allChains.size()];

    if (debug) {
        //List<Block>[] fake_lists = new List[fakeChains.length];
        //List<Block>[] comb_lists = new List[allChains.size() + fakeChains.length];
      lists = new List[allChains.size() + fakeChains.length];
   
      for (int i = 0; i< fakeChains.length; i++) {
        lists[i] = ResolveLoops(fakeChains[i].blocks);
      }
      for (int i = 0; i< allChains.size (); i++) {
        lists[i + fakeChains.length] = ResolveLoops(allChains.get(i).blocks);
      }
      
    } else {

      for (int i = 0; i< allChains.size (); i++) {
        lists[i] = ResolveLoops(allChains.get(i).blocks);
      }
    }
    player.PlayLists(lists);
  }
}



List<Block> ResolveLoops(List<Block> blocks) {
  List<Block> new_list = new ArrayList<Block>();
  for (int i = 0; i<blocks.size (); i++) {
    Block cur_block = blocks.get(i);
    switch(cur_block.type) {

    case PLAY:
      //should add silence to last until the Play begins
      new_list.add(cur_block);

      for(int p = 1; p<cur_block.parameter; p++){
        new_list.add(cur_block);
      }
      break;

    case CLIP:
      new_list.add(cur_block);
      break;

    case START_LOOP:
      //new_list.add(cur_block);
      int end_loop = i + LoopEndIndex(blocks.subList(i, blocks.size()));//find where this loop ends
      List<Block> resolved_sub = ResolveLoops(blocks.subList(i+1, end_loop));//recursively resolve any loops inside this loop
      for (int loop = 0; loop < cur_block.parameter + 1; loop++) {//assumes the start loop block gets the argument, also assumes that "loop 0 times" means "only play through it once and don't repeat"
        if (loop > 0)new_list.add(cur_block); //add the start loop block so we know when it's getting reached during play, that way we can decrement the number on it
        new_list.addAll(resolved_sub);
      }
      i = end_loop-1; //skip to the end of this loop
      break;

    case END_LOOP:
      new_list.add(cur_block);
      break;

    case EFFECT:
      new_list.add(cur_block);
      break;

    case SILENCE:
      for(int p = 0; p<cur_block.parameter; p++){
        new_list.add(cur_block);
      }
      break;

    default:
      break;
    };
  }
  //println(new_list);
  return new_list;
}



//Given a block list that begins with a loop start at [0], this will find the loop's ending index in the list
int LoopEndIndex(List<Block> sub) {
  int starts = 0;
  int ends = 0;
  for (int i = 0; i<sub.size (); i++) {
    if (sub.get(i).type == BlockType.START_LOOP) {
      starts++;
    } else if (sub.get(i).type == BlockType.END_LOOP) {
      ends ++;
      if (starts == ends) {
        return i;
      }
    }
  }
  return sub.size(); //end not found
}



TuioObject FindArgument(TuioObject main, List<TuioObject> objList) {
  for (int i=0; i<objList.size (); i++) {
    TuioObject next = objList.get(i);
    if (TuioObjectParameter(main, next)) {
      return next;
    }
  }
  return null;
}

Chain[] CreateFakeChains() {
  Block[] b1 = new Block[] {
    new Block(0, 0), //play
    new Block(111,0),
    new Block(65),
    new Block(30),
    new Block(111,0),
    new Block(24)
    };
    /*
  Block[] b2 = new Block[] {
     new Block(0, 0), //play
     };
     */


  return new Chain[] {
    new Chain(b1), 
    // new Chain(b2)
  };
}

