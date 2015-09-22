class FunctionBlock extends Block {

  FunctionBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  void Setup() {
    allFunctionBlocks.add(this);
    funcMap.put(sym_id, this);
  }

  void Update() {
    super.Update();
  }

  void OnRemove() {
        super.OnRemove();

    allFunctionBlocks.remove(this);
    funcMap.remove(sym_id);
  }

  void Activate() {
    if (children[0] != null) children[0].Activate();
  }
}

