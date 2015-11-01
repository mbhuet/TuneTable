class FunctionBlock extends Block {
  float dashedLineOffset = 0;
  ArrayList<PlayHead> spawnedPlayHeads;
  ExecuteButton executeButt;

  FunctionBlock(TuioObject tObj) {
    Init(tObj, 1);
    leadsActive = true;
    executeButt = new ExecuteButton(this, -block_diameter, 0,0, block_diameter/4);
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
    //if (spawnedPlayHeads.size() == 0){
    if (true) {
      PlayHead pHead = new PlayHead(this, this, blockColor);
    }
  }

  void stop() {
  }
}

