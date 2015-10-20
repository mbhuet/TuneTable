class BooleanBlock extends Block{
  
  BooleanBlock(TuioObject tObj){
    Init(tObj, 0);
  }
  
  void Setup(){
    boolMap.put(sym_id, true);
    canBeChained = false;
  }
  
  void Update(){
    super.Update();
  }
  
  void OnRemove(){
    super.OnRemove();
  }
  
  void Die(){
    super.Die();
        boolMap.put(sym_id, false);  

  }
  
  void Activate(PlayHead play, Block previous){
    super.Activate(play, previous);
  }
  
  public int[] getSuccessors(){
    return new int[]{};
  }

}
