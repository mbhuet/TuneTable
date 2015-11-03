class FunctionBlock extends Block {
  float dashedLineOffset = 0;
  ArrayList<PlayHead> spawnedPlayHeads;
  ExecuteButton executeButt;
  StopButton stopButt;
  boolean waitingForBeat = false;
  int waitUntil;

  FunctionBlock(TuioObject tObj) {
    Init(tObj, 1);
    leadsActive = true;
    executeButt = new ExecuteButton(this, -block_diameter, 0, 0, block_diameter/4);
    stopButt = new StopButton(this, -block_diameter, 0, 0, block_diameter/4);
    stopButt.isShowing = false;
    blockColor =     color(random(255), random(255), random(255));
  }

  void Setup() {
    allFunctionBlocks.add(this);
    funcMap.put(sym_id, this);
    spawnedPlayHeads = new ArrayList<PlayHead>();
    canBeChained = false;
  }

  void Update() {
    super.Update();
    dashedLineOffset = (millis() % (millisPerBeat * 4) / (float)(millisPerBeat * 4));
    executeButt.Update((int)(x_pos - cos(rotation) * block_diameter), (int)(y_pos - sin(rotation) * block_diameter), rotation);
    stopButt.Update((int)(x_pos - cos(rotation) * block_diameter), (int)(y_pos - sin(rotation) * block_diameter), rotation);

    if (waitingForBeat && millis() >= waitUntil) {
      createPlayHead();
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
    allFunctionBlocks.remove(this);
    funcMap.remove(sym_id);
    executeButt.Destroy();
    executeButt = null;
    Stop();
  }

  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    println("func activated");
    finish();
  }

  public int[] getSuccessors() {
    return new int[] {
      0
    };
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
  
  void removePlayHead(PlayHead pHead){
    spawnedPlayHeads.remove(pHead);
    if(spawnedPlayHeads.size() == 0){
      stopButt.isShowing = false;
    executeButt.isShowing = true;
    }
  }

  void Stop() {
    for (PlayHead head : spawnedPlayHeads) {
      killPlayHeads.add(head);
    }
    spawnedPlayHeads.clear();
    stopButt.isShowing = false;
    executeButt.isShowing = true;
    
  }
}


class ExecuteButton extends Button {
  FunctionBlock func;

  ExecuteButton(FunctionBlock funcBlock, int x_pos, int y_pos, float rot, float rad) {
    InitButton(x_pos, y_pos, rot, rad);
    func = funcBlock;
    println("exec button");
  }
  public void Trigger(Cursor cursor) {
    println("play button hit");
    func.execute();
  }
  public void drawButton() {
    fill(color(0, 0, 0));
    ellipse(x, y, size*2, size*2);
    pushMatrix();
    translate(x, y);
    scale(.8);
    translate(size/6, 0);
    fill(color(255, 255, 255));
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
    fill(color(0, 0, 0));
    ellipse(x, y, size*2, size*2);
    pushMatrix();
    translate(x, y);
    fill(color(255, 255, 255));
    rectMode(CENTER);
    rect(0, 0, size, size);
    popMatrix();
  }
}

