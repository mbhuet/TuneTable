import TUIO.*;
import java.util.*; 

TuioProcessing tuioClient;


// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  Block newBlock = new Block(tobj);
  blockMap.put(tobj.getSessionID(), newBlock);
  
  //println("add object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
    Block remBlock = blockMap.get(tobj.getSessionID());
    remBlock.OnRemove();

    blockMap.remove(tobj.getSessionID());

  //println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  blockMap.get(tobj.getSessionID()).Update(tobj);
  //println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
  //        +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  //println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  //println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
  //        +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  //println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}


// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}

void ExDrawTuioObjects(){
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     stroke(0);
             strokeWeight(0);

     color sqColor = 0;

      
     fill(sqColor);
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
    
     fill(255);
     text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
   }

}

void ExDrawTuioCursors(){
  Vector tuioCursorList = tuioClient.getTuioCursors();
   for (int i=0;i<tuioCursorList.size();i++) {
      TuioCursor tcur = (TuioCursor)tuioCursorList.elementAt(i);
      Vector pointList = tcur.getPath();
      
      if (pointList.size()>0) {
        stroke(0,0,255);
        TuioPoint start_point = (TuioPoint)pointList.firstElement();;
        for (int j=0;j<pointList.size();j++) {
           TuioPoint end_point = (TuioPoint)pointList.elementAt(j);
           line(start_point.getScreenX(width),start_point.getScreenY(height),end_point.getScreenX(width),end_point.getScreenY(height));
           start_point = end_point;
        }
        
        stroke(192,192,192);
        fill(192,192,192);
        ellipse( tcur.getScreenX(width), tcur.getScreenY(height),cur_size,cur_size);
        fill(0);
        text(""+ tcur.getCursorID(),  tcur.getScreenX(width)-5,  tcur.getScreenY(height)+5);
      }
   }
}

boolean TuioObjectNeighbors(TuioObject objA, TuioObject objB){
  float degreeRange = 20;
  if (objB.getAngle() > objA.getAngle() + degreeRange/2.0 || 
      objB.getAngle() < objA.getAngle() - degreeRange/2.0){
      return false;
  }
  
  float obj_length = obj_size; // this needs to be replaced with a call to a table with block lengths for each ID
  float searchX = objA.getScreenX(width) + cos(objA.getAngle()) * obj_length;
  float searchY = objA.getScreenY(height)+ sin(objA.getAngle()) * obj_length;
  float searchRadius = obj_size/2.0;
  
  fill(color(100));
  ellipse(searchX, searchY, searchRadius, searchRadius);
  if (dist(searchX, searchY, objB.getScreenX(width), objB.getScreenY(height)) > searchRadius){
    return false;
  }
  
  return true;
}

boolean BlockNeighbors(Block left, Block right){
  float degreeRange = 20;
  if (right.rotation > left.rotation + degreeRange/2.0 || 
      right.rotation < left.rotation - degreeRange/2.0){
      return false;
  }
  
  float obj_length = obj_size; // this needs to be replaced with a call to a table with block lengths for each ID
  float searchX = left.x_pos + cos(left.rotation) * obj_length;
  float searchY = left.y_pos + sin(left.rotation) * obj_length;
  float searchRadius = obj_size/2.0;
  
  fill(color(100));
  strokeWeight(0);
  //ellipse(searchX, searchY, searchRadius, searchRadius);
  if (dist(searchX, searchY, right.x_pos, right.y_pos) > searchRadius){
    return false;
  }
  
  return true;
}

boolean TuioObjectParameter(TuioObject objA, TuioObject objB){
  /* Don't think we'll need this
  float degreeRange = 20;
  if (objB.getAngle() > objA.getAngle() + degreeRange/2.0 || 
      objB.getAngle() < objA.getAngle() - degreeRange/2.0){
      return false;
  }
  */
  
  float obj_length = obj_size; // this needs to be replaced with a call to a table with block lengths for each ID
  float searchX = objA.getScreenX(width) + cos(objA.getAngle() + 3*PI/2) * obj_length;
  float searchY = objA.getScreenY(height)+ sin(objA.getAngle() + 3*PI/2) * obj_length;
  float searchRadius = obj_size/2.0;
  
  fill(color(100));
  ellipse(searchX, searchY, searchRadius, searchRadius);
  if (dist(searchX, searchY, objB.getScreenX(width), objB.getScreenY(height)) > searchRadius){
    return false;
  }
  
  return true;
}
