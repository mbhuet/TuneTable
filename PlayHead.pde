class PlayHead {
  FunctionBlock origin;
  Block activeBlock;
  LinkedList<Lead> path;
  float pathDecayRate = 1; //pixels/second
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
    lastMillis = millis();
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
                   println("Update pathDist to " + (deltaTime));
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
      totalDist += l.distance - block_diameter;
    }

    //while there are Leads at the end of path that will no longer be reached given our current pathDist, remove them from path
    while (path.peekFirst () != null && (totalDist - (path.getLast ().distance - block_diameter)) > pathDist) {
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

