class SplitBlock extends Block {

  SplitBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  void Setup() {
  }
  void Update() {
    super.Update();
  }
  void OnRemove() {
        super.OnRemove();

  }
  void Activate(PlayHead play){
    super.Activate(play);
    finish();
  }
  
  //TODO should return two blocks
  public int[] getSuccessors(){
    int[] suc = new int[children.length];
    for(int i = 0; i<suc.length; i++){
      suc[i] = i;
    }
    return suc;
  }
}

