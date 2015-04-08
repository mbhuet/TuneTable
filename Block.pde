class Block {

  TuioObject tuioObj;
  int sym_id;
  float x_pos;
  float y_pos;
  float rotation;
  BlockType type;
  int block_length = 1;
  int clip_length;
  int parameter = 0;
  int max_arg = 9;
  
  float block_width;

  UpButton up;
  DownButton down;
  float button_offset_y = block_height * 1.5;
  float button_offset_x = block_height * 1; //TUNING
  float window_radius = block_height/2;//TUNING

  Block left_neighbor;
  Block right_neighbor;

  AudioPlayer clip;
  //float hold_time; //to prevent flickering

  Block(TuioObject tobj) {
    tuioObj = tobj;
    Update();
    type = idToType.get(sym_id);
    parameter = 0;
    Setup();
    println(tuioObj.getSessionID());
  }

  Block (int id, int arg) {
    sym_id = id;
    x_pos = width/2;
    y_pos = height/2;
    rotation = 0;
    block_length = 1;
    type = idToType.get(sym_id);
    parameter = arg;

    Setup();
  }

  Block (int id) {
    sym_id = id;
    x_pos = width/2;
    y_pos = height/2;
    rotation = PI/4;
    block_length = 1;
    type = idToType.get(id);
    parameter = 0;
    Setup();
  }

  void Setup() {
    allBlocks.add(this);
    if (type == BlockType.PLAY) {
      allChains.add(new Chain(this));
    }
    if (type == BlockType.CLIP) LoadClip();

    if (requiresArgument()) {
      block_width = block_height * 2;
      up = new UpButton(0, 0, 0, 10, this);
      down = new DownButton(0, 0, 0, 10, this);
      PlaceButtons();
    }
    else{
      block_width = block_height;
    }
    
  }

  public void OnRemove() {

    //if this is a play block, the chain it represents should be destroyed as well
    if (type == BlockType.PLAY) {
      for (int i = 0; i<allChains.size (); i++) {
        if (allChains.get(i).head == this) {
          allChains.remove(i);
        }
      }
    }

    //println("remove "  + this);
    BreakNeighbors();
    for (Chain c : allChains) {
      if (c.containsBlock(this)) {
        c.Remove(this);
      }
    }
    
    allBlocks.remove(this);
  }



  public void Update() {//TuioObject tobj){
    sym_id = tuioObj.getSymbolID();
    x_pos = tuioObj.getScreenX(width);
    y_pos = tuioObj.getScreenY(height);
    rotation = tuioObj.getAngle();
    FindNeighbors();

    //if this block is part of any chains, that chain should rebuild itself based on the new state
    for (Chain c : allChains) {
      if (c.containsBlock(this) ||
        (right_neighbor != null && c.containsBlock(right_neighbor)) ||
        (left_neighbor != null && c.containsBlock(left_neighbor)))
      {
        c.BuildChain();
      }
    }

    if (requiresArgument()) {
      PlaceButtons();
    }
  }

  void PlaceButtons() {
    PVector holeCenter = new PVector(x_pos + cos(rotation) * button_offset_x,
                                     y_pos + sin(rotation) * button_offset_x);
    
    PVector upPos = new PVector(holeCenter.x + cos(rotation-PI/2) * button_offset_y,
                                holeCenter.y + sin(rotation-PI/2) * button_offset_y);
    PVector downPos = new PVector(holeCenter.x + cos(rotation+PI/2) * button_offset_y,
                                  holeCenter.y + sin(rotation+PI/2) * button_offset_y);
                                     
    up.Update((int)(upPos.x), 
    (int)(upPos.y), 
    rotation);
    down.Update((int)(downPos.x), 
    (int)(downPos.y), 
    rotation);
  }

  void BreakNeighbors() {

    if (right_neighbor != null) {  
      right_neighbor.left_neighbor = null;
    }
    if (left_neighbor != null) {   
      left_neighbor.right_neighbor = null;
    }

    left_neighbor = null;
    right_neighbor = null;
  }
  
  public void drawBlock(){
    pushMatrix();
    rectMode(CENTER);

    translate(x_pos, y_pos);
    rotate(rotation);
    
      pushMatrix();
      translate((block_width - block_height)/ 2, 0);
      fill(0);
      rect(0,0,block_width, block_height);
      popMatrix();
        
    if (requiresArgument()){
      pushMatrix();
      translate(button_offset_x,0);
      fill(255);
      ellipse(0,0,window_radius, window_radius);
      fill(0);
      textAlign(CENTER,CENTER);
      float a = textAscent();
      
      textSize(32);
      translate(0, -textAscent() * .1);
      String arg_string = ""+parameter;
      if (parameter < 0){ arg_string = "Random";
      textSize(7);  
    }
      text(arg_string, 0, 0); 
      popMatrix();
    }
    
    popMatrix();
        
        fill(150);
        ellipse(x_pos, y_pos, 10,10);

  }

  public void FindNeighbors() {

    //check to see if current neighbors are still neighbors before anything else
    if (left_neighbor != null && !BlockNeighbors(left_neighbor, this)) {
      left_neighbor = null;
    }
    if (right_neighbor != null && !BlockNeighbors(this, right_neighbor)) {
      right_neighbor = null;
    }


    //TODO should check all blocks, if a block has no right neighbor, check with this one, same with left 
    for (Entry<Long, Block> entry : blockMap.entrySet ()) {


      Block cur = entry.getValue();
      //println(cur);
      if (cur.right_neighbor ==  null) {
        if (BlockNeighbors(cur, this)) {
          cur.right_neighbor = this;
          this.left_neighbor = cur;
        }
      }
      if (cur.left_neighbor == null) {
        if (BlockNeighbors(this, cur)) {
          cur.left_neighbor = this;
          this.right_neighbor = cur;
        }
      }

      //break out of the loop if neighbors have been found on both sides
      if (right_neighbor != null && left_neighbor != null) {
        break;
      }
    }
  }

  boolean SetArgument(TuioObject arg) {
    if (arg == null) {
      //println("null argument");
      parameter = 0; 
      return false;
    } else if (idToArg.containsKey(arg.getSymbolID())) {
      parameter = idToArg.get(arg.getSymbolID());
      return true;
    } else {
      parameter = -1;
      return false;
    }
  }

  public void IncrementArgument() {
    println("arg inc");

    parameter++;
    if (parameter > max_arg)
      parameter = -1;
  }
  public void DecrementArgument() {
    println("arg dec");
    parameter--;
    if (parameter < -1)
      parameter = max_arg;
  }


  public void Highlight(int numBars, boolean active) {
    strokeWeight(0);

    if (active) {
      fill(color(255, 0, 0));
    } else fill(150);

    float spacer = block_width*.2;

    for (int i = 0; i< numBars; i++) {
      pushMatrix();
      translate(this.x_pos, this.y_pos);
      rotate(this.rotation);
      rect(- block_width/2.0 + spacer + block_width/4 * i, 
      - block_height/2.0, 
      block_width/4 - 2*spacer, 
      block_height * 1.2);
      popMatrix();
    }
  }



  public boolean requiresArgument() {
    return (this.type == BlockType.PLAY ||
      this.type == BlockType.START_LOOP ||
      this.type == BlockType.EFFECT ||
      this.type == BlockType.SILENCE);
  }

  void LoadClip() {
    if (clipDict.containsKey(sym_id)) {
      ClipInfo info =  clipDict.get(sym_id);
      String clip_name = info.name;
      clip = minim.loadFile("clips/"+clip_name+".wav");
      clip_length = info.length;
    } else {
      // println("No clip found for " + id + ": Possible typo");
    }
  }

  public String toString() {
    return ("\nid: " + sym_id + " arg: " + parameter + "  x: " + x_pos + "  y: " + y_pos);
  }
}

