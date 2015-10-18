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
  void Activate(PlayHead play){
    super.Activate(play);
    finish();
  }
  
  public int[] getSuccessors(){
    return new int[]{0};
  }
}

