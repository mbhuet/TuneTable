abstract class Block {

  TuioObject tuioObj;
  int sym_id;
  float x_pos;
  float y_pos;
  float rotation;
  BlockType type;
  int numLeads = 0;
  boolean leadsActive = false;
  boolean isMissing = false;

  float block_width;

  ArrayList<Block> parents;
  Block[] children;
  Lead[] leads;

  LinkedList<PlayHead> playHeadList = new LinkedList<PlayHead>();

  ArrayList<PVector> posHistory = new ArrayList<PVector>();
  ArrayList<Float> rotHistory = new ArrayList<Float>();
  int historyVals = 10;
  int missingSince = 0;
  final int deathDelay = 2000;

  abstract void Setup();
  abstract int[] getSuccessors();

  void Init(TuioObject tobj, int numLeads) {
    this.numLeads = numLeads;
    tuioObj = tobj;
    sym_id = tobj.getSymbolID();
    allBlocks.add(this);

    parents = new ArrayList<Block>();
    children = new Block[numLeads];
    leads = new Lead[numLeads];

    for (int i = 0; i<numLeads; i++) {
      leads[i] = new Lead(this, i * 2*PI / numLeads);
    }

    Setup();
  }

  void Update() { 
    for (int i = 0; i< numLeads; i++) {
      Lead l = leads[i];
      l.Update();
      if (l.distance > l.break_distance) {
        breakConnection(i);
      }
    }
    if (isMissing){
      if (millis() - missingSince >= deathDelay){
        Die();
      }
    }
  }
  
  

  void OnRemove() {
    missingBlocks.add(this);
    isMissing = true;
    missingSince = millis();
  }
  
  void Die(){
    breakAllConnections();
    allBlocks.remove(this);
  }

  //previous is the block that has lead the PlayHead to this block
  public void Activate(PlayHead play, Block previous) {
    playHeadList.add(play);
    //println(sym_id);
  }

  public void finish() {
    PlayHead play = playHeadList.pop();
    play.travel();
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

    //these two methods could be combined for efficiency, if necessary
    findParents();
    if (leadsActive) {
      findChildren();
    }
  }




  public void findChildren() {
    for (int i = 0; i<numLeads; i++) {
      if (children[i] == null) {
        for (Block block : allBlocks) {
          if (!(block.parents.contains(this) || this.parents.contains(block)) && leads[i].isUnderBlock(block)) {
            makeConnection(block, i);
          }
        }
      }
    }
  }

  public void findParents() {
    for (Block block : allBlocks) {
      for (int i = 0; i< block.numLeads; i++) {
        if (block.children[i] == null) {
          if (!(block.parents.contains(this) || this.parents.contains(block)) && block.leads[i].isUnderBlock(this)) {
            block.makeConnection(this, i);
          }
        }
      }
    }
  }

  public void breakAllConnections() {
    for (int i = 0; i< numLeads; i++) {
      breakConnection(i);
    }
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
    if (leadsActive)
      drawLeads();
  }

  void drawShadow() {
    strokeWeight(0);
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
    fill(0);  // Set fill to black
    ellipse(x_pos, y_pos, block_diameter, block_diameter);
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
    return ("\nid: " + sym_id + "  x: " + x_pos + "  y: " + y_pos);
  }
}

