class Lead{
  Block owner;
  Block occupant;
  float rotation;
  
  float distance = block_diameter * 1.5;
  float break_distance = block_diameter * 2; //at what distance will a connection break;
  float connect_snap_dist = block_diameter / 2; //how close does a block need to be to connect to this lead?
  boolean occupied;
  
  Lead(Block owner, float rot){
    this.owner = owner;
    this.rotation = rot;
    occupied = false;
  }
  
  public void Update(){
    if (occupied){
      trackBlock(occupant);
      if (distance > break_distance){
        disconnect();
      }
    }
  }
  
  public void draw(){
    stroke(0);
    strokeWeight(3);
    pushMatrix();
    
    translate(owner.x_pos, owner.y_pos);
    rotate(rotation);

    line(0, 0, distance, 0);
    
    translate(distance,0);
    stroke(0);
    strokeWeight(3);
    dashedCircle(0, 0, block_diameter, 10);
  }
  
  public boolean isUnderBlock(Block b){
    float look_x = owner.x_pos + cos(rotation) * distance;
    float look_y = owner.y_pos + sin(rotation) * distance;
    
    return (dist(look_x, look_y, b.x_pos, b.y_pos) <= connect_snap_dist);
  }
  
  public void connect(Block block){
    occupant = block;
    occupied = true;
    trackBlock(block);
  }
  
  public void disconnect(){
    occupant = null;
    occupied = false;
  }
  
  void trackBlock(Block block){                       
    rotation = atan(block.y_pos - owner.y_pos /
                    block.x_pos - owner.x_pos);
    distance = dist(block.x_pos, block.y_pos, owner.x_pos, owner.y_pos);
  }

}
