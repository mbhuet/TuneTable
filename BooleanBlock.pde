class BooleanBlock extends Block{
  
  BooleanBlock(TuioObject tObj){
    Init(tObj, 0);
  }
  
  BooleanBlock(int x, int y){
    Init(0, x, y, 100);
  }
  
  void Setup(){
    boolMap.put(sym_id, this);
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
        boolMap.remove(sym_id);  

  }
  
  void Activate(PlayHead play, Block previous){
    super.Activate(play, previous);
  }
  
  public int[] getSuccessors(){
    return new int[]{};
  }

}
