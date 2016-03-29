


class StartLoopBlock extends Block {
  int count = 1;
  int max_count = 9;
  int displayCount = 0;
  int text_size = block_diameter/3;

  
  boolean justDepleted = false;
  
  PlusButton plus;
  MinusButton minus;
  
  //ArrayList<LoopLead> loopLeads;
  ArrayList<Block> blocksInLoop;
  PVector loopCenter;
  float loopRadius = block_diameter;
  
  LoopLead headLoopLead;
  
  StartLoopBlock(TuioObject tObj) {
    Init(tObj, 2);
  }
  
  StartLoopBlock(int x, int y) {
    Init(2,x,y, 121);
  }

  void Setup() {
    plus = new PlusButton(0, 0, 0, block_diameter/4, this);
    minus = new MinusButton(0, 0, 0, block_diameter/4, this);
    
    loopCenter = convertFromPolar(new PVector(x_pos, y_pos), rotation, block_diameter);

//loopLeads = new ArrayList<LoopLead>();
    blocksInLoop = new ArrayList<Block>();
    blocksInLoop.add(this);
    headLoopLead = new LoopLead(this, this, this, this, 0);
    leads[0] = headLoopLead;
    updateCountLead();
  }
  void Update() {
    super.Update();
    leadsActive =  inChain;
    UpdateLoopCenter();
    UpdateLoopRadius();
    arrangeButtons();


    drawNumber();
  }
  void OnRemove() {
    super.OnRemove();
  }
  public void Activate(PlayHead play, Block previous) {
    println("Activate finishing " + justDepleted + ", count " + count);    
    super.Activate(play, previous);
    
    if(count > 0){
        //play.addStartLoop(this);
    }
    if(count == 1) justDepleted = true;
    DecrementCount(false);

    finish();
    justDepleted = false;
    
    
  }
  
  void updateCountLead(){
    displayCount = count;
    //TODO choose number to represent infinity, if count is that number, showNumber = false, image = infinity.jpg
  }
  
  void UpdateLoopCenter(){
    PVector midpoint = new PVector();
    for(Block b : blocksInLoop){
      midpoint.x+= b.x_pos;
      midpoint.y+= b.y_pos;
    }
      midpoint.x = midpoint.x/blocksInLoop.size();
      midpoint.y = midpoint.y/blocksInLoop.size();
    loopCenter = convertFromPolar(new PVector(x_pos, y_pos), leads[0].rotation, loopRadius);
  }


  public boolean childIsSuccessor(int i) {
   if(justDepleted){
     if(i==0) return true;
     else return false;
 }  
    if (i == 0) return (count > 0);
    else return !(count > 0);
  }
  
  public int[] getSuccessors(){
 
    if (count > 0 || justDepleted) return new int[]{0};
    else return new int[]{1};
  }
  
  void DecrementCount(boolean cycle){
    count--;
    if(count < 0){
      if(cycle){ count = max_count;
    }
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
  
  void Die(){
    super.Die();
    plus.Destroy();
    minus.Destroy();
  }
  
  
  //Find the average distance of every block in the loop from the loop center, sets loop radius to that
  void UpdateLoopRadius(){
    float total_dist = 0;
    for(Block block : blocksInLoop){
      total_dist += dist(block.x_pos, block.y_pos, loopCenter.x, loopCenter.y);
    }
      loopRadius = min(total_dist/blocksInLoop.size(), block_diameter * 2);
  }
  
  void drawPrototypeCircleLead(){
   ellipseMode(CENTER);
   strokeWeight(10);
   stroke(255);
   noFill();
   PVector center = convertFromPolar(new PVector(x_pos, y_pos), rotation, block_diameter * 2);
   ellipse(center.x, center.y, block_diameter * 4, block_diameter * 4);
   PVector dashCenter = convertFromPolar(new PVector(x_pos, y_pos), rotation, block_diameter * 4);
   shapeMode(CENTER);
   shape(dashCircle, (int)dashCenter.x, (int)dashCenter.y);
  }
  
  void drawLeads() {

    for (Lead l : leads) {
      l.draw();
    }
    
    //headLoopLead.draw();
  }
    
  void drawNumber(){
        
        pushMatrix();
        translate(x_pos, y_pos);
        rotate(leads[0].rotation);
        translate(block_diameter * .8, 0);
        rotate(PI/2.0);

        fill((invertColor? 0 : 255)); //should match background
        stroke(255);
        strokeWeight(text_size/10);
        ellipseMode(CENTER);
        ellipse(0, text_size/10, text_size, text_size);

        textAlign(CENTER, CENTER);
        textSize(text_size);
        fill((invertColor? 255 : 0)); //text color
        text(displayCount, 0, 0);

        popMatrix();
  
  }
  
}

