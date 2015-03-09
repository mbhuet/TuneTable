class Block{

  TuioObject tuioObj;
  int sym_id;
  float x_pos;
  float y_pos;
  float rotation;
  BlockType type;
  int block_length = 1;
  int clip_length;
  int parameter;
  
  Block left_neighbor;
  Block right_neighbor;
  
  AudioPlayer clip;
  //float hold_time; //to prevent flickering
  
  Block(TuioObject tobj){
    Update(tobj);
    type = idToType.get(sym_id);
    parameter = -1;
    
        Setup();

  }
  
  Block(TuioObject tobj, TuioObject arg){
    Update(tobj);
    type = idToType.get(sym_id);
    SetArgument(arg);
    
    Setup();
    
  }
  
  
  //good for faking blocks for debuggin
  Block (int id, int arg){
    sym_id = id;
    x_pos = width/2;
    y_pos = height/2;
    rotation = 0;
    block_length = 1;
    type = idToType.get(sym_id);
    parameter = arg;
    
    Setup();

  }
  
  Block (int id){
    sym_id = id;
    x_pos = width/2;
    y_pos = height/2;
    rotation = 0;
    block_length = 1;
    type = idToType.get(id);
    parameter = 0;
    
    Setup();
        
  }
  
  void Setup(){
  if (type == BlockType.PLAY){
    allChains.add(new Chain(this));
  }
  if (type == BlockType.CLIP) LoadClip();
  }
  
  public void OnRemove(){
    
    //if this is a play block, the chain it represents should be destroyed as well
    if (type == BlockType.PLAY){
      for(int i = 0; i<allChains.size(); i++){
        if (allChains.get(i).head == this){
          allChains.remove(i);
        }
      }
    }
        
  BreakNeighbors();
  }
  
  
  
  public void Update(TuioObject tobj){
    BreakNeighbors();
    tuioObj = tobj;
    sym_id = tobj.getSymbolID();
    x_pos = tobj.getScreenX(width);
    y_pos = tobj.getScreenY(height);
    rotation = tobj.getAngle();
    FindNeighbors();
    
    //if this block is part of any chains, that chain should rebuild itself based on the new state
    for(Chain c : allChains){
      if (c.containsBlock(this)){
        c.Remove(this);
      }
    }
  }
  
  void BreakNeighbors(){
    
    if(right_neighbor != null){  right_neighbor.left_neighbor = null;}
    if(left_neighbor != null){   left_neighbor.right_neighbor = null;}
        
    left_neighbor = null;
    right_neighbor = null;
  }
  
  public void FindNeighbors(){
    //TODO should check all blocks, if a block has not right neighbor, check with this one, same with left
    
    for(Entry<Long, Block> entry: blockMap.entrySet()) {      
      Block cur = entry.getValue();
      //println(cur);
      if (cur.right_neighbor ==  null){
        if(BlockNeighbors(cur, this)){
          cur.right_neighbor = this;
          this.left_neighbor = cur;
          //println("left");
        }
      }
      if (cur.left_neighbor == null){
        if (BlockNeighbors(this, cur)){
          cur.left_neighbor = this;
          this.right_neighbor = cur;
                    //println("right");

        }
      }
      
      //break out of the loop if neighbors have been found on both sides
      if (right_neighbor != null && left_neighbor != null){
        break;
      }
    }
  }
  
  boolean SetArgument(TuioObject arg){
    if (arg == null){
     //println("null argument");
      parameter = 0; 
      return false;
    }
    else if (idToArg.containsKey(arg.getSymbolID())){
      parameter = idToArg.get(arg.getSymbolID());
      return true;
    }
    else{
      parameter = -1;
      return false;
    }
  }
  
  
  public void Highlight(int numBars, boolean active){
    strokeWeight(0);
    
    if (active){
    fill(color(255,0,0));
    }
    else fill(150);
    
    float spacer = block_width*.2;
    
    for(int i = 0; i< numBars; i++){
      
      
      pushMatrix();

    
    
    translate(this.x_pos, this.y_pos);
    rotate(this.rotation);
    //translate(-obj_size/2, -obj_size/2);
    rect(- block_width/2.0 + spacer + block_width/4 * i, 
         - block_height/2.0,
            block_width/4 - 2*spacer, 
            block_height * 1.2);
    
    popMatrix();
      
      
      
    }
    
    //rect(x_pos - object_size, y_pos-object_size, object_size *2, object_size * 2);
    
  }
  
  
  
  public boolean requiresArgument(){
    return (this.type == BlockType.PLAY ||
            this.type == BlockType.START_LOOP ||
            this.type == BlockType.EFFECT ||
            this.type == BlockType.SILENCE);
  }
  
  void LoadClip(){
    if (clipDict.containsKey(sym_id)){
      ClipInfo info =  clipDict.get(sym_id);
      String clip_name = info.name;
      clip = minim.loadFile("clips/"+clip_name+".wav");
      clip_length = info.length;
    }
    else{
     // println("No clip found for " + id + ": Possible typo");
    }
  }
  
  public String toString(){
    return ("\nid: " + sym_id + " arg: " + parameter + "  x: " + x_pos + "  y: " + y_pos);
  }
  
  
}
