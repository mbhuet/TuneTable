class ConditionalBlock extends Block {
  boolean isTrue = false;
  int boolId;

  ConditionalBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  void Setup() {
    boolId = sym_id - 10; //booleans are 100-109, corresponding conditionals are 110-119
    isTrue = boolMap.get(boolId);
  }

  void Update() {
    super.Update();

    isTrue = boolMap.get(boolId);
  }
  void OnRemove() {
        super.OnRemove();

  }
  void Activate(PlayHead play){
    super.Activate(play);
    finish();
  }
  
  public int[] getSuccessors(){
    if (isTrue) return new int[]{0};
    else return new int[]{1};
  }
}

