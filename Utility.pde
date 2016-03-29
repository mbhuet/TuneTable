
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

public void SaveData(){
  PrintWriter output;

    output = createWriter("logs/" + month() + "-" + day() + "_" + hour() + "_" + minute() + ".txt"); 

    HashMap<BlockType, Integer> blockCount = new HashMap<BlockType, Integer>();
    
    /*
    for(Chain c : allChains){
        for(Block b : c.blocks){
            if (blockCount.containsKey(b.type)) {
              blockCount.put(b.type, blockCount.get(b.type)+1);
            }
            else{
              blockCount.put(b.type, 1);
            }
        }
    }
    
    Iterator it = blockCount.entrySet().iterator();
    while (it.hasNext()) {
        Map.Entry pair = (Map.Entry)it.next();
        output.println(pair.getKey() + " " + pair.getValue());
        it.remove(); // avoids a ConcurrentModificationException
    }
    */
    
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
}

public static PVector convertFromPolar(PVector pos, float rot, float dist){
  return new PVector(pos.x + cos(rot) * dist, 
                     pos.y + sin(rot) * dist);
}


