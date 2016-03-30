class CallBlock extends Block {
  int functionId;
  Block function;

  CallBlock(TuioObject tObj) {
    Init(tObj, 2);
  }
  
  CallBlock(int x, int y){
    Init(2, x, y, 122);
  }

  void Setup() {
    functionId = 0;
        leads[1].options.unlimitedDistance = true;

    CheckForFunction();
  }
  
  void Update() {
    super.Update();
        leadsActive = inChain;

    CheckForFunction();
  }
  void OnRemove() {
    super.OnRemove();
  }
    public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    finish();  
}

void CheckForFunction(){
  if (function!= null && !funcMap.containsKey(functionId)){
      function = null;
      leads[1].options.visible = false;
      leads[1].disconnect(false);
    }
    else if (function == null && funcMap.containsKey(functionId)) {
      function = funcMap.get(functionId);
            leads[1].options.visible = true;
      leads[1].connect(function);
    }
}

public void arrangeLeads(float parentLeadRot) {

    if (parents.size() > 1) return;
    if(leads.length == 0) return;
    float leadSeparation = 2*PI / leads.length -1;
    float startAngle = PI + parentLeadRot + leadSeparation / 2;

    for (int i = 0; i < leads.length-1; i++) {
      float leadAngle = (startAngle + leadSeparation * i)%(2*PI);
      leads[i].SetRotation(leadAngle);
    }
  }

  

  public int[] getSuccessors(){
    return new int[]{0};
  }
}

