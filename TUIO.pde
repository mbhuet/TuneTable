import TUIO.*;
import java.util.*; 
import java.util.concurrent.*;


TuioProcessing tuioClient;

AbstractQueue<TuioActionWrapper> actionQueue = new ConcurrentLinkedQueue<TuioActionWrapper>();
AbstractQueue<TuioCursor> cursorQueue = new ConcurrentLinkedQueue<TuioCursor>();


class TuioActionWrapper{
  TuioAction action;
  TuioObject tObject;
  
  TuioActionWrapper(TuioObject tObj, TuioAction act){
    action = act;
    tObject = tObj;
  }
}


// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (!isInitiated) return;
  actionQueue.offer(new TuioActionWrapper(tobj, TuioAction.ADD));
    
  /*
  Block newBlock = new Block(tobj);
  */
  
  //println("add object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

  
// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (!isInitiated) return;
  
  actionQueue.offer(new TuioActionWrapper(tobj, TuioAction.REMOVE));
  
  /*
  Block remBlock = blockMap.get(tobj.getSessionID());
  if (remBlock != null)  killQueue.add(remBlock);
  */
  
  //println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}


// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (!isInitiated) return;
  
  actionQueue.offer(new TuioActionWrapper(tobj, TuioAction.UPDATE));
  
  /*
  Block b = blockMap.get(tobj.getSessionID());
  
  if (b!=null){
    updateQueue.add(b);
  }
  */
  
  //println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
  //        +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  if (!isInitiated) return;
  cursorQueue.add(tcur);
  //println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  if (!isInitiated) return;

  //println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
  //        +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (!isInitiated) return;

  //println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
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
    switch(wrap.action){
      case ADD :
        Block newBlock;
        println(curObj.getSymbolID());
        BlockType type = idToType.get(curObj.getSymbolID());
        switch (type){
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
          
          default:
                      newBlock = new FunctionBlock(curObj);
          break;
        }
      
        //Block newBlock = new Block(curBlock);
        blockMap.put(newBlock.tuioObj.getSessionID(), newBlock);
        
        break;
        
      case REMOVE :
        Block remBlock = blockMap.get(curObj.getSessionID());
        if (remBlock != null){
          remBlock.OnRemove();
          blockMap.remove(remBlock.tuioObj.getSessionID());
        }
        break;
        
      case UPDATE :
        Block upBlock = blockMap.get(curObj.getSessionID());
        if (upBlock!=null){
          upBlock.UpdatePosition();
        }
        break;
        
    }
  }
  
  
  while (cursorQueue.peek () != null) {
        TuioCursor cur = cursorQueue.poll();

    //println(cur.getScreenX(width) + ", " + cur.getScreenY(height));
    Click((int)cur.getScreenX(width), (int)cur.getScreenY(height));
  }
  //println("tuio stop");
}





