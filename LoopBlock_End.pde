class EndLoopBlock extends Block {

  EndLoopBlock(TuioObject tObj) {
    Init(tObj, 1);
  }
  
    EndLoopBlock(int x, int y) {
    Init(1,x,y, 122);
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

  public int[] getSuccessors() {
    return new int[] {0};
  }
  
  public void finish(){
  PlayHead temp = playHead;
    if (playHead != null)playHead = null;
    temp.playColor = this.blockColor;
    temp.returnToLastStartLoop();
  
  }
}

