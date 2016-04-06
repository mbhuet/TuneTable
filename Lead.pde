class Lead {
  int leadIndex;
  Block owner;
  Block occupant;
  float rotation;
  float distance;
  float reg_distance = block_diameter * 1.5;
  float break_distance = block_diameter * 2; //at what distance will a connection break;
  float connect_snap_dist = block_diameter / 2; //how close does a block need to be to connect to this lead?
  boolean occupied;
  int lineSeparation = 1;
  int standardWeight = 10;
  
  public LineOptions[] lines;
  public LeadOptions options;


  Lead(Block owner, float rot, int index) {
    this.owner = owner;
    this.rotation = rot;
    leadIndex = index;
    occupied = false;
    distance = reg_distance;
    options = new LeadOptions();
    lines = new LineOptions[5];
    for (int i = 0; i< lines.length; i++) {
      lines[i] = new LineOptions();
      lines[i].visible = false;
      lines[i].weight = standardWeight;
    }
  }
  
  Lead(Block owner, float rot, int index, LeadOptions options){
    this(owner, rot, index);
    this.options = options;
  }

  public void Update() {
    if (occupied) {
      trackBlock(occupant);
    }
  }

  int numLinesVisible() {
    int num = 0;
    for (int i = 0; i< lines.length; i++) {
      if (lines[i].visible) 
        num++;
    }
    return num;
  }

  public void draw() {
    if(!options.visible) return;
    colorMode(RGB, 255);

    int numVisible = numLinesVisible();
    int numVisibleVisited = 0;
    float start_x = -1 * (standardWeight * numVisible + lineSeparation * (numVisible-1))/2;

    pushMatrix();
    translate(owner.x_pos, owner.y_pos);
    rotate(rotation);

    for (int i = 0; i<lines.length; i++) {
      LineOptions lineOptions = lines[i];
      if (!lineOptions.visible) continue;
      stroke(lineOptions.col);
      strokeWeight(lineOptions.weight);

      pushMatrix();
      int offset_x = (numVisibleVisited * (standardWeight + lineSeparation));
      lines[i].x_offset = (start_x + offset_x);
      translate(0, start_x + offset_x);

      if (lineOptions.dashed) {
        dashedLine(0, 0, (int)distance, 0, (lineOptions.marching? (options.reverse_march? -lineOptions.dash_offset : lineOptions.dash_offset): 0));
      } else {
        line(0, 0, distance - block_diameter/2, 0);
      }

      



      popMatrix();
      numVisibleVisited++;
    }
    
    if (showFootprint()) {
      pushMatrix();
      translate(distance, 0);
      dashCircle.setStroke(color(255));//lines[i].col);
      dashCircle.setStrokeWeight(5);
      shapeMode(CENTER);
      shape(dashCircle);
      popMatrix();
    }
    
    if (options.image != null) {
        pushMatrix();
        translate(distance/2, 0);
        rotate(PI/2.0);
        translate(-options.image.width/2, -options.image.height/2);
        fill((invertColor? 0 : 255));
        noStroke();
        rectMode(CORNER);
        rect(0, 0, options.image.width, options.image.height);

        image(options.image, 0, 0);
        popMatrix();
      }

      if (options.showNumber) {

        pushMatrix();
        translate(distance/2, 0);
        rotate(PI/2.0);

        fill((invertColor? 0 : 255)); //should match background
        stroke(255);
        strokeWeight(text_size/10);
        ellipseMode(CENTER);
        ellipse(0, text_size/10, text_size, text_size);

        textAlign(CENTER, CENTER);
        textSize(text_size);
        fill((invertColor? 255 : 0)); //text color
        text(options.number, 0, 0);

        popMatrix();
      }

    popMatrix();
  }

  public void highlightTravelled(int lineNum, float percent, color col) {
    percent = min(1, percent);
    percent = max(0, percent);
    stroke(col);
    strokeWeight(block_diameter/4);
    strokeCap(SQUARE);

    pushMatrix();

    translate(owner.x_pos, owner.y_pos);
    //translate(lines[lineNum].x_offset, 0);
    rotate(rotation);
    //translate(block_diameter/2, 0);
    
    if(options.reverse_march){
      println("reverse march highlight");
            line(0, 0, (distance) * (percent), 0);
    }
    else{
      line( (distance) * (1.0-percent), 0, distance, 0);
    }

    popMatrix();
  }

  public boolean isUnderBlock(Block b) {
    PVector look = footprintPosition();
    return (dist(look.x, look.y, b.x_pos, b.y_pos) <= connect_snap_dist);
  }

  public void connect(Block block) {
    occupant = block;
    occupied = true;
    trackBlock(block);

    if(leadIndex >=0){
      owner.SetChild(block, leadIndex);
    }
    if (block.parents.size() == 1) {
      block.arrangeLeads(rotation);
    }
  }
  
  boolean showFootprint(){
    return !occupied;
  }

  public void disconnect(boolean connectAround) {
        println("LEAD DISCONNECT");
        println(owner);

    occupant = null;
    occupied = false;
    distance = reg_distance;
    if(leadIndex >=0){
      owner.RemoveChild(leadIndex);
    }
  }
  

  void trackBlock(Block block) {                       
    rotation = atan2((block.y_pos - owner.y_pos), 
    (block.x_pos - owner.x_pos));
    distance = dist(block.x_pos, block.y_pos, owner.x_pos, owner.y_pos);
  }

  public void SetRotation(float rot) {
    rotation = rot;
  }
  
  //returns whether or not this leads's occupant is too far away to maintain the connection
  public boolean occupantTooFar(){
    return options.unlimitedDistance ? false : distance > break_distance;
  }
  
  public PVector footprintPosition(){
    float x = owner.x_pos + cos(rotation) * distance;
    float y = owner.y_pos + sin(rotation) * distance;
    return new PVector(x,y);
    
  }
  
  public boolean canRecieveChild(){
    return occupant == null;
  }
  
  public void UpdateRotationFromParent(float rotDelta){
  if (!occupied){
    rotation += rotDelta; 
  }
  
  
  }
}

class LineOptions {
  public boolean visible = false;
  public boolean dashed = false;
  public boolean marching = true;
  public float dash_offset = 0;
  public float x_offset = 0;
  public color col = color(invertColor ? 255 : 0);
  public int weight = 10;
}

class LeadOptions {
  public boolean reverse_march = false;
  public boolean visible = true;
  public PImage image;
  public int number = 0;
  public boolean showNumber = false;
  public boolean unlimitedDistance = false;
}

