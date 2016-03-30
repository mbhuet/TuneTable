class PlayHead {
  FunctionBlock origin;
  Block activeBlock;
  LinkedList<Lead> path;
  float pathDecayRate = 0.01f;
  float minDecayDist = .5f;
  float pathDist = 0;
  color playColor;
  int lastMillis = 0;
  boolean dead = false;

  Stack<CallBlock> functionCallStack;

  void Init(FunctionBlock origin, Block start, color c) {
    path = new LinkedList<Lead>();
    playColor = c;
    activeBlock = start;
    allPlayHeads.add(this);
    this.origin = origin;
    origin.spawnedPlayHeads.add(this);
functionCallStack = new Stack<CallBlock>();
    //println("init activeBlock " + activeBlock);
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
    //println("activeBlock " + activeBlock);
    pathDist = min(pathDist - minDecayDist, pathDist * (1-pathDecayRate));// * ((float)(millis() - lastMillis)/1000.0));
    if(pathDist <0) pathDist = 0;
    lastMillis = millis();
    if (dead && pathDist <= 1) {
      killPlayHeads.add(this);
      //println("add playhead to kill list");
    }
  }

  public void draw() {
    highlightPath();
  }

  void travel() {
    Block currentBlock = activeBlock; //activeBlock may change, so we need to keep a reference to it
    boolean hasTravelled = false; //if there are more than 1 valid successors, 
    int[] nextBlockIndices = currentBlock.getSuccessors();
    //println("playhead " + this + " travelling to " + Arrays.toString(nextBlockIndices));
    for (int i = 0; i< nextBlockIndices.length; i++) {
      int indexOfSuccessor = nextBlockIndices[i];
      Block nextBlock = currentBlock.children[indexOfSuccessor];
      if (nextBlock != null && nextBlock.inChain) { //if there is a block
        if (!hasTravelled) {
          addLead(currentBlock.leads[indexOfSuccessor]);
          activeBlock = nextBlock;
          nextBlock.Activate(this, currentBlock);
          hasTravelled = true;
        } else {  
          PlayHead newPlay = new PlayHead(origin, nextBlock, currentBlock, playColor);
          newPlay.addLead(currentBlock.leads[indexOfSuccessor]);
        }
      } else { //there is no block ahead
        // if there are any start Loops in the stack, we'll jump back to it
        if (functionCallStack.size() > 0) {
          activeBlock = functionCallStack.pop();
          activeBlock.Activate(this, currentBlock);
          hasTravelled = true;
        }
      }
    }

    if (!hasTravelled) {
      dead = true;
      println("playhead " + this + " dead");
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

  void highlightPath() {
    if (path.peekFirst() == null) return;

    float totalDist = 0;
    for (Lead l : path) {
      totalDist += l.distance - block_diameter;
    }
    
    while (path.peekFirst() != null && totalDist - (path.getLast ().distance - block_diameter) > pathDist) { //NO SUCH ELEMENT EXCEPTION
      totalDist = totalDist - (path.getLast().distance - block_diameter);
      
      path.removeLast();
    }

    float remDist = pathDist;


    for (Lead l : path) {
      if (remDist >= (l.distance - block_diameter)) {
        l.highlightTravelled(origin.sym_id, 1, playColor);
        remDist -= l.distance - block_diameter;
      } else {
        float percent = (remDist/(l.distance - block_diameter));
        l.highlightTravelled(origin.sym_id, percent, playColor);
      }
    }
  }

  void addLead(Lead lead) {
    path.offerFirst(lead);
    pathDist += lead.distance - block_diameter;
        println(pathDist);

  }

  public void addFunctionCall(CallBlock call) {
    if (functionCallStack.size() > 0 && functionCallStack.peek() == call) {
      functionCallStack.pop();
    } else {    
      functionCallStack.push(call);
    }
  }

  void Die() {
    println("PlayHead " + this + " Die");
    if (activeBlock instanceof SoundBlock) {
      ((SoundBlock)activeBlock).Stop();
    }
    allPlayHeads.remove(this);
    origin.removePlayHead(this);
  }
}

