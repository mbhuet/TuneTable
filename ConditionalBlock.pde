class ConditionalBlock extends Block {
  boolean isTrue = false;
  int boolId;

  ConditionalBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  void Setup() {
    boolId = 112;//sym_id - 10; //booleans are 100-109, corresponding conditionals are 110-119
    isTrue =( boolMap.containsKey(boolId) && boolMap.get(boolId));
  }

  void Update() {
    super.Update();
    leadsActive =  (parents.size() > 0) ? true : false;
    
    isTrue = ( boolMap.containsKey(boolId) && boolMap.get(boolId));
  }
  void OnRemove() {
        super.OnRemove();

  }
    public void Activate(PlayHead play, Block previous) {
      super.Activate(play, previous);
    
    finish();
  }
  
  public int[] getSuccessors(){
    if (isTrue) return new int[]{0};
    else return new int[]{1};
  }
}

