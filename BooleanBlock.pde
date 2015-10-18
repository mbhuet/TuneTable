class BooleanBlock extends Block{
  
  BooleanBlock(TuioObject tObj){
    Init(tObj, 0);
  }
  
  void Setup(){
    boolMap.put(sym_id, true);
  }
  
  void Update(){
    super.Update();
  }
  
  void OnRemove(){
    super.OnRemove();
    boolMap.put(sym_id, false);  
  }
  
  void Activate(PlayHead play){
    super.Activate(play);
  }
  
  public int[] getSuccessors(){
    return new int[]{};
  }

}
