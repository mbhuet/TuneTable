class BeatBlock extends SoundBlock {
  int buttonSize = block_diameter/6;
  int buttonDist;
  String beatString = "";
  
  int clipStartTime = 0;
  int beatCount = 0;
  int beatTimer = 0; //used to time the current beat sound
  int totalLength = millisPerBeat * beatsPerMeasure; //this block will be one measures
  int beatLength;
  
  boolean pie = true;

  BeatButton[] buttons;
  int numBeats = 8;

  BeatBlock(TuioObject tObj) {
    Init(tObj, 0);
  }

  BeatBlock(int x, int y) {
    Init(0, x, y, 62);
  }

  void Setup() {
    canBeChained = false;
    LoadClip();
    buttons = new BeatButton[numBeats];
    for (int i = 0; i<numBeats; i++) {
      buttons[i] = new BeatButton(this, i, 0, 0, 0, buttonSize);
      beatString += "-";
    }
    buttonDist = block_diameter/2 + buttonSize;
    beatLength = millisPerBeat * beatsPerMeasure / numBeats;// millisPerBeat * 4 / 8,
    arrangeButtons(rotation);

    BeginPlaying();
  }

  void Update() {

    super.Update();
    if (isPlaying) {
      beatCount = millis()/(beatLength)%numBeats;
      playTimer = millis()%(totalLength);
      

      if (pie)drawArc((int)(block_diameter * .5), (float)playTimer/(float)totalLength, rotation);
      //else drawBeat((int)(block_diameter * .5));
      
      if (millis() - clipStartTime >= beatLength) {
          if(beatString.charAt(beatCount) == '0' ||
              beatString.charAt(beatCount) == '+')
          PlayBeat();
        
      }
    }

   drawBridges();
  }
  
  public void UpdatePosition() {
    super.UpdatePosition();
    arrangeButtons(rotation);

  }


  public void Activate(PlayHead play, Block previous) {
    super.Activate(play, previous);
    this.previous = previous;
    Play();
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
    for(int i = 0; i<numBeats; i++){
      buttons[i].Destroy();
      buttons[i] = null;
    }
  }

  boolean isReadyToDie() {
    return (true);
  }

  void arrangeButtons(float startAngle) {
    for (int i = 0; i<numBeats; i++) {
      buttons[i].Update((int)(x_pos + cos(startAngle + i * 2*PI/numBeats) * buttonDist), (int)(y_pos + sin(startAngle + i * 2*PI/numBeats) * buttonDist), i*2*PI/numBeats);
    }
  }

  void drawBridge(int afterIndex) {
    noFill();
    strokeWeight(buttonSize);
    strokeCap(ROUND);
    stroke(invertColor ? 255 : 0);
    float startRot = rotation + afterIndex * 2*PI/numBeats;
    arc(x_pos, y_pos, buttonDist *2, buttonDist * 2, startRot, startRot + 2*PI/numBeats);
  }

  public void drawBridges() {
    for (int i = 1; i<numBeats; i++) {
      if (beatString.charAt(i) == '+') drawBridge(i-1);
    }
  }

  void drawShadow() {
      shapeMode(CORNER);

    beatShadow.setFill(blockColor);
    pushMatrix();
    translate(x_pos, y_pos);
    rotate(rotation);
    fill(color(255,0,0));
    ellipse(0,0,10,10);
    shape(beatShadow);
    popMatrix();
  }


  void PlayBeat() {
    clip.cue(millis() % (beatLength));
    clip.play();
    clipStartTime = millis() - (millis() % (beatLength));
  }
  
  void BeginPlaying(){
    beatCount = 0;
    isPlaying = true;
    PlayBeat();
  }

  void flipBeat(int i, Cursor cursor) {
    //should keep track of this cursor's history somehow for dragging
    buttons[i].isOn = !buttons[i].isOn;
    char cur = buttons[i].isOn ? '0' : '-';
    setBeat(i, cur);
    if (cur == '-' && beatString.length() > i+1 && beatString.charAt(i+1) == '+') setBeat(i+1, '0');
  }

  void setBeat(int i, char beat) {
    beatString = beatString.substring(0, i)+beat+beatString.substring(i+1);
  }
}

class BeatButton extends Button {
  BeatBlock block;
  int index;
  boolean isOn;

  BeatButton(BeatBlock b, int i, int x_pos, int y_pos, float rot, float rad) {
    InitButton(x_pos, y_pos, rot, rad);
    index = i;
    block = b;
    isOn = false;
  }
  public void Trigger(Cursor cursor) {
    //the first time a cursor touches a beatbutton, it should record the new state of that button and set all others it touches to that 
    block.flipBeat(index, cursor);
    if (cursor.beatHistory.size() > 0) {
      BeatButton last = cursor.beatHistory.get(cursor.beatHistory.size()-1);
      if (last.block == this.block) {
        if (last.index == this.index -1) {
          if (last.isOn && this.isOn) {
            block.setBeat(this.index, '+');
          }
        } else if (last.index == this.index + 1) {
          if (last.isOn && this.isOn) {
            block.setBeat(last.index, '+');
          }
        }
      }
    }
  }
  public void drawButton() {
    strokeWeight(3);

    if (isOn) {
      fill(color(invertColor ? 255 : 0));
      stroke(color(invertColor ? 0 : 255));
    } else {
      fill(color(invertColor ? 0 : 255));
      stroke(color(invertColor ? 255 : 0));
    }
    ellipse(x, y, size*2, size*2);
  }
}

