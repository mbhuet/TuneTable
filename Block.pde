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
    tuioObj = tobj;

    Update();//tobj);
    type = idToType.get(sym_id);
    parameter = -1;
    Setup();
    println(tuioObj.getSessionID());

  }
  
  Block(TuioObject tobj, TuioObject arg){
        tuioObj = tobj;

    Update();//tobj);
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
        
        //println("remove "  + this);
  BreakNeighbors();
  for(Chain c : allChains){
      if (c.containsBlock(this)){
        c.Remove(this);
      }
    }
  }
  
  
  
  public void Update(){//TuioObject tobj){
    sym_id = tuioObj.getSymbolID();
    x_pos = tuioObj.getScreenX(width);
    y_pos = tuioObj.getScreenY(height);
    rotation = tuioObj.getAngle();
    FindNeighbors();
    
    //if this block is part of any chains, that chain should rebuild itself based on the new state
    for(Chain c : allChains){
      if (c.containsBlock(this) ||
         (right_neighbor != null && c.containsBlock(right_neighbor)) ||
         (left_neighbor != null && c.containsBlock(left_neighbor)))
         {
            c.BuildChain();
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
    
    //check to see if current neighbors are still neighbors before anything else
    if(left_neighbor != null && !BlockNeighbors(left_neighbor, this)){
          left_neighbor = null;
    }
    if(right_neighbor != null && !BlockNeighbors(this, right_neighbor)){
          right_neighbor = null;
    }
    
    
    //TODO should check all blocks, if a block has no right neighbor, check with this one, same with left 
    for(Entry<Long, Block> entry: blockMap.entrySet()) {
      
      
      Block cur = entry.getValue();
      //println(cur);
      if (cur.right_neighbor ==  null){
        if(BlockNeighbors(cur, this)){
          cur.right_neighbor = this;
          this.left_neighbor = cur;
        }
      }
      if (cur.left_neighbor == null){
        if (BlockNeighbors(this, cur)){
          cur.left_neighbor = this;
          this.right_neighbor = cur;
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
