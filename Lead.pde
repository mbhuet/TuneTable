class Lead{
  Block owner;
  Block occupant;
  float rotation;
  
  float distance;
  float reg_distance = block_diameter * 1.5;
  float break_distance = block_diameter * 2; //at what distance will a connection break;
  float connect_snap_dist = block_diameter / 2; //how close does a block need to be to connect to this lead?
  boolean occupied;
  
  Lead(Block owner, float rot){
    this.owner = owner;
    this.rotation = rot;
    occupied = false;
    distance = reg_distance;
  }
  
  public void Update(){
    if (occupied){
      trackBlock(occupant);
    }
  }
  
  public void draw(){
    stroke(0);
    strokeWeight(3);
    pushMatrix();
    
    translate(owner.x_pos, owner.y_pos);
    rotate(rotation);

    line(0, 0, distance - block_diameter/2, 0);
    
    translate(distance,0);
    stroke(0);
    strokeWeight(3);
    dashedCircle(0, 0, block_diameter, 10);
    popMatrix();
  }
  
  public void highlightTravelled(float percent, color col){
    percent = min(1,percent);
    percent = max(0,percent);
    stroke(col);
    strokeWeight(block_diameter/4);
    strokeCap(SQUARE);

    pushMatrix();
    
    translate(owner.x_pos, owner.y_pos);
    rotate(rotation);
    translate(block_diameter/2,0);

    line( (distance - block_diameter) * (1.0-percent), 0, distance - block_diameter, 0);
    
    popMatrix();
    
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
    distance = reg_distance;
  }
  
  void trackBlock(Block block){                       
    rotation = atan2((block.y_pos - owner.y_pos) ,
                    (block.x_pos - owner.x_pos));
    distance = dist(block.x_pos, block.y_pos, owner.x_pos, owner.y_pos);
  }

}
