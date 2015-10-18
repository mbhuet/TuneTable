class PlayHead{
  Block activeBlock;
  LinkedList travelledLeads;
  float leadDecayRate = .2f;
  color playColor;
  
  PlayHead(Block start, color c){
    playColor = c;
    activeBlock = start;
    activeBlock.Activate(this);
  }
  
  void travel(){
    int[] nextBlockIndices = activeBlock.getSuccessos();
    for(int i = 0; i<nextBlocks.length; i++){
      Block nextBlock = activeBlock.children[nextBlockIndices[i]];
      if (nextBlock != null){
        if (i > 0){
          PlayHead newPlay = new PlayHead(nextBlock, playColor);
        }
        else{
          activeBlock = nextBlock;
          nextBlock.Activate(this);
        }
      }
    }
  }
  
  void highlightLeads(){
    float totalDist = 0;
  }


}
