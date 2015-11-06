class ClipBlock extends SoundBlock {

  ClipBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  void Setup() {
    LoadClip();
  }
  void Update() {
    super.Update();
    leadsActive = inChain;
    if (isPlaying) {
      if(pie)drawArc((int)(block_diameter * .25), (float)clip.position()/(float)clip.length());
      else drawBeat((int)(block_diameter * .25));
      playTimer += millis() - startTime;
      if (clip.position() >= clip.length()) {
        Stop();
        }
      }
    }
  

  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    this.previous = previous;
    Play();
  }
     
  public int[] getSuccessors(){
    return new int[]{0};
  }

  void OnRemove() {
        super.OnRemove();
  }
  
  void Die(){
    super.Die();
        clip.close();

  }
  
  boolean isReadyToDie(){
    return (!isPlaying);
  }
  

  void LoadClip() {
    if (clipDict.containsKey(sym_id)) {
      ClipInfo info =  clipDict.get(sym_id);
      String clip_name = info.name;
      clip = minim.loadFile("clips/"+clip_name+".wav");
      clip.rewind();
    } else {
      println("No clip found for " + sym_id + ": Possible typo");
      ClipInfo info =  clipDict.get(1);
      String clip_name = info.name;
      clip = minim.loadFile("clips/"+clip_name+".wav");
      clip.rewind();
    }
  }

  void Play() {
    playTimer = 0;
    isPlaying = true;
    clip.cue(millis() % millisPerBeat);
    clip.play();
    startTime = millis();

  }

}
