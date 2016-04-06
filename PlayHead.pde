class PlayHead {
  FunctionBlock origin;
  Block activeBlock;
  LinkedList<Lead> path;
  float pathDecayRate = 1; //pixels/second
  float minDecayDist = 50;
  float pathDist = 0;
  color playColor;
  int lastMillis = 0;
  boolean dead = false;

  Stack<CallBlock> functionCallStack;

  void Init(FunctionBlock origin, color c) {
    path = new LinkedList<Lead>();
    playColor = c;
    allPlayHeads.add(this);
    this.origin = origin;
    origin.spawnedPlayHeads.add(this);
    functionCallStack = new Stack<CallBlock>();
    lastMillis = millis();
  }

  void Init(FunctionBlock origin, Block start, color c) {
    Init(origin, c);
    activeBlock = start;
  }

  //This constructor is for PlayHeads that will highlight the path of a lead that has no occupant, therefore it won't have a start Block
  PlayHead(FunctionBlock origin, color c) {
    Init(origin, c);
  }

  PlayHead(FunctionBlock origin, Block start, color c) {
    Init(origin, start, c);
    activeBlock.Activate(this, null);
  }

  PlayHead(FunctionBlock origin, Block start, Block previous, color c) {
    Init(origin, start, c);
    activeBlock.Activate(this, previous);
  }

  public void Update() {
    float deltaTime = (float)(millis() - lastMillis)/1000;
    pathDist -= max(minDecayDist * deltaTime, 
    pathDist * pathDecayRate * deltaTime);
    if (pathDist <0) pathDist = 0;
    if (dead && pathDist <= 1) {
      killPlayHeads.add(this);
    }
    lastMillis = millis();
  }

  public void draw() {
    highlightPath();
  }

  void travel() {
    Block currentBlock = activeBlock; //activeBlock may change, so we need to keep a reference to it
    boolean hasTravelled = false; //if there are more than 1 valid successors, 
    int[] nextBlockIndices = currentBlock.getSuccessors();
    for (int i = 0; i< nextBlockIndices.length; i++) {
      int indexOfSuccessor = nextBlockIndices[i];
      Block nextBlock = currentBlock.children[indexOfSuccessor];

      if (nextBlock != null && nextBlock.inChain) { //if there is a block
        if (!hasTravelled) {
          addLead(currentBlock.leads[indexOfSuccessor]);
          activeBlock = nextBlock;
          nextBlock.Activate(this, currentBlock);
          hasTravelled = true;
        } else {//create a new PlayHead that will follow this path
          PlayHead newPlay = new PlayHead(origin, nextBlock, currentBlock, playColor);
          newPlay.addLead(currentBlock.leads[indexOfSuccessor]);
        }
      } else { //there is no block ahead
        if (functionCallStack.size() > 0) {// if there are any CallBlocks in the stack, we'll jump back to the top one
          addLead(currentBlock.leads[indexOfSuccessor]);
          CallBlock callBlock = functionCallStack.pop();
          addLead(callBlock.endLead);
          activeBlock = callBlock;
          activeBlock.Activate(this, currentBlock);
          hasTravelled = true;
        } else if (!hasTravelled) {// this PlayHead will highlight the dead-end lead and die
          addLead(currentBlock.leads[indexOfSuccessor]);
        } else {//create a Playhead that will only highlight the dead-end lead and die
          PlayHead newPlay = new PlayHead(origin, playColor);
          newPlay.addLead(currentBlock.leads[indexOfSuccessor]);
        }
      }
    }

    if (!hasTravelled) {
      dead = true;
      //println("playhead " + this + " dead");
    }
  }

  public void returnToLastFunctionCall() {
    if (functionCallStack.size() == 0) {
      travel();
    } else {
      Block currentBlock = activeBlock; //activeBlock may change, so we need to keep a reference to it
      activeBlock = functionCallStack.pop();
      activeBlock.Activate(this, currentBlock);
    }
  }

  //When the playhead jumps from one block to the next, it leaves a thick line that will shrink to catch up
  void highlightPath() {
    //if there are no Leads in the path, there's nothing to do, so return.
    if (path.peekFirst() == null) return;

    //first we'll get the sum length of all Leads in the path
    float totalDist = 0;
    for (Lead l : path) {
      totalDist += l.distance;// - block_diameter;
    }

    //while there are Leads at the end of path that will no longer be reached given our current pathDist, remove them from path
    while (path.peekFirst () != null && (totalDist - (path.getLast ().distance)) > pathDist) {
      totalDist = totalDist - (path.getLast().distance);

      path.removeLast();
    }

    float remDist = pathDist;

    for (Lead l : path) {
      if (remDist >= (l.distance)) {
        l.highlightTravelled(origin.sym_id, 1, playColor);
        remDist -= l.distance;
      } else {
        float percent = (remDist/(l.distance));
        l.highlightTravelled(origin.sym_id, percent, playColor);
      }
    }
  }

  void addLead(Lead lead) {
    path.offerFirst(lead);
    pathDist += lead.distance;// - block_diameter;
    println("Add Lead pathDist = " + pathDist);
  }

  public void addFunctionCall(CallBlock call) {
    if (functionCallStack.size() > 0 && functionCallStack.peek() == call) {
      functionCallStack.pop();
    } else {    
      functionCallStack.push(call);
    }
  }

  void Die() {
    //println("PlayHead " + this + " Die");
    if (activeBlock instanceof SoundBlock) {
      ((SoundBlock)activeBlock).Stop();
    }
    allPlayHeads.remove(this);
    origin.removePlayHead(this);
  }
}

