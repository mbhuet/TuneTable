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

  LinkedList<PlayHead> playHeadList = new LinkedList<PlayHead>(); //currently unused
  PlayHead playHead; //when a playHead passes through this block, it is kept track of here


  ArrayList<PVector> posHistory = new ArrayList<PVector>(); //used to calculate average position
  ArrayList<Float> rotHistory = new ArrayList<Float>();  //used to calculate average rotation
  int historyVals = 10; //how many position and rotation values to store for calculating a moving average (data smoothing)
  int missingSince = 0; //millis when block is reported removed by TUIO
  final int deathDelay = 500; //how many millis after going missing for the block to be removed

  abstract void Setup();
  abstract int[] getSuccessors();


  void Init(TuioObject tobj, int numLeads) {
    this.numLeads = numLeads;
    parents = new ArrayList<Block>();
    children = new Block[numLeads];
    leads = new Lead[numLeads];
    
    setTuioObject(tobj);
    allBlocks.add(this);

    for (int i = 0; i<numLeads; i++) {
      leads[i] = new Lead(this, rotation + i * 2*PI / numLeads, i);
    }
    UpdatePosition();
    arrangeLeads(rotation);
    type = idToType.get(sym_id);

    blockColor = color(invertColor ? 255 : 0);
    Setup();
  }


  /*
    This Init is for simulated blocks and does not require a TuioObject
   */
  void Init(int numLeads, int x, int y, int id) {
    this.numLeads = numLeads;
    this.sym_id = id;
    allBlocks.add(this);

    parents = new ArrayList<Block>();
    children = new Block[numLeads];
    leads = new Lead[numLeads];

    for (int i = 0; i<numLeads; i++) {
      leads[i] = new Lead(this, rotation + i * 2*PI / numLeads, i);
    }
    type = idToType.get(sym_id);

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
    //Update leads and break connection if the child block is too far away
    for (int i = 0; i< numLeads; i++) {
      Lead l = leads[i];
      l.Update();
      if (l.occupant != null && l.occupantTooFar()) {
        breakConnection(i, true);
      }
    }

    //checks to see if this block has been missing for too long
    if (isMissing) {
      if (millis() - missingSince >= deathDelay) {
        if (isReadyToDie()) {
          missingBlocks.remove(this);
          killBlocks.add(this);
        }
      }
    }

    //fake blocks never use UpdatePosition(), which is where updateNeighbors is normally called
    if (isFake) {
      updateNeighbors();
      /*
      for(Lead l : leads){
       l.UpdateRotationFromParent(.01);
       }
       */
    }
  }


  /*
    Called when the TuioObject is reported removed. It won't actually be destroyed until it has been missing for deathDelay milliseconds
   */
  void OnRemove() {    
    missingBlocks.add(this);
    isMissing = true;
    missingSince = millis();
    if (!isFake)blockMap.remove(tuioObj.getSessionID());
  }

  /*
    Called when this block has been found while missing
   */
  void find(TuioObject newObj) {
    isMissing = false;
    missingBlocks.remove(this);
    if (!isFake)setTuioObject(newObj);
  }

  /*
    Destroys the block and all of its connections
   */
  void Die() {
    breakAllConnections();
    allBlocks.remove(this);
    missingBlocks.remove(this);
    if (!isFake)blockMap.remove(tuioObj.getSessionID());
  }

  //Some blocks may have certain conditions to meet before they're ready to die
  boolean isReadyToDie() {
    return true;
  }

  //previous is the block that has directed the PlayHead to this block
  public void Activate(PlayHead play, Block previous) {
    playHead = play;
  }
  /*
    Called when this block has finished being active
   This tells the playhead to move on to the next block in the chain
   */
  public void finish() {
    //println("finish " + this + " playHead " + (playHead == null ? "null" : playHead.toString()));
    PlayHead temp = playHead;
    if (playHead != null)
    {
      playHead = null;
      //temp.playColor = this.blocolor;
      temp.travel();
    }
  }



  /*
    Uses the TuioObject to update the blocks position and rotation
   Position and rotation are calculated using a moving average, which prevents them from jittering as much
   */
  public void UpdatePosition() {
    float new_x_pos = tuioObj.getScreenX(width);
    float new_y_pos = tuioObj.getScreenY(height);

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

      float rotDelta = (avg_rot - rotation); //this will cause unconnected leads to rotate with the block

      for (Lead l : leads) { 
        l.UpdateRotationFromParent(rotDelta);
      }
      rotation = avg_rot;
    }

    updateNeighbors();
  }

  /*
    Returns whether or not the child at index i will be an active successor to this block
   */
  public boolean childIsSuccessor(int i) {
    return (i < numLeads);
  }


  public void updateNeighbors() {

    if (this.canBeChained && !this.inChain) {
      findParents();
    }
    if (leadsActive) {
      findChildren();
    }
  }


  public void findChildren() {
    for (int i = 0; i<numLeads; i++) {
      if (leads[i].canRecieveChild()) {
        for (Block block : allBlocks) {
          if (!( block==this || block.parents.contains(this) || this.parents.contains(block) || block.inChain) && leads[i].isUnderBlock(block) && block.canBeChained) {
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
        if (block.leads[i].canRecieveChild()) {         
          if (!( block==this || block.parents.contains(this) || this.parents.contains(block)) && block.leadsActive && block.leads[i].isUnderBlock(this)) {
            block.makeConnection(this, i);
          }
        }
      }
    }
  }

  public void breakAllConnections() {
    breakParentConnections();
    breakChildConnections();
  }

  public void breakChildConnections() {
    println(this +" start breaking child connections");
    for (int i = 0; i< numLeads; i++) {
      breakConnection(i, false);
    }
        println(this +" finished breaking child connections");

  }

  public void breakParentConnections() {
    println(this + " start breaking parent connections");
    Block[] parentsArray = new Block[parents.size()];
    parents.toArray(parentsArray);
    for (Block p : parentsArray) {
      println("Parent " + p + " break connection with " + this);
      p.breakConnection(this, true);
    }
    println(this + " finished breaking barent connections");
  }

  void makeConnection(Block b, int i) {
    leads[i].connect(b);
  }
  
  void SetChild(Block b, int i){
    println(this + " Set Child " + b);
    if (children[i] != null) 
      RemoveChild(i);
    children[i] = b;
    b.parents.add(this);
  }
  
  void RemoveChild(int i){
    println(this + " Remove Child");
    if (children[i] != null) {
      children[i].parents.remove(this);
      children[i] = null;
    }
  }

  /*
  Breaks connection with a child at index i
   */
  void breakConnection(int i, boolean connectAround) {
    println(this + " breakConnection("+i+"," +connectAround+")");
    leads[i].disconnect(connectAround);
  }

  /*
  Breaks connection with child block b
   */
  void breakConnection(Block b, boolean connectAround) {
    
    for (int i = 0; i<numLeads; i++) {
      if (children[i] == b) {
        leads[i].disconnect(connectAround);
      }
    }
  }

  public void arrangeLeads(float parentLeadRot) {

    if (parents.size() > 1) return;
    if(leads.length == 0) return;
    float leadSeparation = 2*PI / leads.length;
    float startAngle = PI + parentLeadRot + leadSeparation / 2;

    for (int i = 0; i < leads.length; i++) {
      float leadAngle = (startAngle + leadSeparation * i)%(2*PI);
      leads[i].SetRotation(leadAngle);
    }
  }

  public void cleanLeads() {
    for (int i = 0; i< leads.length; i++) {
      for (int j = 0; j < leads[i].lines.length; j++) {
        leads[i].lines[j].visible = false;
      }
    }
  }


  public void draw() {
    drawShadow();
  }

  /*
    Default shadow shape is a circle. We use shapes instead of ellipse() to improve performance
   */
  void drawShadow() {
    noStroke();
    shapeMode(CENTER);
    fill(blockColor);
    pushMatrix();
    translate(x_pos, y_pos);
    shape(circleShadow);
    popMatrix();
  }

  /*
  Updates the look of this block's lead depending on whether or not it's in an active path from a Start block
   */
  void updateLeads(float offset, color col, boolean isActive, boolean setBlockColor, ArrayList<Block> activeVisited, ArrayList<Block> inactiveVisited) {
    Block origin = activeVisited.get(0);
    int originId = origin.sym_id;
    this.inChain = true;
    colorMode(HSB);

    color dulledColor = color(hue(col), saturation(col)/3, 150);
    if(setBlockColor) blockColor = (isActive? col : dulledColor);

    for (int i = 0; i< numLeads; i++) {     
      if (isActive && childIsSuccessor(i)) {
        leads[i].lines[originId].dashed = true;
        leads[i].lines[originId].dash_offset = offset;
        leads[i].lines[originId].col = col;
        leads[i].lines[originId].visible = true;


        if (children[i] != null && !activeVisited.contains(children[i])) {
          activeVisited.add(children[i]);
          children[i].updateLeads(offset, col, true, setBlockColor, activeVisited, inactiveVisited);
        }
      } else {
        leads[i].lines[originId].dashed = false;
        leads[i].lines[originId].col = dulledColor;
        leads[i].lines[originId].visible = true;


        if (children[i] != null && !activeVisited.contains(children[i]) && !inactiveVisited.contains(children[i])) {
          inactiveVisited.add(children[i]);
          children[i].updateLeads(offset, col, false, setBlockColor, activeVisited, inactiveVisited);
        }
      }
    }
  }

  /*
  Draws an arc around the block's center with specified radius, starting rotation and completion percentage of the arc. 
   */
  void drawArc(int radius, float percent, float startRotation) {
    pushMatrix();
    noStroke();

    if (playHead != null)
      fill(playHead.playColor);
    else
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

  /*
  Draws a circle under the block with the max specified radius at the start of each beat. The circle shrinks over time until the start of the next beat
   */
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
    return (dist(hit_x, hit_y, x_pos, y_pos) < block_diameter/2);
  }

  public String toString() {
    return ("id: " + sym_id + "  x: " + x_pos + "  y: " + y_pos);
  }
}

