abstract class Button{
  int x,y;
  float rotation;
  float size;
  
  void InitButton(int x_pos, int y_pos, float rot, float rad){
    x = x_pos;
    y = y_pos;
    rotation = rot;
    size = rad;
    allButtons.add(this);
  }
  
  public void Update(int x_pos, int y_pos, float rot){
    x = x_pos;
    y = y_pos;
    rotation = rot;
  }
  
  public void Destroy(){
    allButtons.remove(this);
  }
  
  public boolean IsUnder(int hit_x, int hit_y){
    //println(hit_x + ", " + x + ", " + hit_y + ", " + y);
    
    return (dist(hit_x, hit_y, x, y) < size);
  }
  
  abstract void Trigger();
  abstract void drawButton();
}



class PlayButton extends Button{

  PlayButton(int x_pos, int y_pos, float rot, float rad){
    InitButton(x_pos,y_pos,rot,rad);
  }
  public void Trigger(){
    //println("play button hit");
    Play();
  }
  public void drawButton(){
    fill(color(0,0,0));
    ellipse(x,y,size*2,size*2);
    pushMatrix();
    translate(x,y);
    scale(.8);
    translate(size/6, 0);
    fill(color(255,255,255));
    triangle(-size/2,-size/2,
             -size/2, size/2,
             size/2, 0);
    popMatrix();
  }
}

class UpButton extends Button{
  Block block;
  
  UpButton(int x_pos, int y_pos, float rot, float rad, Block b){
    InitButton(x_pos,y_pos,rot, rad);
    block = b;
  }
  public void Trigger(){
        //println("up");

    block.IncrementArgument();
  }
  public void drawButton(){
    
    pushMatrix();
    translate(x,y);
    //translate(size/6, 0);
    rotate(rotation);
    
    fill(color(0,0,0));
      stroke(0);
    rectMode(CENTER);
    rect(0,size, size*2,size*2);
    
    ellipse(0,0,size*2,size*2);
    
    //translate(block_width,0);
        scale(1);

    fill(color(255,255,255));
    triangle(0,-size/2,
             -size/2,size/2,
             size/2, size/2);
    popMatrix();
  }
}

class DownButton extends Button{
  Block block;
  
  DownButton(int x_pos, int y_pos, float rot, float rad, Block b){
    InitButton(x_pos,y_pos,rot, rad);
    block = b;
  }
  public void Trigger(){
    //println("down");
    block.DecrementArgument();
  }
  public void drawButton(){
    
    pushMatrix();
    translate(x,y);
    //translate(size/6, 0);
    rotate(rotation);
          stroke(0);

    fill(color(0,0,0));
    
    rectMode(CENTER);
    rect(0,-size, size*2,size*2);
    
    
    ellipse(0,0,size*2,size*2);
    
    //translate(block_width,0);
        scale(1);

    fill(color(255,255,255));
    triangle(0,size/2,
             -size/2,-size/2,
             size/2, -size/2);
    popMatrix();
    
  }
}
