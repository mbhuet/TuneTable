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
    clip.pause();
    //println("rewind " + clip.position() + " at millis " + millis());
    
  }

  
}

