class ClipBlock extends Block {
  AudioPlayer clip;
  int playTimer = 0;
  int startTime = 0;
  boolean isPlaying = false;
  boolean pie = true;
  
  Block previous;

  ClipBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  void Setup() {
    LoadClip();
  }
  void Update() {
    super.Update();
    leadsActive =  (parents.size() > 0) ? true : false;
    //println("---"+clip.position());
    if (isPlaying) {
      //println(clip.isPlaying() + " at " + clip.position() + " / " + clip.length());
      if(pie)drawArc();
      else drawBeat();
      playTimer += millis() - startTime;
      if (clip.position() >= clip.length()) {
        //println("reached end " + clip.length());
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
      //println(clip_length);
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
    //println(clip.isPlaying() +" play " + clip.length() + " at millis " + millis());

  }

  void Stop() {
    //println("stop " + clip.position() + " at millis " + millis());
    playTimer = 0;
    isPlaying = false;
    clip.rewind();
    //println("rewind " + clip.position() + " at millis " + millis());
    finish();
  }
  
  void drawArc(){
    pushMatrix();
    noStroke();
    fill(0, 102, 153);
    translate(x_pos, y_pos);
    float arcRot = 0;
    if (previous != null){
    arcRot = atan2((previous.y_pos - this.y_pos) ,
                    (previous.x_pos - this.x_pos));
    }
    rotate(arcRot); //should rotate such that the start angle points to the parent
    arc(0, 0, block_diameter * 1.25f, block_diameter * 1.25f, 0, (float)clip.position()/(float)clip.length() * 2*PI, PIE);
    popMatrix();

  }
  
  void drawBeat(){
    pushMatrix();
    fill(0, 102, 153);
    noStroke();
    translate(x_pos, y_pos);
    rotate(0); //should rotate such that the start angle points to the parent
    //arc(0, 0, block_diameter * 1.25f, block_diameter * 1.25f, 0, (float)clip.position()/(float)clip.length() * 2*PI, PIE);
    float beatSize = block_diameter * 1.25f * (1.0- .5f *(float)(clip.position()%255) / (float)255);
    ellipse(0, 0, beatSize, beatSize);
    popMatrix();
  }
}
