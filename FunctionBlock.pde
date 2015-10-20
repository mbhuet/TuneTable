class FunctionBlock extends Block {
  color funcColor;
  float dashedLineOffset = 0;
  ArrayList<PlayHead> spawnedPlayHeads;

  FunctionBlock(TuioObject tObj) {
    Init(tObj, 1);
    leadsActive = true;
    funcColor =     color(0, 102, 153);
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
  }
  
  void startHighlightPath(){
    ArrayList<Block> visited = new ArrayList<Block>();
    visited.add(this);
    updateLeads(dashedLineOffset, funcColor, true, visited);
  }

  void OnRemove() {
    super.OnRemove();
  }

  void Die() {
    super.Die();
    allFunctionBlocks.remove(this);
    funcMap.remove(sym_id);
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
    if (spawnedPlayHeads.size() == 0){
    PlayHead pHead = new PlayHead(this, this, color(0, 102, 153));
    }
  }
  
  void stop(){
  }
}

