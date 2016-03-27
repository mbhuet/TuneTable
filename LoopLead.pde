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
  float arc_start;
  float arc_end;
  PVector center;
  StartLoopBlock loopBlock;
  
  float ownerAngle;
  float occupantAngle;
  
  boolean drawFootprint = true;

  LoopLead(Block owner, Block occupant, StartLoopBlock loopBlock, float rot, PVector cent, float start, float end) {
    super(owner, rot);
    this.occupant = occupant;
    this.loopBlock = loopBlock;
    center = cent;
    arc_start = start;
    arc_end = end;
    //println("constructor " + rotation);
  }

  public void Update() {
    UpdateAngleRange();
        //println("update " + rotation);

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

      float arc_range = arc_end-arc_start;


    if (options.dashed) {
      dashedArc(0, 0, loopBlock.loopRadius, 0, arc_range, options.offset);
    } else {
      arc(0, 0, loopBlock.loopRadius * 2, loopBlock.loopRadius * 2, arc_start, arc_end);
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

    if (drawFootprint) { //this will draw a footprint
    rotate((arc_end - arc_start)/2);
      translate(loopBlock.loopRadius,0);
      dashCircle.setStroke(options.col);
      dashCircle.setStrokeWeight(5);
      shapeMode(CENTER);

      shape(dashCircle);
    }

    popMatrix();
  }

  public void highlightTravelled(float percent, color col) {
  }

  public boolean isUnderBlock(Block b) {
   PVector footprintPos = convertFromPolar(loopBlock.loopCenter, (arc_end - arc_start)/2 + ownerAngle, loopBlock.loopRadius);
   return (dist(footprintPos.x, footprintPos.y, b.x_pos, b.y_pos) <= connect_snap_dist);
  }
  
  public void connect(Block block) {
    /*
    occupant = block;
    occupied = true;
    trackBlock(block);
    block.arrangeLeads(rotation);
    */
    
    
  }

  public void disconnect() {
  }

  void trackBlock(Block block) {
  }

  
  void UpdateAngleRange(){
    PVector center = loopBlock.loopCenter;
    ownerAngle = atan2((center.y - owner.y_pos), 
    (center.x - owner.x_pos));
    //if(ownerAngle < 0) ownerAngle = -ownerAngle;
    //else ownerAngle = -ownerAngle + 2*PI;
    
    ownerAngle = map(ownerAngle, -PI, PI, 0, 2*PI);
    
    occupantAngle = atan2((center.y - occupant.y_pos), 
    (center.x - occupant.x_pos));
        occupantAngle = map(occupantAngle, -PI, PI, 0, 2*PI);

    //    if(occupantAngle < 0) occupantAngle = -occupantAngle;
    //else occupantAngle = -occupantAngle + 2*PI;

    //println(ownerAngle + ", " + occupantAngle);
  }
}

