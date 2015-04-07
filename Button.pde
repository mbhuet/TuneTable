abstract class Button{
  int x,y;
  float size;
  
  void InitButton(int x_pos, int y_pos, float rad){
    x = x_pos;
    y = y_pos;
    size = rad;
    allButtons.add(this);

  }
  
  public void Destroy(){
    allButtons.remove(this);
  }
  
  public boolean IsUnder(int hit_x, int hit_y){
    return (dist(hit_x, x, hit_y, y) < size);
  }
  
  abstract void Trigger();
  abstract void drawButton();
}



class PlayButton extends Button{
  
  
  PlayButton(int x_pos, int y_pos, float rad){
    InitButton(x_pos,y_pos,rad);
  }
  
  public void Trigger(){
    Play();
  }
  
  public void drawButton(){
           // println("drawbutton");

    fill(color(0,0,0));
    ellipse(x,y,100,100);
    
    pushMatrix();
    translate(x,y);
    scale(.5);

   translate(size/6, 0);
    fill(color(255,0,0));
    triangle(-size/2,-size/2,
             -size/2, size/2,
             size/2, 0);
    popMatrix();
            
  }
  
}
