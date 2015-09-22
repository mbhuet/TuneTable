class CountdownBlock extends Block {

  UpButton up;
  DownButton down;
  int count;
  int max_count = 9;

  float button_offset_y = block_diameter * 1; //TUNING
  float window_offset_x = block_diameter * .88; //TUNING
  float window_radius = block_diameter/2;//TUNING

  CountdownBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  void Setup() {
    up = new UpButton(0, 0, 0, block_diameter/4, this);
    down = new DownButton(0, 0, 0, block_diameter/4, this);
  }

  void Update() {
    super.Update();
  }
  void OnRemove() {
        super.OnRemove();

  }

  void Activate() {
    if (count > 0 && children[0] != null) children[0].Activate();
    else if (count ==0 && children[1] != null) children[1].Activate();
    count--;
  }


  public void IncrementArgument() {
    //println("arg inc");

    count++;
    if (count > max_count)
      count = 0;
  }

  public void DecrementArgument() {
    //println("arg dec");
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

  void PlaceButtons() {
    PVector holeCenter = new PVector(x_pos + cos(rotation) * window_offset_x, 
    y_pos + sin(rotation) * window_offset_x);

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
}

