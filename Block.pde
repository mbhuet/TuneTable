abstract class Block {

  TuioObject tuioObj;
  int sym_id;
  float x_pos;
  float y_pos;
  float rotation;
  BlockType type;
  int numLeads = 0;
  boolean leadsActive = false;
  boolean inChain = false;
  boolean canBeChained = true;
  boolean isMissing = false;
  boolean isFake;
  color blockColor;

  float block_width;

  public ArrayList<Block> parents;
  public Block[] children;
  public Lead[] leads;

  LinkedList<PlayHead> playHeadList = new LinkedList<PlayHead>();
  PlayHead playHead;

  ArrayList<PVector> posHistory = new ArrayList<PVector>();
  ArrayList<Float> rotHistory = new ArrayList<Float>();
  int historyVals = 10;
  int missingSince = 0;
  final int deathDelay = 500;

  abstract void Setup();
  abstract int[] getSuccessors();

  void Init(TuioObject tobj, int numLeads) {
    this.numLeads = numLeads;
    setTuioObject(tobj);
    allBlocks.add(this);

    parents = new ArrayList<Block>();
    children = new Block[numLeads];
    leads = new Lead[numLeads];

    for (int i = 0; i<numLeads; i++) {
      leads[i] = new Lead(this, rotation + i * 2*PI / numLeads);
    }

    blockColor = color(invertColor ? 255 : 0);

    Setup();
  }

  void Init(int numLeads, int x, int y, int id) {
    this.numLeads = numLeads;
    this.sym_id = id;
    allBlocks.add(this);

    parents = new ArrayList<Block>();
    children = new Block[numLeads];
    leads = new Lead[numLeads];

    for (int i = 0; i<numLeads; i++) {
      leads[i] = new Lead(this, rotation + i * 2*PI / numLeads);
    }

    blockColor = color(invertColor ? 255 : 0);
    isFake = true;
    x_pos = x; 
    y_pos = y;

    Setup();
  }

  void setTuioObject(TuioObject tobj) {
    tuioObj = tobj;
    sym_id = tobj.getSymbolID();
    blockMap.put(tobj.getSessionID(), this);
  }

  void Update() { 
    for (int i = 0; i< numLeads; i++) {
      Lead l = leads[i];
      l.Update();
      if (l.distance > l.break_distance) {
        breakConnection(i);
      }
    }
    if (isMissing) {
      if (millis() - missingSince >= deathDelay) {
        if (isReadyToDie()) {
          missingBlocks.remove(this);
          killBlocks.add(this);
        }
      }
    }
    if (isFake) {
      updateNeighbors();
    }
  }



  void OnRemove() {    
    missingBlocks.add(this);
    isMissing = true;
    missingSince = millis();
    if (!isFake)blockMap.remove(tuioObj.getSessionID());
  }

  void find(TuioObject newObj) {
    isMissing = false;
    missingBlocks.remove(this);
    if (!isFake)setTuioObject(newObj);
  }

  void Die() {
    breakAllConnections();
    allBlocks.remove(this);
    missingBlocks.remove(this);
    if (!isFake)blockMap.remove(tuioObj.getSessionID());
   

  }

  boolean isReadyToDie() {
    return true;
  }

  //previous is the block that has lead the PlayHead to this block
  public void Activate(PlayHead play, Block previous) {
    //playHeadList.add(play);
    playHead = play;
    //println("activate " + this + " " +playHead);
  } 

  public void finish() {
    //PlayHead play = playHeadList.pop();
    //println("finish " + this + " " +playHead);
    playHead.travel();
    if (playHead != null)playHead = null;
  }




  public void UpdatePosition() {
    float new_x_pos = tuioObj.getScreenX(width);// - cos(rotation) * (.5/3.25) * block_height;
    float new_y_pos = tuioObj.getScreenY(height);// - sin(rotation) * (.5/3.25) * block_height;

    rotHistory.add(tuioObj.getAngle());
    posHistory.add(new PVector(new_x_pos, new_y_pos));

    if (posHistory.size() < historyVals) {
      x_pos = new_x_pos;
      y_pos = new_y_pos;
      rotation = tuioObj.getAngle();
    } else {

      if (posHistory.size() > historyVals) {
        posHistory.remove(0);
      }

      if (rotHistory.size() > historyVals) {
        rotHistory.remove(0);
      }

      float avg_x = 0;
      float avg_y = 0;

      float avg_rot = 0;
      float sum_cos = 0;
      float sum_sin = 0;

      for (int i = 0; i<posHistory.size (); i++) {
        avg_x += posHistory.get(i).x;
        avg_y += posHistory.get(i).y;
      }

      for (int i = 0; i<rotHistory.size (); i++) {
        sum_cos += cos(rotHistory.get(i));
        sum_sin += sin(rotHistory.get(i));
      }

      avg_rot = atan2(sum_sin, sum_cos);

      avg_x = avg_x/posHistory.size();
      avg_y = avg_y/posHistory.size();

      x_pos = avg_x;
      y_pos = avg_y;

      for (Lead l : leads) { 
        if (!l.occupied)  l.rotation += (avg_rot - rotation); //this will cause unconnected leads to rotate with the block
      }
      rotation = avg_rot;
    }

    updateNeighbors();
  }

  public boolean childIsSuccessor(int i) {
    return (i < numLeads);
  }

  public void updateNeighbors(){
  if (this.canBeChained) {
        findParents();
        
      }
      if (leadsActive) {
        findChildren();

      }
  }


  public void findChildren() {
    for (int i = 0; i<numLeads; i++) {
      if (children[i] == null) {
        for (Block block : allBlocks) {
          if (!( block==this || block.parents.contains(this) || this.parents.contains(block)) && leads[i].isUnderBlock(block) && block.canBeChained) {
            makeConnection(block, i);
            break;
          }
        }
      }
    }
  }

  public void findParents() {
    for (Block block : allBlocks) {
      for (int i = 0; i< block.numLeads; i++) {
        if (block.children[i] == null) {
          if (!( block==this || block.parents.contains(this) || this.parents.contains(block)) && block.leadsActive && block.leads[i].isUnderBlock(this)) {
            block.makeConnection(this, i);

          }
        }
      }
    }
  }

  public void breakAllConnections() {
    breakChildConnections();
    breakParentConnections();
  }

  public void breakChildConnections() {
    for (int i = 0; i< numLeads; i++) {
      breakConnection(i);
    }
  }

  public void breakParentConnections() {
    Block[] parentsArray = new Block[parents.size()];
    parents.toArray(parentsArray);
    for (Block p : parentsArray) {
      p.breakConnection(this);
    }
  }

  void makeConnection(Block b, int i) {
    if (children[i] != null) 
      breakConnection(i);
    children[i] = b;
    leads[i].connect(b);
    b.parents.add(this);
  }

  void breakConnection(int i) {
    if (children[i] != null) {
      children[i].parents.remove(this);
      children[i] = null;
      leads[i].disconnect();
    }
  }

  void breakConnection(Block b) {
    for (int i = 0; i<numLeads; i++) {
      if (children[i] == b) {
        children[i].parents.remove(this);
        children[i] = null;
        leads[i].disconnect();
      }
    }
  }


  public void draw() {
    drawShadow();
  }

  void drawShadow() {
    strokeWeight(0);
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
    fill(blockColor);  // Set fill to black
    ellipse(x_pos, y_pos, block_diameter, block_diameter);
  }

  void updateLeads(float offset, color col, boolean isActive, ArrayList<Block> activeVisited, ArrayList<Block> inactiveVisited) {
    this.inChain = true;
    blockColor = col;
    //println(sym_id + " " + millis());
    for (int i = 0; i< numLeads; i++) {     
      if (isActive && childIsSuccessor(i)) {
        leads[i].options.dashed = true;
        leads[i].options.offset = offset;
        leads[i].options.col = col;
        leads[i].options.weight = 10;

        if (children[i] != null && !activeVisited.contains(children[i])) {
          activeVisited.add(children[i]);
          children[i].updateLeads(offset, col, true, activeVisited, inactiveVisited);
        }
      } else {
        leads[i].options.dashed = false;
        leads[i].options.col = color(0);
        leads[i].options.weight = 3;

        if (children[i] != null && !activeVisited.contains(children[i]) && !inactiveVisited.contains(children[i])) {
          inactiveVisited.add(children[i]);
          children[i].updateLeads(offset, col, false, activeVisited, inactiveVisited);
        }
      }
    }
  }


  void drawArc(int radius, float percent, float startRotation) {
    pushMatrix();
    noStroke();
    fill(blockColor);
    translate(x_pos, y_pos);
    rotate(startRotation);
    arc(0, 0, 
    block_diameter + radius, 
    block_diameter + radius, 
    0, 
    percent * 2 * PI, //(float)clip.position()/(float)clip.length() * 2*PI, 
    PIE);
    popMatrix();
  }

  void drawBeat(int radius) {
    pushMatrix();
    fill(blockColor);
    noStroke();
    translate(x_pos, y_pos);
    rotate(0); //should rotate such that the start angle points to the parent
    ellipse(0, 0, radius, radius);
    popMatrix();
  }

  void drawLeads() {

    for (Lead l : leads) {
      l.draw();
    }
  }

  public boolean IsUnder(int hit_x, int hit_y) {
    //will return true if the hit is near the symbol position
    return (dist(hit_x, hit_y, x_pos, y_pos) < block_diameter/2);
  }

  public String toString() {
    return ("id: " + sym_id + "  x: " + x_pos + "  y: " + y_pos);
  }
}

