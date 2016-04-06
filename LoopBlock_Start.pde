


class StartLoopBlock extends Block {
  int count = 1;
  int max_count = 9;
  int displayCount = 0;

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
    Init(2, x, y, 121);
  }

  void Setup() {
    plus = new PlusButton(0, 0, 0, block_diameter/4, this);
    minus = new MinusButton(0, 0, 0, block_diameter/4, this);

    loopCenter = convertFromPolar(new PVector(x_pos, y_pos), rotation, block_diameter);

    blocksInLoop = new ArrayList<Block>();
    //blocksInLoop.add(this);
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

    if (inChain) {
      drawNumber();
      plus.isShowing = true;
      minus.isShowing = true;
    } else {
      plus.isShowing = false;
      minus.isShowing = false;
    }
  }
  void OnRemove() {
    super.OnRemove();
  }
  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);

    if (count > 0) {
      //play.addStartLoop(this);
    }
    if (count == 1) justDepleted = true;
    else justDepleted = false;
    
    DecrementCount(false);

    finish();
    justDepleted = false;
  }

  void updateCountLead() {
    displayCount = count;
    //TODO choose number to represent infinity, if count is that number, showNumber = false, image = infinity.jpg
  }

  void UpdateLoopCenter() {
    PVector midpoint = new PVector();
    for (Block b : blocksInLoop) {
      midpoint.x+= b.x_pos;
      midpoint.y+= b.y_pos;
    }
    midpoint.x = midpoint.x/blocksInLoop.size();
    midpoint.y = midpoint.y/blocksInLoop.size();
    
    float rot = atan2((midpoint.y - this.y_pos), (midpoint.x - this.x_pos));
    //leads[0].rotation = rot;
           

     
     float dist = dist(x_pos, y_pos, midpoint.x, midpoint.y);
          
     float avg_radius = min(block_diameter * 2, dist);
     //println(loopRadius + " " + avg_radius);
     //loopRadius = avg_radius;
     
     
     //PVector testCenter = convertFromPolar(new PVector(x_pos, y_pos), leads[0].rotation, 120);
     
     loopCenter = convertFromPolar(new PVector(x_pos, y_pos), leads[0].rotation, loopRadius);
     //loopCenter = testCenter;
    //println(testCenter);
  }

  //Find the average distance of every block in the loop from the loop center, sets loop radius to that
  void UpdateLoopRadius() {
    if (blocksInLoop.size() == 1) {
      loopRadius = block_diameter;
      return;
    }
    float total_dist = 0;
    for (Block block : blocksInLoop) {
      total_dist += dist(block.x_pos, block.y_pos, loopCenter.x, loopCenter.y);
    }
    //println(blocksInLoop.size());
    loopRadius = min(total_dist/blocksInLoop.size(), block_diameter * 2);
  }


  public boolean childIsSuccessor(int i) {
    
    if (justDepleted) {
      if (i==0) return true;
      else return false;
    }  
    
    if (i == 0) return (count > 0);
    else return !(count > 0);
  }

  public int[] getSuccessors() {

    if (count > 0 || justDepleted) return new int[] {
      0
    };
    else return new int[] {
      1
    };
  }

  void DecrementCount(boolean cycle) {
    count--;
    if (count < 0) {
      if (cycle) { 
        count = max_count;
      } else count = 0;
    }
    updateCountLead();
  }

  void IncrementCount(boolean cycle) {
    count ++;
    if (count > max_count) {
      if (cycle) count = 0;
      else count = max_count;
    }
    updateCountLead();
  }  

  void arrangeButtons() {
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
  
 

  void Die() {
    super.Die();
    plus.Destroy();
    minus.Destroy();
  }






  void drawLeads() {

    for (Lead l : leads) {
      l.draw();
    }
    
    //This hack is necessary because drawing arcs is way too slow. Drawing the loop as a solid arc brought the framerate to 12 fps
    if(count == 0){
      for(LineOptions line : leads[0].lines){
        if(!line.visible) continue;
      stroke(line.col);
      ellipseMode(CENTER);
      ellipse(loopCenter.x, loopCenter.y, line.x_offset * 2, line.x_offset * 2);
      }
    }

    //headLoopLead.draw();
  }

  void drawNumber() {

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

