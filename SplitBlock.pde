class SplitBlock extends Block {

  SplitBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  void Setup() {
  }
  void Update() {
    super.Update();
    leadsActive =  inChain;
  }
  void OnRemove() {
    super.OnRemove();
  }
  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    finish();
  }

  //TODO should return two blocks
  public int[] getSuccessors() {
    int[] suc = new int[children.length];
    for (int i = 0; i<suc.length; i++) {
      suc[i] = i;
    }
    return suc;
  }
}

