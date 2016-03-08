class ConditionalBlock extends Block {
  boolean isTrue = false;
  int boolId;
  color myColor;

  BooleanBlock boolBlock;
  //Lead boolLead;
  
  BooleanButton leftButton;
  BooleanButton rightButton;

  ConditionalBlock(TuioObject tObj) {
    Init(tObj, 2);
  }
  
  ConditionalBlock(int x, int y) {
    Init(2,x,y, 110);
  }

  void Setup() {
    
    /*
    boolId = sym_id - 10; //booleans are 100-109, corresponding conditionals are 110-119
    

    boolLead = new Lead(this, 0);
    boolLead.break_distance = 9999;
    boolLead.visible = false;
    boolLead.lines[0].visible = false;
    boolLead.lines[0].col = myColor;
    boolLead.lines[0].dashed = false;
    boolLead.lines[0].weight = 5;
    
    //leads[0].options.image = unlock;
    leads[0].image = (isTrue ? unlock : lock);

    checkBooleanBlock();
    */
    leftButton = new BooleanButton(0,0,0, block_diameter/5, this);
    rightButton = new BooleanButton(0,0,0, block_diameter/5, this);
    
    leftButton.Flip();
    
    arrangeButtons();
    
  }

  void Update() {
    super.Update();
    leadsActive = inChain;
    arrangeButtons();

    //checkBooleanBlock();
    //boolLead.Update();
    //boolLead.draw();
  }
  
  void arrangeButtons(){
    float leftLeadRot = leads[0].rotation;
    float rightLeadRot = leads[1].rotation;
    
    float leftButtonDist = leads[0].distance/2; // how far along the lead
    float rightButtonDist = leads[1].distance/2;
    
    PVector leftPos = new PVector(x_pos + cos(leftLeadRot) * leftButtonDist, 
                                  y_pos + sin(leftLeadRot) * leftButtonDist);
                                       
     PVector rightPos = new PVector(x_pos + cos(rightLeadRot) * rightButtonDist, 
                                    y_pos + sin(rightLeadRot) * rightButtonDist);
                                       
    leftButton.Update((int)(leftPos.x), 
                      (int)(leftPos.y), 
                      leftLeadRot + PI/2);
    
    rightButton.Update((int)(rightPos.x), 
                       (int)(rightPos.y), 
                       rightLeadRot + PI/2);
  }

/*
  void checkBooleanBlock() {
    boolean inMap = boolMap.containsKey(boolId);
    if (inMap && !isTrue) {//the booleanBlock has just been added to the dictionary
      isTrue = true;
      boolBlock = boolMap.get(boolId);
      boolLead.connect(boolBlock);
      boolLead.lines[0].visible = true;
      boolLead.lines[0].col = (invertColor? 255:0);
      //leads[0].options.image = lock;

    } else if (!inMap && isTrue) { //the booleanBlock has just been removed from the dictionary
      isTrue = false;
      boolBlock = null;
      boolLead.disconnect();
      boolLead.lines[0].visible = false;
      boolLead.lines[0].col = (invertColor? 0:255);
      //leads[0].options.image = unlock;
    }
    
    leads[0].image = (isTrue? unlock : lock);
  }
  */
  
  void Flip(){
    isTrue = !isTrue;
    leftButton.Flip();
    rightButton.Flip();
  
  }


  void OnRemove() {
    super.OnRemove();
  }
  
  void Die() {
    leftButton.Destroy();
    leftButton = null;
    rightButton.Destroy();
    rightButton = null;
    
    super.Die();
  }
  
  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    finish();
  }

  public boolean childIsSuccessor(int i) {
    if (i == 0) return isTrue;
    else return !isTrue;
  }

  public int[] getSuccessors() {
    if (isTrue) return new int[] {
      0
    };
    else return new int[] {
      1
    };
  }
}

class BooleanButton extends Button{
  ConditionalBlock block;
  boolean isOn;
  
  BooleanButton(int x_pos, int y_pos, float rot, float rad, ConditionalBlock b){
    InitButton(x_pos,y_pos,rot, rad);
    block = b;
  }
  public void Trigger(Cursor cursor){
    block.Flip();
  }
  
  void Flip(){
    isOn = !isOn;
  }
  
  public void drawButton(){
    
    pushMatrix();
    translate(x,y);
    //translate(size/6, 0);
    rotate(rotation);
    
    fill(isOn? 255 : 0);
    stroke(isOn? 0 : 255);
    strokeWeight(size/5);
    ellipse(0,0,size*2,size*2);
    
    /*
    fill(invertColor? 0 : 255);
    textAlign(CENTER, CENTER);
      textSize(size*2);
      text("-", 0, -size/3);
    */
    popMatrix();
    
  }
}



