class Lead {
  Block owner;
  Block occupant;
  float rotation;
  float distance;
  float reg_distance = block_diameter * 1.5;
  float break_distance = block_diameter * 2; //at what distance will a connection break;
  float connect_snap_dist = block_diameter / 2; //how close does a block need to be to connect to this lead?
  boolean occupied;
  int text_size = block_diameter/3;

  public LeadOptions options;


  Lead(Block owner, float rot) {
    this.owner = owner;
    this.rotation = rot;
    occupied = false;
    distance = reg_distance;
    options = new LeadOptions();
  }

  public void Update() {
    if (occupied) {
      trackBlock(occupant);
    }
  }

  public void draw() {

    if (!options.visible) return;
    stroke(options.col);
    strokeWeight(options.weight);

    pushMatrix();
    translate(owner.x_pos, owner.y_pos);
    rotate(rotation);

    if (options.dashed) {
      dashedLine(0, 0, (int)distance, 0, options.offset);
    } else {
      line(0, 0, distance - block_diameter/2, 0);
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

    if (!occupied) {
      translate(distance, 0);
      dashCircle.setStroke(options.col);
      dashCircle.setStrokeWeight(5);
      shapeMode(CENTER);

      shape(dashCircle);
    }

    popMatrix();
  }

  public void highlightTravelled(float percent, color col) {
    percent = min(1, percent);
    percent = max(0, percent);
    stroke(col);
    strokeWeight(block_diameter/4);
    strokeCap(SQUARE);

    pushMatrix();

    translate(owner.x_pos, owner.y_pos);
    rotate(rotation);
    translate(block_diameter/2, 0);

    line( (distance - block_diameter) * (1.0-percent), 0, distance - block_diameter, 0);

    popMatrix();
  }

  public void highlightActive(float offset, color col) {
    dashedLine((int)owner.x_pos, 
    (int)owner.y_pos, 
    (int)occupant.x_pos, 
    (int)occupant.y_pos, 
    offset);
  }

  public void highlightOccupied() {
  }

  public boolean isUnderBlock(Block b) {
    float look_x = owner.x_pos + cos(rotation) * distance;
    float look_y = owner.y_pos + sin(rotation) * distance;

    return (dist(look_x, look_y, b.x_pos, b.y_pos) <= connect_snap_dist);
  }

  public void connect(Block block) {
    occupant = block;
    occupied = true;
    trackBlock(block);
    block.arrangeLeads(rotation);
  }

  public void disconnect() {
    occupant = null;
    occupied = false;
    distance = reg_distance;
  }

  void trackBlock(Block block) {                       
    rotation = atan2((block.y_pos - owner.y_pos), 
    (block.x_pos - owner.x_pos));
    distance = dist(block.x_pos, block.y_pos, owner.x_pos, owner.y_pos);
  }
  
  public void SetRotation(float rot){
    rotation = rot;
  }
}

class LeadOptions {
  public boolean visible = true;
  public PImage image;
  public int number = 0;
  public boolean showNumber = false;
  public boolean dashed = false;
  public float offset = 0;
  public color col = color(invertColor ? 255 : 0);
  public int weight = 3;
}

