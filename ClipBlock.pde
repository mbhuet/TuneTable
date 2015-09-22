class ClipBlock extends Block {
  AudioPlayer clip;
  int clip_length; //in millis
  int playTimer = 0;
  int startTime = 0;
  boolean isPlaying = false;

  ClipBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  void Setup() {
    LoadClip();
  }
  void Update() {
    super.Update();
    if (isPlaying) {
      playTimer += millis() - startTime;
      if (playTimer >= clip_length) {
        Stop();
        if (children[0] != null)
          children[0].Activate();
      }
    }
  }

  void Activate() {
    Play();
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
      clip_length = clip.length();
    } else {
      println("No clip found for " + sym_id + ": Possible typo");
    }
  }

  void Play() {
    playTimer = 0;
    isPlaying = true;
    clip.play();
    startTime = millis();
  }

  void Stop() {
    playTimer = 0;
    isPlaying = false;
    clip.rewind();
  }
}

