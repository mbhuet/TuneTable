class EffectBlock extends Block {

  EffectBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  void Setup() {
  }
  void Update() {
    super.Update();
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

