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
  void Activate() {
    for (Block b : children) {
      if (b != null) b.Activate();
    }
  }
}

