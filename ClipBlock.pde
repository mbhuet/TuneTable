class ClipBlock extends SoundBlock {

  ClipBlock(TuioObject tObj) {
    Init(tObj, 1);
  }

  ClipBlock(int x, int y, int id) {
    Init(1, x, y, id);
  }

  void Setup() {
    LoadClip();
  }
  void Update() {
    //println("begin clip update " + this + " playHead " + (playHead == null ? "null" : playHead.toString()));
    super.Update();
    leadsActive = inChain;

    if (isPlaying) {

      if (pie) {
        float arcRot = 0;
        if (previous != null) {
          arcRot = atan2((previous.y_pos - this.y_pos), 
          (previous.x_pos - this.x_pos));
        }
        drawArc((int)(block_diameter * .4), (float)clip.position()/(float)clip.length(), arcRot);
      } else { 
        float beatRadius = block_diameter * 1.25f * (1.0- .5f *(float)(clip.position()%255) / (float)255);

        drawBeat((int)(beatRadius));
      }
      playTimer += millis() - startTime;
      if (clip.position() >= clip.length()) {
        Stop();
        finish();
      }
    }
    
        //println("end clip update " + this + " playHead " + (playHead == null ? "null" : playHead.toString()));

  }


  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    
    //println("clip activate playHead = " + ((playHead == null)? "null" : playHead.toString()) );
  }

  public int[] getSuccessors() {
    return new int[] {
      0
    };
  }

  void OnRemove() {
    super.OnRemove();
  
}

void Die() {
  super.Die();
  clip.close();
  if (playHead != null) {  
    //println("block " + this + " has been removed, killing its playhead " + playHead);
    playHead.dead = true;
  }
}
}
