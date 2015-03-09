// we need to import the TUIO library
// and declare a TuioProcessing client variable


import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.util.Map.*;

// Creates Variable and junk  
Minim minim;
Player player;


// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float block_height = 60;
float block_width = 60;
float table_size = 760;
float scale_factor = 1;
float obj_size = object_size*scale_factor; 
float cur_size = cursor_size*scale_factor; 
PFont font;

static int display_width = 640;
static int display_height = 480;

List<Block> allBlocks;
//List<Block> playBlocks;
List<Chain> allChains;

void setup()
{
  //size(screen.width,screen.height);
  size(display_width, display_height);
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

  player = new Player();
  allBlocks = new ArrayList<Block>();
  //playBlocks = new ArrayList<Block>();
  allChains = new ArrayList<Chain>();
}


void draw()
{
  background(255);
  textFont(font, 18*scale_factor);

  if (player.isPlaying) {
    player.Update();
  }

  ExDrawTuioObjects();
  
 for (Chain c : allChains) {
    c.drawChain();
  }
  
  
}

void keyPressed() {
  if (key == ' ') {
    println("play");
    Play();
  }
}

void Play() { 
  if (!player.isPlaying) {

    List<Block>[] lists = new List[allChains.size()];

    for (int i = 0; i< allChains.size(); i++) {
      lists[i] = ResolveLoops(allChains.get(i).blocks);

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
      break;

    case CLIP:
      new_list.add(cur_block);
      break;

    case START_LOOP:
      int end_loop = i + LoopEndIndex(blocks.subList(i, blocks.size()));//find where this loop ends
      List<Block> resolved_sub = ResolveLoops(blocks.subList(i+1, end_loop));//recursively resolve any loops inside this loop
      for (int loop = 0; loop < cur_block.parameter + 1; loop++) {//assumes the start loop block gets the argument, also assumes that "loop 0 times" means "only play through it once and don't repeat"
        new_list.addAll(resolved_sub);
      }
      i = end_loop; //skip to the end of this loop
      break;

    case END_LOOP:
      //this should never happen
      break;

    case EFFECT:
      new_list.add(cur_block);
      break;

    case SILENCE:
      new_list.add(cur_block);
      break;

    default:
      break;
    };
  }
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
  return 0; //end not found
}





/*
Chain[] FindChains() {
 List<Chain> chains = new LinkedList<Chain>();
 Vector tuioObjectList = tuioClient.getTuioObjects();
 
 List<TuioObject> playBlocks =  new ArrayList<TuioObject>();
 List<TuioObject> objList =     new ArrayList<TuioObject>();
 
 
 //seperate out play blocks, put everything else into a single arrayList
 for (int i=0; i<tuioObjectList.size (); i++) {
 TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
 if (tobj.getSymbolID() == 0) { // this is a Play block
 playBlocks.add(tobj);
 } else {
 objList.add(tobj);
 }
 }
 
 
 //look for chains starting at a play block
 for (TuioObject play : playBlocks) {
 List<Block> curChain = new LinkedList<Block>();    
 TuioObject start = FindArgument(play, objList);
 curChain.add(new Block(play, start));
 
 boolean chainCont = false; //is the chain going to continue
 TuioObject cur = play;
 do {
 chainCont = false;
 int mil = (millis());
 
 for (int i=0; i<objList.size (); i++) { // iterate through list of all unclaimed tuio objects
 TuioObject next = objList.get(i);
 
 if (TuioObjectNeighbors(cur, next)) {
 Block nextBlock = new Block(next);
 
 // if this next block should have an argument, search the object list for it
 if (nextBlock.requiresArgument()){
 TuioObject arg  = FindArgument(next, objList);
 if (arg != null){
 objList.remove(arg);
 nextBlock.SetArgument(arg);
 }
 }
 
 curChain.add(nextBlock);
 objList.remove(next);
 cur = next;
 chainCont = true;
 break;
 }
 
 
 
 }
 println(millis() - mil);
 
 
 
 }
 while (chainCont);
 
 Block[] curChainArray = new Block[0];//this array needs to exist to copy curChain into
 //println(curChain);
 chains.add(new Chain(curChain.toArray(curChainArray)));
 }
 //TODO look for chains without a play block
 
 
 
 Chain[] chainArray = new Chain[0];
 return chains.toArray(chainArray);
 }
 
 */

TuioObject FindArgument(TuioObject main, List<TuioObject> objList) {
  for (int i=0; i<objList.size (); i++) {
    TuioObject next = objList.get(i);
    if (TuioObjectParameter(main, next)) {
      return next;
    }
  }
  return null;
}

Chain[] FakeChains() {
  Block[] b1 = new Block[] {
    new Block(0, 0), //play
    new Block(1), 
    new Block(1), 
    new Block(3), 
    new Block(2), 
    new Block(4), 
    new Block(4)
    };
    
  Block[] b2 = new Block[] {
     new Block(0, 0), //play
     new Block(2), 
     new Block(2),
     };
     

  return new Chain[] {
    new Chain(b1), 
    new Chain(b2)
  };
}


