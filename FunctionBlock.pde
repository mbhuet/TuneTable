class FunctionBlock extends Block {
  color funcColor;
  
  FunctionBlock(TuioObject tObj) {
    Init(tObj, 1);
    funcColor = color(0,255,0);
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

