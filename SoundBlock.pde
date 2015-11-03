abstract class SoundBlock extends Block {
  boolean isPlaying = false;
  int startTime = 0;
  int playTimer = 0;
  boolean pie = true;

  Block previous;

  AudioPlayer clip;



  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    this.previous = previous;
    Play();
  }


  boolean isReadyToDie() {
    return (true);//!isPlaying); //new surface may have fixed problem of misidentification, if so, this is no longer necessary
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

  void drawArc(int radius, float percent) {
    pushMatrix();
    noStroke();
    fill(blockColor);
    translate(x_pos, y_pos);
    float arcRot = 0;
    if (previous != null) {
      arcRot = atan2((previous.y_pos - this.y_pos), 
      (previous.x_pos - this.x_pos));
    }
    rotate(arcRot); //should rotate such that the start angle points to the parent
    arc(0, 0, 
    block_diameter + radius, 
    block_diameter + radius, 
    0, 
    percent * 2 * PI, //(float)clip.position()/(float)clip.length() * 2*PI, 
    PIE);
    popMatrix();
  }

  void drawBeat(int radius) {
    pushMatrix();
    fill(blockColor);
    noStroke();
    translate(x_pos, y_pos);
    rotate(0); //should rotate such that the start angle points to the parent
    float beatSize = block_diameter * 1.25f * (1.0- .5f *(float)(clip.position()%255) / (float)255);
    ellipse(0, 0, beatSize, beatSize);
    popMatrix();
  }
}

