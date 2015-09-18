class ClipBlock extends Block{
    AudioPlayer clip;
    float clip_length;

  ClipBlock(TuioObject tObj){
    Init(tObj, 1);
  }

  void Setup(){}
  void Update(){}
  void Activate(){}
  
    void OnRemove(){
      clip.close();
    }
    
    void LoadClip() {
    if (clipDict.containsKey(sym_id)) {
      ClipInfo info =  clipDict.get(sym_id);
      String clip_name = info.name;
      clip = minim.loadFile("clips/"+clip_name+".wav");
      clip_length = info.length;
    } else {
      // println("No clip found for " + id + ": Possible typo");
    }
  }
}
