class Lead{
  Block owner;
  float rot;
  
  float distance = block_diameter * 1.5;
  boolean occupied;
  
  Lead(Block owner, float rot){
    this.owner = owner;
    this.rot = rot;
    
  }
  
  public void draw(){
    stroke(0);
    strokeWeight(3);
    pushMatrix();
    
    translate(owner.x_pos, owner.y_pos);
    rotate(rot);
    line(0, 0, distance, 0);
    
    translate(distance,0);
    stroke(0);
    strokeWeight(3);
    dashedCircle(0, 0, block_diameter, 10);
  }

}
