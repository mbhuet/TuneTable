class FunctionBlock extends Block{
  
  FunctionBlock(TuioObject tObj){
    numLeads = 1;
    Init(tObj);
  }
  
  void Setup(){
      allFunctionBlocks.add(this);
  }
  
  void Update(){}
  void OnRemove(){}
  void Activate(){}
}
