class ClipBlock extends Block {
  AudioPlayer clip;
  int playTimer = 0;
  int startTime = 0;
  boolean isPlaying = false;
  
  boolean pie = true;

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
      if(pie)drawArc();
      else drawBeat();
      playTimer += millis() - startTime;
      if (clip.position() >= clip.length()) {
        //println("reached end " + playTimer + " / " + clip_length);
        Stop();
        }
      }
    }
  

  void Activate(PlayHead play){
    super.Activate(play);
    Play();
  }
  
  public int[] getSuccessors(){
    return new int[]{0};
  }

  void OnRemove() {
        super.OnRemove();

    clip.close();
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
    }
  }

  void Play() {
    //println("play " + clip.position() + " at millis " + millis());
    playTimer = 0;
    isPlaying = true;
    clip.play();
    startTime = millis();
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
    fill(0, 102, 153);
    noStroke();
    translate(x_pos, y_pos);
    rotate(0); //should rotate such that the start angle points to the parent
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
