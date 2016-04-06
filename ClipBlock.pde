class ClipBlock extends SoundBlock {
  int buttonSize = block_diameter/4;
  int buttonDist;
  ClipButton[] buttons;
  
  ClipBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  ClipBlock(int x, int y, int id) {
    Init(1, x, y, id);
  }

  void Setup() {
    LoadClips();
    buttonDist = block_diameter/2;
    buttons = new ClipButton[clips.length];
    for(int i = 0; i< buttons.length; i++){
      buttons[i] = new ClipButton(this, i, 0, 0, 0, buttonSize);
    }
    arrangeButtons(rotation);
  }
  void Update() {
    //println("begin clip update " + this + " playHead " + (playHead == null ? "null" : playHead.toString()));
    super.Update();
    leadsActive = inChain;

    if (isPlaying) {

      if (pie) {
        float arcRot = 0;
        if (previous != null) {
          arcRot = atan2((previous.y_pos - this.y_pos), 
          (previous.x_pos - this.x_pos));
        }
        drawArc((int)(block_diameter * .4), (float)clips[activeClip].position()/(float)clips[activeClip].length(), arcRot);
      } else { 
        float beatRadius = block_diameter * 1.25f * (1.0- .5f *(float)(clips[activeClip].position()%255) / (float)255);

        drawBeat((int)(beatRadius));
      }
      playTimer += millis() - startTime;
      if (clips[activeClip].position() >= clips[activeClip].length()) {
        Stop();
        finish();
      }
    }
    arrangeButtons(rotation);
    //println("end clip update " + this + " playHead " + (playHead == null ? "null" : playHead.toString()));
    
  }


  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);

    //println("clip activate playHead = " + ((playHead == null)? "null" : playHead.toString()) );
  }

  public int[] getSuccessors() {
    return new int[] {
      0
    };
  }

  void OnRemove() {
    super.OnRemove();
  }
  
  void arrangeButtons(float startAngle) {
    for (int i = 0; i<buttons.length; i++) {
      buttons[i].Update((int)(x_pos + cos(startAngle + i * 2*PI/clips.length) * buttonDist), (int)(y_pos + sin(startAngle + i * 2*PI/clips.length) * buttonDist), i*2*PI/clips.length);
    }
  }
  
  void SetButtonsShowing(boolean isShowing){
    for(ClipButton butt : buttons){
      butt.SetShowing(isShowing);
    }
  }
  
    void drawButtons(){
    for(ClipButton butt : buttons){
      if(butt.isShowing)
      butt.drawButton();
    }
  }
  
  void draw(){
        drawButtons();
    drawShadow();
  }

  void Die() {
    super.Die();
    for (int i = 0; i<buttons.length; i++) {
      buttons[i].Destroy();
      buttons[i] = null;
    }
    if (playHead != null) {  
      //println("block " + this + " has been removed, killing its playhead " + playHead);
      playHead.dead = true;
    }
  }
}

class ClipButton extends Button {
  ClipBlock block;
  int index;

  ClipButton(ClipBlock b, int i, int x_pos, int y_pos, float rot, float rad) {
    InitButton(x_pos, y_pos, rot, rad);
    index = i;
    block = b;
  }
  public void Trigger(Cursor cursor) {
    block.SwitchClip(index);
  }
  
  public void Trigger(){
    block.SwitchClip(index);
  }
  
  public void drawButton() {
    strokeWeight(3);
    strokeCap(SQUARE);
    color strokeCol = (color(invertColor ? 255 : 0));
    color fillCol = (color(invertColor ? 0 : 255));

    if (block.activeClip == index) {
      fillCol = (color(invertColor ? 255 : 0));
      strokeCol = (color(invertColor ? 0 : 255));
    }
    
    fill(fillCol);
    stroke(strokeCol);
    
    pushMatrix();
    //translate(block.x_pos, block.y_pos);
    translate(x,y);
    rotate(rotation);
    rotate(HALF_PI);
    //arc(0,0,block_diameter, block_diameter, -QUARTER_PI,QUARTER_PI);
    ellipse(0, 0, size*2, size*2);
    
    textAlign(CENTER, CENTER);
      textSize(text_size);
    fill(strokeCol);
    text(index, 0,0);
    popMatrix();
    //block.drawShadow();
  }
}

