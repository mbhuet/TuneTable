public void dashedCircle(int x, int y, int radius, int numDashes) {
  noFill();
  for (int i = 0; i < numDashes; i++) {
    arc(x, y, radius, radius, (i + .3) * (2*PI)/numDashes, (i + 1 - .3) * (2*PI) / numDashes);
  }
}

public void dashedLine(int x1, int y1, int x2, int y2, float offset) {
  int lineLength = block_diameter/4;
  int gapLength = lineLength/2;

  float distance = dist(x1, y1, x2, y2);
  float rotation = atan2((y2 - y1), 
  (x2 - x1));
  int position = 0;
  strokeCap(ROUND);

  pushMatrix();

  translate(x1, y1);
  rotate(rotation);

  int unitLength = lineLength + gapLength;
  float offsetLength = unitLength * offset;

  float lineOffset = min(lineLength, offsetLength);
  float gapOffset = max(0, (offsetLength - lineLength));

  line(0, 0, lineOffset, 0);
  position+=lineOffset;
  translate(lineOffset, 0);

  //stroke(255);
  //line(0, 0, gapOffset, 0);
  position+=gapOffset;
  translate(gapOffset, 0);

  while (position < distance) {
    line(0, 0, min(distance-position, lineLength), 0);
    position+=lineLength;
    translate(lineLength, 0);

    //stroke(255);
    //line(0, 0, gapLength, 0);
    position+=gapLength;
    translate(gapLength, 0);
  }

  popMatrix();
}

PShape sinCircle(int x, int y, int radius, float rotation, int numLumps, float amplitude) {
  PShape shape = createShape();
  float angle = 0;
  float angleStep = PI/(4*numLumps);
  float freq = numLumps;
  float amp = amplitude;
  float dx, dy;  
  shape.beginShape();
  
  while (angle <= 2*PI) {
    float localAmp = cos(angle * freq + PI) * amp;
    dx = x + (radius + localAmp) * cos(angle);
    dy = y + (radius + localAmp) * sin(angle);

    angle += angleStep;

    shape.curveVertex(dx, dy);
  }
    shape.endShape(CLOSE);
    return shape;
}

//TAKES A LOT OF PROCESSING POWER
void radialGradient(float x, float y, int radius, color innerColor, color outerColor) {
  float inter = 1;
  for (int r = radius; r > 0; --r) {
    inter = (float)r/(float)radius;
    noStroke();
    fill(lerpColor(outerColor, innerColor, inter));
    ellipse(x, y, r*2, r*2);
  }
}

