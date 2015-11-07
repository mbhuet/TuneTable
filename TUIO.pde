import TUIO.*;
import java.util.*; 
import java.util.concurrent.*;

TuioProcessing tuioClient;

AbstractQueue<TuioActionWrapper> actionQueue = new ConcurrentLinkedQueue<TuioActionWrapper>();
AbstractQueue<CursorActionWrapper> cursorQueue = new ConcurrentLinkedQueue<CursorActionWrapper>();

class TuioActionWrapper {
  TuioAction action;
  TuioObject tObject;

  TuioActionWrapper(TuioObject tObj, TuioAction act) {
    action = act;
    tObject = tObj;
  }
}

class CursorActionWrapper {
  TuioAction action;
  TuioCursor tCursor;

  CursorActionWrapper(TuioCursor tCurs, TuioAction act) {
    action = act;
    tCursor = tCurs;
  }
}


// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (!isInitiated) return;
  actionQueue.offer(new TuioActionWrapper(tobj, TuioAction.ADD));

}


// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (!isInitiated) return;

  actionQueue.offer(new TuioActionWrapper(tobj, TuioAction.REMOVE));

  
}


// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (!isInitiated) return;

  actionQueue.offer(new TuioActionWrapper(tobj, TuioAction.UPDATE));

}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  if (!isInitiated) return;
    cursorQueue.offer(new CursorActionWrapper(tcur, TuioAction.ADD));
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  if (!isInitiated) return;

  cursorQueue.offer(new CursorActionWrapper(tcur, TuioAction.UPDATE));
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (!isInitiated) return;

  cursorQueue.offer(new CursorActionWrapper(tcur, TuioAction.REMOVE));
}


// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}


void TuioUpdate() {

  while (actionQueue.peek () != null) {
    TuioActionWrapper wrap = actionQueue.poll();
    TuioObject curObj = wrap.tObject;
    switch(wrap.action) {
    case ADD :
      if (!checkMissing(curObj)) {
        Block newBlock;
        BlockType type = idToType.get(curObj.getSymbolID());
        if (type == null) type = BlockType.FUNCTION; //why is it null sometimes?

        switch (type) {
        case FUNCTION:
          newBlock = new FunctionBlock(curObj);
          break;

        case CLIP:
          newBlock = new ClipBlock(curObj);
          break;

        case COUNTDOWN:            
          newBlock = new CountdownBlock(curObj);
          break;

        case CONDITIONAL:
          newBlock = new ConditionalBlock(curObj);
          break;

        case EFFECT:
          newBlock = new EffectBlock(curObj);
          break;

        case BOOLEAN:
          newBlock = new BooleanBlock(curObj);
          break;

        case CALL:
          newBlock = new CallBlock(curObj);
          break;

        case SPLIT:
          newBlock = new SplitBlock(curObj);
          break;
          
        case BEAT:
          newBlock = new BeatBlock(curObj);
          break;

        default:
          newBlock = new FunctionBlock(curObj);
          break;
        }

      }
      break;


    case REMOVE :

      Block remBlock = blockMap.get(curObj.getSessionID());
      if (remBlock != null) {
        remBlock.OnRemove();
      }
      break;

    case UPDATE :
      Block upBlock = blockMap.get(curObj.getSessionID());
      if (upBlock!=null) {
        upBlock.UpdatePosition();
      }
      break;
    }
  }

  killRemoved();


  while (cursorQueue.peek () != null) {
    CursorActionWrapper wrap = cursorQueue.poll();
    TuioCursor tCur = wrap.tCursor;
    switch(wrap.action) {
    case ADD :
      Cursor newCur = new Cursor(tCur);
      break;


    case REMOVE :
    //println(cursorMap.containsKey(tCur.getSessionID()));
      Cursor remCursor = cursorMap.get(tCur.getSessionID());
      if (remCursor != null) {

        remCursor.OnRemove();
      }
      break;

    case UPDATE :
      Cursor upCursor = cursorMap.get(tCur.getSessionID());
      if (upCursor!=null) {
        upCursor.UpdatePosition();
      }
      break;
    }
  }
}

boolean checkMissing(TuioObject tObj) {
  for (Block miss : missingBlocks) {
    if (dist(miss.x_pos, miss.y_pos, tObj.getScreenX(width), tObj.getScreenY(height)) < block_diameter/2 &&
      miss.sym_id == tObj.getSymbolID()) { //if this block is close a recently missing block
      miss.find(tObj);
      return true;
    }
  }
  return false;
}





