class PlayHead {
  FunctionBlock origin;
  Block activeBlock;
  LinkedList<Lead> path;
  float pathDecayRate = 0.05f;
  float pathDist = 0;
  color playColor;
  int lastMillis = 0;
  boolean dead = false;

  void Init(FunctionBlock origin, Block start, color c) {
    path = new LinkedList<Lead>();
    playColor = c;
    activeBlock = start;
    allPlayHeads.add(this);
    this.origin = origin;
    origin.spawnedPlayHeads.add(this);
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
    pathDist = pathDist * (1-pathDecayRate);// * ((float)(millis() - lastMillis)/1000.0));
    lastMillis = millis();
    if (dead && pathDist <= 1) {
      killPlayHeads.add(this);
      println("add playhead to kill list");
    }
  }

  public void draw() {
    highlightPath();
  }

  void travel() {
    boolean hasTravelled = false; //if there are more than 1 valid successors, 
    int[] nextBlockIndices = activeBlock.getSuccessors();
    for (int i = 0; i< nextBlockIndices.length; i++) {
      int indexOfSuccessor = nextBlockIndices[i];
      Block nextBlock = activeBlock.children[indexOfSuccessor];
      if (nextBlock != null) { //if there is a block 
        if (!hasTravelled) {
          addLead(activeBlock.leads[nextBlockIndices[i]]);
          Block lastBlock = activeBlock;
          activeBlock = nextBlock;
          nextBlock.Activate(this, lastBlock);
          hasTravelled = true;
        }
        else{
          PlayHead newPlay = new PlayHead(origin, nextBlock, activeBlock, playColor);
          newPlay.addLead(activeBlock.leads[nextBlockIndices[i]]);
        } 
      }
    }
    
    if (!hasTravelled){
      dead = true;
        println("playhead " + this + " dead");
    }
  }

  void highlightPath() {
    if (path.peekFirst() == null) return;

    float totalDist = 0;
    for (Lead l : path) {
      totalDist += l.distance - block_diameter;
    }

    while (totalDist - (path.getLast ().distance - block_diameter) > pathDist) { //NO SUCH ELEMENT EXCEPTION
      totalDist = totalDist - (path.getLast().distance - block_diameter);

      path.removeLast();
    }

    float remDist = pathDist;


    for (Lead l : path) {
      if (remDist >= (l.distance - block_diameter)) {
        l.highlightTravelled(1, playColor);
        remDist -= l.distance - block_diameter;
      } else {
        float percent = (remDist/(l.distance - block_diameter));
        l.highlightTravelled(percent, playColor);
      }
    }
  }

  void addLead(Lead lead) {
    path.offerFirst(lead);
    pathDist += lead.distance - block_diameter;
  }

  void Die() {
    if (activeBlock instanceof SoundBlock) {
      ((SoundBlock)activeBlock).Stop();
      println("stop playing " + activeBlock);
      //TODO stop playing immediately
    }
    allPlayHeads.remove(this);
    origin.removePlayHead(this);
    println(this);
  }
}

