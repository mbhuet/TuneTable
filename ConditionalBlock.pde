class ConditionalBlock extends Block {
  boolean isTrue = false;
  int boolId;

  ConditionalBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  void Setup() {
    boolId = 100;//sym_id - 10; //booleans are 100-109, corresponding conditionals are 110-119
    isTrue =( boolMap.containsKey(boolId) && boolMap.get(boolId));
    leads[0].options.image = unlock;
    leads[1].options.image = lock;
  }

  void Update() {
    super.Update();
    leadsActive = inChain;
    isTrue = ( boolMap.containsKey(boolId) && boolMap.get(boolId));
  }
  
  
  void OnRemove() {
        super.OnRemove();

  }
    public void Activate(PlayHead play, Block previous) {
      super.Activate(play, previous);
    
    finish();
  }
  
  public boolean childIsSuccessor(int i){
    if (i == 0) return isTrue;
    else return !isTrue;
  }
  
  public int[] getSuccessors(){
    if (isTrue) return new int[]{0};
    else return new int[]{1};
  }
}

