public class Cursor {
  int x_pos, y_pos;
  TuioCursor tuioCursor;
  int spawnTime;
  int spawnDelay;
  boolean dead;
  boolean isMouse = false;
  ArrayList<BeatButton> beatHistory;

  Cursor(TuioCursor c) {
    Init();
    setTuioCursor(c);

  }
  
  Cursor(){
    Init();
    isMouse = true;
  }

  void Init() {
    spawnTime = millis();
    checkButtons();
    dead = false;
    beatHistory = new ArrayList<BeatButton>();
    cursors.add(this);
  }

  void UpdatePosition() {
    x_pos = tuioCursor.getScreenX(width);
    y_pos = tuioCursor.getScreenY(height);    
  }
  
  void checkButtons(){
    for (Button b : allButtons) {
      if (!dead && b.isShowing && b.IsUnder(x_pos, y_pos) && !beatHistory.contains(b)) {
                        b.Trigger(this);

        if(b instanceof BeatButton){
          
          beatHistory.add((BeatButton)b);
        }
        else dead = true;
        

      }
    }
  }
  
  void Update(){
    if(isMouse){
      x_pos = mouseX;
      y_pos = mouseY;
    }
    if (!dead) checkButtons();
    
    if (debug){
    
    stroke(color(255,0,0));
    strokeWeight(3);
    noFill();
    ellipse(x_pos, y_pos, 5,5);
    }
  }

  void OnRemove() {
        cursors.remove(this);

    if(!isMouse)cursorMap.remove(tuioCursor.getSessionID());
  }

  void setTuioCursor(TuioCursor tCur) {
    tuioCursor = tCur;
    cursorMap.put(tCur.getSessionID(), this);
  }
}

