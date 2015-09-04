
public void Tooltip(String[] info){
  int textSize = 12;
  textSize(textSize);
  int boxHeight = (info.length + 2) * textSize;
  int boxWidth = textSize;
  
  for(int s = 0; s<info.length; s++){
    boxWidth = max(boxWidth, (int)textWidth(info[s]) + textSize * 2);
  }
  
  stroke(0);
  strokeWeight(1);
  strokeCap(PROJECT);

  fill(255);
  rectMode(CORNER);
  pushMatrix();
  translate((mouseX + boxWidth >= width ? mouseX-boxWidth : mouseX), (mouseY - boxHeight <= 0 ? mouseY : mouseY-boxHeight));
  rect(0, 0, boxWidth, boxHeight);
  
  textAlign(LEFT, TOP);
  fill(0);

  for(int i = 0; i<info.length; i++){
    
    translate(0,textSize);
    text(info[i],textSize,0);
  }
  
  popMatrix();
  
}
