class CallBlock extends Block {
  int functionId;
  Block function;

  CallBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  void Setup() {
    functionId = 0;
    if (funcMap.containsKey(functionId)) {
      function = funcMap.get(functionId);
      leads[1].visible = true;
    }
    else{
      leads[1].visible = false;
    }
    children[1] = function;
  }
  
  void Update() {
    super.Update();
        leadsActive = inChain;

    if (function!= null && !funcMap.containsKey(functionId)){
      function = null;
      leads[1].visible = false;
    }
    else if (function == null && funcMap.containsKey(functionId)) {
      function = funcMap.get(functionId);
            leads[1].visible = true;

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

