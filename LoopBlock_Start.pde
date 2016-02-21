class StartLoopBlock extends Block {
  int count = 0;
  int max_count = 9;
  
  PlusButton plus;
  MinusButton minus;
  
  StartLoopBlock(TuioObject tObj) {
    Init(tObj, 2);
  }
  
  StartLoopBlock(int x, int y) {
    Init(2,x,y, 121);
  }

  void Setup() {
     plus = new PlusButton(0, 0, 0, block_diameter/4, this);
    minus = new MinusButton(0, 0, 0, block_diameter/4, this);
      leads[0].options.showNumber = true;
    
  }
  void Update() {
    super.Update();
    leadsActive =  inChain;
    arrangeButtons();
  }
  void OnRemove() {
    super.OnRemove();
  }
  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    
    if(count > 0){
        play.addStartLoop(this);
    }

    finish();
    DecrementCount(false);
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
  
  void arrangeButtons(){
    float countLeadRot = leads[0].rotation;
    float buttonDist = block_diameter * .75; // how far along the lead
    float buttonLeadOffset = block_diameter/2; // how far from the lead
    
    PVector buttonCenter = new PVector(x_pos + cos(countLeadRot) * buttonDist, 
                                       y_pos + sin(countLeadRot) * buttonDist);
    PVector plusPos = new PVector(buttonCenter.x + cos(countLeadRot-PI/2) * buttonLeadOffset, 
                                  buttonCenter.y + sin(countLeadRot-PI/2) * buttonLeadOffset);
    PVector minusPos = new PVector(buttonCenter.x + cos(countLeadRot+PI/2) * buttonLeadOffset, 
                                   buttonCenter.y + sin(countLeadRot+PI/2) * buttonLeadOffset);

    plus.Update((int)(plusPos.x), 
    (int)(plusPos.y), 
    countLeadRot + PI/2);
    minus.Update((int)(minusPos.x), 
    (int)(minusPos.y), 
    countLeadRot + PI/2);
  }
  
}
