class PlayHead {
  Block activeBlock;
  LinkedList<Lead> path;
  float pathDecayRate = 0.05f;
  float pathDist = 0;
  color playColor;
  int lastMillis = 0;
  boolean dead = false;

  void Init(Block start, color c){
    path = new LinkedList<Lead>();
    playColor = c;
    activeBlock = start;
    allPlayHeads.add(this);
  }
  
  PlayHead(Block start, color c) {
    Init(start, c);
    activeBlock.Activate(this, null);
  }
  
  PlayHead(Block start, Block previous, color c) {
    Init(start, c);
    activeBlock.Activate(this, previous);
  }

  public void Update() {
    pathDist = pathDist * (1-pathDecayRate);// * ((float)(millis() - lastMillis)/1000.0));
    lastMillis = millis();
    if (dead && pathDist <= 0) {
      //allPlayHeads.remove(this); //causes concurrent modification exception
    }
  }

  public void draw() {
    highlightPath();
  }

  void travel() {
    //println("playhead travel");
    int[] nextBlockIndices = activeBlock.getSuccessors();
    for (int i = 0; i<nextBlockIndices.length; i++) {

      Block nextBlock = activeBlock.children[nextBlockIndices[i]];
      if (nextBlock != null) {
        if (i > 0) {
          PlayHead newPlay = new PlayHead(nextBlock, playColor);
          newPlay.addLead(activeBlock.leads[nextBlockIndices[i]]);
        } else {
          addLead(activeBlock.leads[nextBlockIndices[i]]);
          Block lastBlock = activeBlock;
          activeBlock = nextBlock;
          nextBlock.Activate(this, lastBlock);
        }
      } else {
        dead = true;
      }
    }
  }

  void highlightPath() {

    float totalDist = 0;
    for (Lead l : path) {
      totalDist += l.distance - block_diameter;
    }

    while (totalDist - (path.getLast ().distance - block_diameter) > pathDist) {
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
}

