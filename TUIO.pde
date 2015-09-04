import TUIO.*;
import java.util.*; 
import java.util.concurrent.*;


TuioProcessing tuioClient;

/*
AbstractQueue<TuioObject> addQueue = new ConcurrentLinkedQueue<TuioObject>();
AbstractQueue<Block> killQueue = new ConcurrentLinkedQueue<Block>();
AbstractQueue<Block> updateQueue = new ConcurrentLinkedQueue<Block>();
*/

AbstractQueue<TuioObject> blockQueue = new ConcurrentLinkedQueue<TuioObject>();
AbstractQueue<TuioAction> actionQueue = new ConcurrentLinkedQueue<TuioAction>();



AbstractQueue<TuioCursor> cursorQueue = new ConcurrentLinkedQueue<TuioCursor>();



// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (!isInitiated) return;
  blockQueue.offer(tobj);
  actionQueue.offer(TuioAction.ADD);
    
  /*
  Block newBlock = new Block(tobj);
  */
  
  //println("add object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

  
// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (!isInitiated) return;
  
  blockQueue.offer(tobj);
  actionQueue.offer(TuioAction.REMOVE);
  
  /*
  Block remBlock = blockMap.get(tobj.getSessionID());
  if (remBlock != null)  killQueue.add(remBlock);
  */
  
  //println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}


// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (!isInitiated) return;
  
  blockQueue.offer(tobj);
  actionQueue.offer(TuioAction.UPDATE);
  
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
  //println("tuio update");
  
  /*
  while (killQueue.peek () != null) {
    Block remBlock = killQueue.poll();
    remBlock.OnRemove();
    blockMap.remove(remBlock.tuioObj.getSessionID());
  }
  while (addQueue.peek () != null) {
    TuioObject tobj = addQueue.poll();
    Block newBlock = new Block(tobj);
    blockMap.put(newBlock.tuioObj.getSessionID(), newBlock);
  }
  while (updateQueue.peek () != null) {
    Block upBlock = updateQueue.poll();
    upBlock.Update();
  }
  */
  
  while (blockQueue.peek () != null) {
    TuioObject curBlock = blockQueue.poll();
    switch(actionQueue.poll()){
      case ADD :
        Block newBlock = new Block(curBlock);
        blockMap.put(newBlock.tuioObj.getSessionID(), newBlock);
        break;
        
      case REMOVE :
        Block remBlock = blockMap.get(curBlock.getSessionID());
        if (remBlock != null){
          remBlock.OnRemove();
          blockMap.remove(remBlock.tuioObj.getSessionID());
        }
        break;
        
      case UPDATE :
        Block upBlock = blockMap.get(curBlock.getSessionID());
        if (upBlock!=null){
          upBlock.Update();
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


void ExDrawTuioObjects() {
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0; i<tuioObjectList.size (); i++) {
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
    stroke(0);
    strokeWeight(0);

    color sqColor = 0;


    fill(sqColor);
    pushMatrix();
    translate(tobj.getScreenX(width), tobj.getScreenY(height));
    rotate(tobj.getAngle());
    rect(-block_height/2, -block_height/2, block_height, block_height);
    popMatrix();

    fill(255);
    text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
  }
}

void ExDrawTuioCursors() {
  Vector tuioCursorList = tuioClient.getTuioCursors();
  for (int i=0; i<tuioCursorList.size (); i++) {
    TuioCursor tcur = (TuioCursor)tuioCursorList.elementAt(i);
    Vector pointList = tcur.getPath();

    if (pointList.size()>0) {
      stroke(0, 0, 255);
      TuioPoint start_point = (TuioPoint)pointList.firstElement();
      ;
      for (int j=0; j<pointList.size (); j++) {
        TuioPoint end_point = (TuioPoint)pointList.elementAt(j);
        line(start_point.getScreenX(width), start_point.getScreenY(height), end_point.getScreenX(width), end_point.getScreenY(height));
        start_point = end_point;
      }

      stroke(192, 192, 192);
      fill(192, 192, 192);
      ellipse( tcur.getScreenX(width), tcur.getScreenY(height), cur_size, cur_size);
      fill(0);
      text(""+ tcur.getCursorID(), tcur.getScreenX(width)-5, tcur.getScreenY(height)+5);
    }
  }
}

boolean TuioObjectNeighbors(TuioObject objA, TuioObject objB) {
  float degreeRange = 20;
  if (objB.getAngle() > objA.getAngle() + degreeRange/2.0 || 
    objB.getAngle() < objA.getAngle() - degreeRange/2.0) {
    return false;
  }

  float obj_length = block_height; // this needs to be replaced with a call to a table with block lengths for each ID
  float searchX = objA.getScreenX(width) + cos(objA.getAngle()) * obj_length;
  float searchY = objA.getScreenY(height)+ sin(objA.getAngle()) * obj_length;
  float searchRadius = block_height/2.0;

  fill(color(100));
  ellipse(searchX, searchY, searchRadius, searchRadius);
  if (dist(searchX, searchY, objB.getScreenX(width), objB.getScreenY(height)) > searchRadius) {
    return false;
  }

  return true;
}

boolean BlockNeighbors(Block left, Block right) {
  if (right.sym_id == 0) return false; //Play blocks can never be a right neighbor, only left
  float degreeRange = 20;
  if (right.rotation > left.rotation + degreeRange/2.0 || 
    right.rotation < left.rotation - degreeRange/2.0) {
    return false;
  }

  float obj_length = left.block_width;
  float searchX = left.x_pos + cos(left.rotation) * obj_length;
  float searchY = left.y_pos + sin(left.rotation) * obj_length;
  float searchRadius = block_height/2.0;

  fill(color(100));
  strokeWeight(0);
  //ellipse(searchX, searchY, searchRadius, searchRadius);
  if (dist(searchX, searchY, right.x_pos, right.y_pos) > searchRadius) {
    return false;
  }

  return true;
}

boolean TuioObjectParameter(TuioObject objA, TuioObject objB) {

  float obj_length = block_height; // this needs to be replaced with a call to a table with block lengths for each ID
  float searchX = objA.getScreenX(width) + cos(objA.getAngle() + 3*PI/2) * obj_length;
  float searchY = objA.getScreenY(height)+ sin(objA.getAngle() + 3*PI/2) * obj_length;
  float searchRadius = block_height/2.0;

  fill(color(100));
  ellipse(searchX, searchY, searchRadius, searchRadius);
  if (dist(searchX, searchY, objB.getScreenX(width), objB.getScreenY(height)) > searchRadius) {
    return false;
  }

  return true;
}

