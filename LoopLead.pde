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
  float loop_radius = block_diameter;
  PVector center;
  StartLoopBlock loopBlock;
  
  boolean drawFootprint = true;

  LoopLead(Block owner, Block occupant, StartLoopBlock loopBlock, float rot, PVector cent, float start, float end) {
    super(owner, rot);
    this.occupant = occupant;
    this.loopBlock = loopBlock;
    center = cent;
    arc_start = start;
    arc_end = end;
  }

  public void Update() {
  }

  public void draw() {
    if (!options.visible) return;
    stroke(options.col);
    strokeWeight(options.weight);
    noFill();
    
    pushMatrix();
    translate(center.x, center.y);
    rotate(rotation);

    if (options.dashed) {
      dashedArc(0, 0, loop_radius, arc_start, arc_end, options.offset);
    } else {
      arc(0, 0, loop_radius * 2, loop_radius * 2, arc_start, arc_end);
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
      translate(distance, 0);
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
    return false;
  }
  
  public void connect(Block block) {
  }

  public void disconnect() {
  }

  void trackBlock(Block block) {
  }
}

