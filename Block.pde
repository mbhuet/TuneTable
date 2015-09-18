abstract class Block {

  TuioObject tuioObj;
  int sym_id;
  float x_pos;
  float y_pos;
  float rotation;
  BlockType type;
  int numLeads = 0;
  
  float block_width;

  Block parent;
  Block[] children;
  Lead[] leads;
  
  ArrayList<PVector> posHistory = new ArrayList<PVector>();
  ArrayList<Float> rotHistory = new ArrayList<Float>();
  int historyVals = 10;
  
  abstract void Setup();
  abstract void Update();
  abstract void OnRemove();
  abstract void Activate();

  void Init(TuioObject tobj, int numLeads) {
    this.numLeads = numLeads;
    tuioObj = tobj;
    sym_id = tobj.getSymbolID();
    allBlocks.add(this);
    
    children = new Block[numLeads];
    leads = new Lead[numLeads];
    
    for(int i = 0; i<numLeads; i++){
        leads[i] = new Lead(this, i * 2*PI / numLeads);
    }
    
    Setup();
  }
  
  
  public void UpdatePosition() {
    float new_x_pos = tuioObj.getScreenX(width);// - cos(rotation) * (.5/3.25) * block_height;
    float new_y_pos = tuioObj.getScreenY(height);// - sin(rotation) * (.5/3.25) * block_height;
    
    rotHistory.add(tuioObj.getAngle());
    posHistory.add(new PVector(new_x_pos, new_y_pos));
    
    if (posHistory.size() < historyVals){
      x_pos = new_x_pos;
      y_pos = new_y_pos;
      rotation = tuioObj.getAngle();
    }
    
    else{
    
        if (posHistory.size() > historyVals){
          posHistory.remove(0);
        }
        
        if (rotHistory.size() > historyVals){
          rotHistory.remove(0);
        }
        
        float avg_x = 0;
        float avg_y = 0;
        
        float avg_rot = 0;
        float sum_cos = 0;
        float sum_sin = 0;
      
        for (int i = 0; i<posHistory.size(); i++){
          avg_x += posHistory.get(i).x;
          avg_y += posHistory.get(i).y;
        }
        
        for (int i = 0; i<rotHistory.size(); i++){
          sum_cos += cos(rotHistory.get(i));
          sum_sin += sin(rotHistory.get(i));
        }
        
        avg_rot = atan2(sum_sin, sum_cos);
        
        avg_x = avg_x/posHistory.size();
        avg_y = avg_y/posHistory.size();
        
        x_pos = avg_x;
        y_pos = avg_y;
        rotation = avg_rot;
    }
  }

  
  

  public void FindChildren() {

    for (Block cur : allBlocks) {
      
    }
  }


  public void drawShadow() {
    strokeWeight(0);
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
    fill(0);  // Set fill to black
    ellipse(x_pos, y_pos, block_diameter, block_diameter);
  }
  
  public void drawLeads() {
      for(Lead l : leads){
        l.draw();
      }
  }
  
  public boolean IsUnder(int hit_x, int hit_y){
    //will only return true if the hit is near the symbol position
    //checking if a point is within the full rectangular area would require calculating all corner points, and I don't want to do that right now.
        return (dist(hit_x, hit_y, x_pos, y_pos) < block_diameter/2);

  }

  public String toString() {
    return ("\nid: " + sym_id + "  x: " + x_pos + "  y: " + y_pos);
  }
}

