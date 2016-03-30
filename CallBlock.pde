class CallBlock extends Block {
  int functionId;
  FunctionBlock function;

  EndLead endLead;

  boolean returning = false;

  //ArrayList<PlayHead> 

  CallBlock(TuioObject tObj) {
    Init(tObj, 2);
  }

  CallBlock(int x, int y) {
    Init(2, x, y, 122);
  }

  void Setup() {
    endLead = new EndLead(this);
    functionId = 0;
    leads[1].options.unlimitedDistance = true;
    CheckForFunction();
  }

  void Update() {
    super.Update();
    leadsActive = inChain;

    CheckForFunction();
    if (function != null) {
      endLead.SetTargetLead(lastActiveLeadInChain(function));
    }
    endLead.Update();
  }
  void OnRemove() {
    super.OnRemove();
  }

  public void Activate(PlayHead play, Block previous) {
    //if the previous block is not a parent, we can assume it is in another chain
    if (!parents.contains(previous)) {
      returning = true;
    } else {
      play.addFunctionCall(this);
    }
    super.Activate(play, previous);
    finish();
    returning = false;
  }

  void CheckForFunction() {
    if (function!= null && !funcMap.containsKey(functionId)) {
      function = null;
      leads[1].options.visible = false;
      leads[1].disconnect(false);
      endLead.options.visible = false;
    } else if (function == null && funcMap.containsKey(functionId)) {
      function = funcMap.get(functionId);
      leads[1].options.visible = true;
      leads[1].connect(function);
      endLead.options.visible = true;
    }
  }

  public void arrangeLeads(float parentLeadRot) {

    if (parents.size() > 1) return;
    if (leads.length == 1) return;
    float leadSeparation = 2*PI / (leads.length -1);
    float startAngle = PI + parentLeadRot + leadSeparation / 2;

    for (int i = 0; i < leads.length-1; i++) {
      float leadAngle = (startAngle + leadSeparation * i)%(2*PI);
      leads[i].SetRotation(leadAngle);
    }
  }

  void drawLeads() {

    for (Lead l : leads) {
      l.draw();
    }

    endLead.draw();
    println("draw endLead");
  }



  public int[] getSuccessors() {
    if (function == null || returning) {
      return new int[] {
        0
      };
    } else {
      return new int[] {
        1
      };
    }
  }

  void updateLeads(float offset, color col, boolean isActive, boolean setBlockColor, ArrayList<Block> activeVisited, ArrayList<Block> inactiveVisited) {
    super.updateLeads(offset, col, isActive, setBlockColor, activeVisited, inactiveVisited);
    println(endLead);
    endLead.lines = leads[1].lines;
  }
}

