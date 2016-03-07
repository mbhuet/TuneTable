class CountdownBlock extends Block {

  int count;
  int max_count = 9;

  float button_offset_y = block_diameter * 1; //TUNING
  float window_offset_x = block_diameter * .88; //TUNING
  float window_radius = block_diameter/2;//TUNING

  CountdownBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  void Setup() {
   
  }

  void Update() {
    super.Update();
  }
  void OnRemove() {
        super.OnRemove();

  }

    public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    count--;
    finish();
  }
  
  public int[] getSuccessors(){
    if (count > 0) return new int[]{0};
    else return new int[]{1};
  }


  public void IncrementArgument() {

    count++;
    if (count > max_count)
      count = 0;
  }

  public void DecrementArgument() {
    count--;
    if (count < 0)
      count = max_count;
  }

  public void drawCount() {
    pushMatrix();
    rectMode(CENTER);
    translate(x_pos, y_pos);
    rotate(rotation);

    translate(window_offset_x, 0);

    //White circle
    fill(255);
    ellipse(0, 0, window_radius, window_radius);
    fill(0);

    //Argument number
    textAlign(CENTER, CENTER);
    textSize(32);
    translate(0, -textAscent() * .1);
    String arg_string = ""+count;

    if (count < 0) { 
      arg_string = "?";
      //textSize(7);
    }


    text(arg_string, 0, 0); 

    popMatrix();
  }

  
}

