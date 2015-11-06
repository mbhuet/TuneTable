abstract class Button{
  int x,y;
  float rotation;
  float size;
  public boolean isShowing;
  
  void InitButton(int x_pos, int y_pos, float rot, float rad){
    isShowing = true;
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
    
    return (dist(hit_x, hit_y, x, y) < size);
  }
  
  public void FlipShowing(){
    isShowing = !isShowing;
  }
  
  public void SetShowing(boolean b){
    isShowing = b;
  }
  
  abstract void Trigger(Cursor cursor);
  abstract void drawButton();
}



class PlayAllButton extends Button{

  PlayAllButton(int x_pos, int y_pos, float rot, float rad){
    InitButton(x_pos,y_pos,rot,rad);
  }
  public void Trigger(Cursor cursor){
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
  CountdownBlock block;
  
  UpButton(int x_pos, int y_pos, float rot, float rad, CountdownBlock b){
    InitButton(x_pos,y_pos,rot, rad);
    block = b;
  }
  public void Trigger(Cursor cursor){

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
  CountdownBlock block;
  
  DownButton(int x_pos, int y_pos, float rot, float rad, CountdownBlock b){
    InitButton(x_pos,y_pos,rot, rad);
    block = b;
  }
  public void Trigger(Cursor cursor){
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




