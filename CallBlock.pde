class CallBlock extends Block {
  int functionId;
  Block function;

  CallBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  void Setup() {
    functionId = sym_id - 10;
    if (funcMap.containsKey(functionId)) {
      function = funcMap.get(functionId);
    }
    children[0] = function;
  }
  
  void Update() {
    super.Update();
    if (function!= null && !funcMap.containsKey(functionId))
      function = null;
    else if (function == null && funcMap.containsKey(functionId)) {
      function = funcMap.get(functionId);
    }
  }
  void OnRemove() {
    super.OnRemove();
  }
    public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    finish();  
}

  public int[] getSuccessors(){
    return new int[]{0};
  }
}

