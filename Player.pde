class Player {
  boolean isPlaying;

  int[] changeTimes; //tracks when each chain will need to play the next clip
  int[] playIndices; //tracks which Block in the chain is currently playing
  boolean[] finished; //tracks lists that have finished playing

  int startTime;


  List<Block>[] blockLists;

  Player() {
    isPlaying = false;
  }



  void PlayLists(List<Block>[] lists) {
    isPlaying = true;
    startTime = millis();
    changeTimes = new int[lists.length];
    playIndices = new int[lists.length];
    finished = new boolean[lists.length];
    blockLists = lists;

    Start();
    //Update();
  }
  
  boolean IsFinished(){
    for(boolean b : finished){
      if (!b) return false;
    }
    return true;
  }
  
  
  void Start(){
    for (int i = 0; i<blockLists.length; i++) {
      if (blockLists[i].get(0).parameter == 0){
        
      }
      else{
      changeTimes[i] = 1000;
      blockLists[i].get(0).DecrementDisplayedArgument();
      }
         
    }
  }


  void Update() {
    int runningTime = millis()-startTime;
    //println("updating " + runningTime);
    
    int numBars = floor(((runningTime%1000)/1000.0) * 4) + 1;
    //println(numBars);
    
    for (int i = 0; i<blockLists.length; i++) {
      for(int l = 0; l < playIndices[i]; l++){
          blockLists[i].get(l).Highlight(4, false);
      }
      
      
      if (!finished[i]) {
          blockLists[i].get(playIndices[i]).Highlight(numBars, true);
      }
      
      if (finished[i]){
        //maybe show some effect?
      } else if (runningTime >= changeTimes[i]) {//need to move to the next clip in this list
        if (playIndices[i] >= blockLists[i].size()-1) { //this list has finished playing
          finished[i] = true;
        } else {
          playIndices[i]++;

          Block next = blockLists[i].get(playIndices[i]);
          //next.Highlight(numBars, true);
         
          switch(next.type) {

          case PLAY:
            changeTimes[i] = runningTime + 1000;
            next.DecrementDisplayedArgument();
            break;

          case CLIP:
            //println(next.id);
            next.clip.rewind();
            next.clip.play();
            changeTimes[i] = runningTime + next.clip_length * 1000;//next.clip.length();
            //println("playing " + next.id + " length: " + next.clip.length());
            break;

          case EFFECT:
            break;

          case SILENCE:
             next.DecrementDisplayedArgument();
             changeTimes[i] = runningTime + 1000;

            break;
            
          case START_LOOP:
            next.DecrementDisplayedArgument();
          break;
          
          case END_LOOP:
          break;

          default:
            break;
          };
        }
      }
    }
    
    if (IsFinished()){
      isPlaying =false;
      for (Block b : allBlocks) {
    b.OnEndPlay();
  }
    }
  }
}

