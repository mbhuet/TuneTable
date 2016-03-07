class ConditionalBlock extends Block {
  boolean isTrue = false;
  int boolId;
  color myColor;

  BooleanBlock boolBlock;
  Lead boolLead;

  ConditionalBlock(TuioObject tObj) {
    Init(tObj, 2);
  }
  
  ConditionalBlock(int x, int y) {
    Init(2,x,y, 110);
  }

  void Setup() {
    boolId = sym_id - 10; //booleans are 100-109, corresponding conditionals are 110-119
    
    boolLead = new Lead(this, 0);
    boolLead.break_distance = 9999;
    boolLead.lines[0].visible = false;
    boolLead.lines[0].col = myColor;
    boolLead.lines[0].dashed = false;
    boolLead.lines[0].weight = 5;
    
    //leads[0].options.image = unlock;
    leads[0].lines[0].image = (isTrue ? unlock : lock);

    checkBooleanBlock();
  }

  void Update() {
    super.Update();
    leadsActive = inChain;

    checkBooleanBlock();
    boolLead.Update();
    boolLead.draw();
  }

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
    
    leads[0].lines[0].image = (isTrue? unlock : lock);
  }


  void OnRemove() {
    super.OnRemove();
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

