abstract class SoundBlock extends Block {
  boolean isPlaying = false;
  int startTime = 0;
  int playTimer = 0;
  boolean pie = true;

  Block previous;

  AudioPlayer[] clips;

  int activeClip = 0;



  public void Activate(PlayHead play, Block previous) {
    if (playHead != null) {
      playHead.Die();
    }
    super.Activate(play, previous);
    this.previous = previous;
    Play();
  }


  boolean isReadyToDie() {
    return (true);//!isPlaying); //new surface may have fixed problem of misidentification, if so, this is no longer necessary
  }


  void LoadClips() {
    int clips_id = sym_id < 40 ? sym_id%6+10 : sym_id;
    if (!clipDict.containsKey(clips_id)) {
      println("No clip found for " + clips_id + ": Possible typo");
      clips_id = 10;
    }
    String[] fileNames =  clipDict.get(clips_id);
    clips = new AudioPlayer[fileNames.length];
    for (int i = 0; i< fileNames.length; i++) {
      LoadClip(i, fileNames[i]);
    }
  }


  void LoadClip(int i, String fileName) {
    //println("loadClip " + fileName);
    clips[i] = minim.loadFile("clips/"+fileName+".wav");
    clips[i].rewind();
  }

  void CloseClips() {
    for (AudioPlayer clip : clips) {
      clip.close();
    }
  }

  void SwitchClip(int nextActiveClip) {
    if (isPlaying) {
      int pos = clips[activeClip].position();
      clips[activeClip].rewind();
      clips[activeClip].pause();
      clips[nextActiveClip].play(pos);
    }
    activeClip = nextActiveClip;
  }

  void Play() {
    playTimer = 0;
    isPlaying = true;
    clips[activeClip].cue(millis() % millisPerBeat);
    clips[activeClip].play();
    startTime = millis();
  }

  void Stop() {
    playTimer = 0;
    isPlaying = false;
    clips[activeClip].rewind();
    clips[activeClip].pause();
  }

  void Die() {
    super.Die();
    CloseClips();
  }
}

