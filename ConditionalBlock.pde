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
    boolId = 100;//sym_id - 10; //booleans are 100-109, corresponding conditionals are 110-119
    
    boolLead = new Lead(this, 0);
    boolLead.break_distance = 9999;
    boolLead.options.visible = false;
    boolLead.options.col = myColor;
    boolLead.options.dashed = false;
    boolLead.options.weight = 5;
    
    leads[0].options.image = unlock;
    leads[1].options.image = lock;

    checkBooleanBlock();
  }

  void Update() {
    super.Update();
    leadsActive = inChain;

    checkBooleanBlock();
    boolLead.draw();
  }

  void checkBooleanBlock() {
    boolean inMap = boolMap.containsKey(boolId);
    if (inMap && !isTrue) {//the booleanBlock has just been added to the dictionary
      isTrue = true;
      boolBlock = boolMap.get(boolId);
      boolLead.connect(boolBlock);
      boolLead.options.visible = true;
    } else if (!inMap && isTrue) { //the booleanBlock has just been removed from the dictionary
      isTrue = false;
      boolBlock = null;
      boolLead.disconnect();
      boolLead.options.visible = false;
    }
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

