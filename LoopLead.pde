/* RULES OF LOOP LEADS
 - always has an occupant
 - block footprint exists in the middle
 - has an arc angle, default is 2PI
 - has a center point
 - break distance is anything outside of a certain distance range from the center (block_diameter/2?)
 - if a block is placed in the footprint, it becomes the occupant, former occupant becomes occupant of new occupant's looplead
 - if arc angle is less than x, do not draw a footprint
 */


class LoopLead extends Lead {
  StartLoopBlock loopBlock;
  Block previous_occupant;

  float ownerAngle;
  float occupantAngle;

  boolean drawFootprint = true;

  LoopLead(Block owner, Block occupant, Block previous, StartLoopBlock loopBlock, int index) {
    super(owner, 0, index);
    this.occupant = occupant;
    this.loopBlock = loopBlock;
    //loopBlock.loopLeads.add(this);
    loopBlock.blocksInLoop.add(loopBlock.blocksInLoop.indexOf(previous) + 1, this.owner);
  }

  LoopLead(Block owner, Block occupant, Block previous, StartLoopBlock loopBlock, int index, LeadOptions options) {
    this(owner, occupant, previous, loopBlock, index);
    this.options = options;
  }

  public void Update() {
    UpdateArcRange();
    //println(rotation);
  }

  public void draw() {
    if (!options.visible) return;

    stroke(options.col);
    strokeWeight(options.weight);
    noFill();

    pushMatrix();
    translate(loopBlock.loopCenter.x, loopBlock.loopCenter.y);
    rotate(ownerAngle);
    //println("ownerAngle " + ownerAngle);

    float arc_range = abs(occupantAngle - ownerAngle);


    if (options.dashed) {
      dashedArc(0, 0, loopBlock.loopRadius, 0, arc_range, options.offset);
    } else {
      arc(0, 0, loopBlock.loopRadius * 2, loopBlock.loopRadius * 2, 0, arc_range);
    }
    
    
    if (footprintActive()) { //this will draw a footprint
      rotate(arcMiddle());
      translate(loopBlock.loopRadius, 0);
      dashCircle.setStroke(options.col);
      dashCircle.setStrokeWeight(5);
      shapeMode(CENTER);

      shape(dashCircle);
    }
    
    
    popMatrix();
    
    
    pushMatrix();
    translate(owner.x_pos, owner.y_pos);
    rotate(rotation);

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
      text(options.number, 0, 0);

      popMatrix();
    }

    

    popMatrix();
  }

 public void highlightTravelled(float percent, color col) {
    percent = min(1, percent);
    percent = max(0, percent);
    stroke(col);
    strokeWeight(block_diameter/4);
    strokeCap(SQUARE);
    noFill();
    pushMatrix();

    translate(loopBlock.loopCenter.x, loopBlock.loopCenter.y);
    //rotate(owner.rotation);
    float arc_range = abs(occupantAngle - ownerAngle);

    arc(0, 0, loopBlock.loopRadius * 2, loopBlock.loopRadius * 2, ownerAngle + arc_range * (1.0-percent), occupantAngle);

    popMatrix();
  }

  public boolean isUnderBlock(Block b) {
    if (!footprintActive()) return false;
    PVector footprintPos = convertFromPolar(loopBlock.loopCenter, arcMiddle() + ownerAngle, loopBlock.loopRadius);
    if (debug) {
      colorMode(RGB);
      stroke(255, 0, 0);
      strokeWeight(1);
      noFill();
      ellipse(footprintPos.x, footprintPos.y, block_diameter * 1.1, block_diameter * 1.1);
    }
    return (dist(footprintPos.x, footprintPos.y, b.x_pos, b.y_pos) <= connect_snap_dist);
  }

  public void connect(Block block) {
    owner.SetChild(block, leadIndex);
    block.leads[0] = new LoopLead(block, occupant, owner, loopBlock, 0, block.leads[0].options);
    block.SetChild(this.occupant, 0);
    this.occupant = block;
  }

  public void disconnect(boolean connectAround) {
        if (occupant == owner) return;

    //if we want to connect to the block after the current occupant
    if(connectAround && occupant.leads[0].occupant != null){
      loopBlock.blocksInLoop.remove(occupant);
      owner.SetChild(occupant.leads[0].occupant, 0);
      occupant = occupant.leads[0].occupant;

    }
    else{
    owner.RemoveChild(0);
    occupant = null;
              loopBlock.blocksInLoop.remove(owner);

    }
  
    }


    void trackBlock(Block block) {
    }

  boolean footprintActive() {
    return abs(occupantAngle - ownerAngle)*loopBlock.loopRadius > block_diameter * 2;
  }

  public boolean occupantTooFar() {
    if (occupant == owner)  return false;
    float dist = dist(occupant.x_pos, occupant.y_pos, loopBlock.loopCenter.x, loopBlock.loopCenter.y);
    return (dist > loopBlock.loopRadius + block_diameter/2 || dist < loopBlock.loopRadius - block_diameter/2);
  }

  public boolean canRecieveChild() {
    return footprintActive();
  }



  void UpdateArcRange() {
    PVector center = loopBlock.loopCenter;
    ownerAngle = atan2((center.y - owner.y_pos), 
    (center.x - owner.x_pos));

    ownerAngle = map(ownerAngle, -PI, PI, 0, 2*PI);

    occupantAngle = atan2((center.y - occupant.y_pos), 
    (center.x - occupant.x_pos));

    occupantAngle = map(occupantAngle, -PI, PI, 0, 2*PI);
    if (occupantAngle <= ownerAngle) occupantAngle = occupantAngle + 2*PI;

    //if(occupant == owner) occupantAngle = ownerAngle + 2*PI;
  }

  float arcMiddle() {
    return (occupantAngle - ownerAngle)/2;
  }

  public void UpdateRotationFromParent(float rotDelta) {
    if (occupant == owner) {
      rotation += rotDelta;
    }
  }
}

