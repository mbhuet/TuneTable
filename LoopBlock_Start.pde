class StartLoopBlock extends Block {
  int count = 0;
  int max_count = 9;
  
  StartLoopBlock(TuioObject tObj) {
    Init(tObj, 2);
  }
  
  StartLoopBlock(int x, int y) {
    Init(2,x,y, 121);
  }

  void Setup() {
      leads[0].options.showNumber = true;

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
    play.addStartLoop(this);
    DecrementCount(false);
    finish();
  }
  
  void updateCountLead(){
    leads[0].options.number = count;
    //TODO choose number to represent infinity, if count is that number, showNumber = false, image = infinity.jpg
  }


  public boolean childIsSuccessor(int i) {
    if (i == 0) return (count > 0);
    else return !(count > 0);
  }
  
  public int[] getSuccessors(){
    if (count > 0) return new int[]{0};
    else return new int[]{1};
  }
  
  void DecrementCount(boolean cycle){
    count--;
    if(count < 0){
      if(cycle) count = max_count;
      else count = 0;
    }
    updateCountLead();
  }
  
  void IncrementCount(boolean cycle){
    count ++;
    if(count > max_count){
      if(cycle) count = 0;
      else count = max_count;
    }
    updateCountLead();
  }  
  
}

