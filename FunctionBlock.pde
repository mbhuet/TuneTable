class FunctionBlock extends Block {
  float dashedLineOffset = 0;
  ArrayList<PlayHead> spawnedPlayHeads;
  ExecuteButton executeButt;
  StopButton stopButt;
  boolean waitingForBeat = false;
  int waitUntil;

  FunctionBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  FunctionBlock(int x, int y, int id) {
    Init(1, x, y, id);
  }

  void Setup() { //ARRAY INDEX OUT OF BOUNDS
    allFunctionBlocks.add(this);
    funcMap.put(sym_id, this);
    spawnedPlayHeads = new ArrayList<PlayHead>();
    canBeChained = false;

    leadsActive = true;
    executeButt = new ExecuteButton(this, -block_diameter, 0, 0, block_diameter/4);
    stopButt = new StopButton(this, -block_diameter, 0, 0, block_diameter/4);
    stopButt.isShowing = false;
    blockColor = colorSet[sym_id];
  }

  void Update() {
    super.Update();
    dashedLineOffset = (millis() % (millisPerBeat * .5) / (float)(millisPerBeat * .5));
    
    arrangeButtons();

    if (waitingForBeat || spawnedPlayHeads.size() > 0) {
      float beatRadius = block_diameter * 1.5 * (1.0- ( (float)(millis() %millisPerBeat)) / (float)millisPerBeat);

      drawBeat((int)beatRadius);
    }
    if (waitingForBeat && millis() >= waitUntil) {
      createPlayHead();
      waitingForBeat = false;
    }
  }

  void startUpdatePath() {
    ArrayList<Block> activeVisited = new ArrayList<Block>();
    ArrayList<Block> inactiveVisited = new ArrayList<Block>();
    activeVisited.add(this);
    updateLeads(dashedLineOffset, blockColor, true, activeVisited, inactiveVisited);
  }

  void OnRemove() {
    super.OnRemove();
  }

  void Die() {
    super.Die();
    Stop();

    allFunctionBlocks.remove(this);
    funcMap.remove(sym_id);
    executeButt.Destroy();
    executeButt = null;
    stopButt.Destroy();
    stopButt = null;
  }

  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    println("func activated " + millis());
    finish();
  }

  public int[] getSuccessors() {
    return new int[] {
      0
    };
  }
  
  void drawShadow() {
    shapeMode(CORNER);
    fill(blockColor);
    stroke(blockColor);
    strokeWeight(10);
    pushMatrix();
    translate(x_pos, y_pos);
    rotate(rotation + 2*PI / 12);
    shape(playShadow);
    popMatrix();
  }
  
  void arrangeButtons(){
   int butt_x = (int)(x_pos - cos(rotation) * block_diameter * .75);
    int butt_y = (int)(y_pos - sin(rotation) * block_diameter * .75);
    
    executeButt.Update(butt_x, butt_y, rotation);
    stopButt.Update(butt_x, butt_y, rotation);

  }


  void execute() {
    waitingForBeat = true;
    waitUntil = millis() + (millisPerBeat * beatsPerMeasure - millis() % (millisPerBeat * beatsPerMeasure));
    executeButt.isShowing = false;
    stopButt.isShowing = true;

  }

  void createPlayHead() {
    PlayHead pHead = new PlayHead(this, this, blockColor);
  }

  void removePlayHead(PlayHead pHead) {
    spawnedPlayHeads.remove(pHead);
    if (spawnedPlayHeads.size() == 0) {
      if(stopButt != null) //When the block is removed, buttons may be killed before playheads are removed through the playhead Kill Queue
        stopButt.isShowing = false;
      if(executeButt != null)
        executeButt.isShowing = true;
    }
  }

  void Stop() {
    for (PlayHead head : spawnedPlayHeads) {
      killPlayHeads.add(head);
    }
    //spawnedPlayHeads.clear();

    stopButt.isShowing = false;
    executeButt.isShowing = true;
  }
}


class ExecuteButton extends Button {
  FunctionBlock func;

  ExecuteButton(FunctionBlock funcBlock, int x_pos, int y_pos, float rot, float rad) {
    InitButton(x_pos, y_pos, rot, rad);
    func = funcBlock;
  }
  public void Trigger(Cursor cursor) {
    println("play button hit");
    func.execute();
  }
  public void drawButton() {
    noStroke();
    fill(invertColor ? 255 : 0);
    ellipse(x, y, size*2, size*2);
    pushMatrix();
    translate(x, y);
    scale(.8);
    translate(size/6, 0);
    fill(invertColor ? 0 : 255);
    triangle(-size/2, -size/2, 
    -size/2, size/2, 
    size/2, 0);
    popMatrix();
  }
}

class StopButton extends Button {
  FunctionBlock func;

  StopButton(FunctionBlock funcBlock, int x_pos, int y_pos, float rot, float rad) {
    InitButton(x_pos, y_pos, rot, rad);
    func = funcBlock;
  }
  public void Trigger(Cursor cursor) {
    func.Stop();
  }
  public void drawButton() {
    noStroke();
    fill(invertColor ? 255 : 0);
    ellipse(x, y, size*2, size*2);
    pushMatrix();
    translate(x, y);
    fill(invertColor ? 0 : 255);
    rectMode(CENTER);
    rect(0, 0, size, size);
    popMatrix();
  }
}

