color[] colorSet = new color[]
{
  color(52, 152, 219), //emerald green
  color(231, 76, 60), //alizarin red
  color(46, 204, 113), //peter river blue
  color(230, 126, 34), //carrot orange
  color(155, 89, 182) //amethyst
};


HashMap<Long, Block> blockMap;

void SetupBlockMap() {
  blockMap = new HashMap<Long, Block>();
}

HashMap<Long, Cursor> cursorMap;

void SetupCursorMap() {
  cursorMap = new HashMap<Long, Cursor>();
}

HashMap<Integer, Block> funcMap;

void SetupFuncMap() {
  funcMap = new HashMap<Integer, Block>();
}


HashMap<Integer, ClipInfo> clipDict;

void SetupClipDict() {
  clipDict = new HashMap<Integer, ClipInfo>();
/*
  clipDict.put(1, new ClipInfo("abstract/beep-1", 1));
  clipDict.put(2, new ClipInfo("abstract/beep-2", 1));
  clipDict.put(3, new ClipInfo("abstract/electronic-1", 1));
  clipDict.put(4, new ClipInfo("abstract/harp-1", 1));
  clipDict.put(5, new ClipInfo("abstract/harp-2", 2));
  clipDict.put(6, new ClipInfo("abstract/keyboard-1", 1));
  clipDict.put(7, new ClipInfo("abstract/keyboard-2", 1));
  clipDict.put(8, new ClipInfo("abstract/marimba-1", 1));

  clipDict.put(9, new ClipInfo("abstract/marimba-2", 1));
  clipDict.put(10, new ClipInfo("abstract/marimba-3", 1));
  clipDict.put(11, new ClipInfo("abstract/trill-1", 1));
*/
  clipDict.put(10, new ClipInfo("trad/bass-asc-progression", 1));
  clipDict.put(11, new ClipInfo("trad/bass-fx-slap", 1));
  clipDict.put(12, new ClipInfo("trad/bass-groovy", 1));
  
  
  clipDict.put(13, new ClipInfo("eightbit/eight-bit Analog Drum Loop-001", 1));

  clipDict.put(14, new ClipInfo("trad/bass-slappy", 1));
  clipDict.put(15, new ClipInfo("trad/bass-synthetic", 1));

  //EIGHTBIT Sounds
  clipDict.put(16, new ClipInfo("eightbit/eight-bit Atari Pad-004", 1));
  clipDict.put(17, new ClipInfo("eightbit/eight-bit Video Game Loop-003", 4));
  clipDict.put(18, new ClipInfo("eightbit/eight-bit Analog Drum Loop-015", 4));
  clipDict.put(19, new ClipInfo("eightbit/eight-bit Atari Bassline-003", 1));

  clipDict.put(20, new ClipInfo("eightbit/eight-bit Atari Lead-009", 1));
  clipDict.put(21, new ClipInfo("eightbit/eight-bit Atari Lead-011", 2));
  clipDict.put(22, new ClipInfo("eightbit/eight-bit Atari Lead-008", 3));
  clipDict.put(23, new ClipInfo("eightbit/eight-bit Atari Pad-003", 3));

  clipDict.put(40, new ClipInfo("kick_export", 0));
}


HashMap<Integer, Integer> idToEffect;

void SetupIdToEffect() {
  idToEffect = new HashMap<Integer, Integer>();
}



HashMap<Integer, BooleanBlock> boolMap;

void SetupBoolMap() {
  boolMap = new HashMap<Integer, BooleanBlock>();
  /*
  boolMap.put(100, false);
   boolMap.put(101, false);
   boolMap.put(102, false);
   boolMap.put(103, false);
   boolMap.put(104, false);
   boolMap.put(105, false);
   boolMap.put(106, false);
   boolMap.put(107, false);
   boolMap.put(108, false);
   boolMap.put(109, false);
   */
}

HashMap<Integer, BlockType> idToType;

void SetupIdToType() {
  idToType = new HashMap<Integer, BlockType>();

  //FUNCTION 0-4
  for (int i = 0; i < 5; i++) {
    idToType.put(i, BlockType.FUNCTION);
  }

  //CALL 5-9
  for (int i = 5; i < 10; i++) {
    idToType.put(i, BlockType.CALL);
  }
      idToType.put(122, BlockType.CALL);


  //CLIPS 10-39
  for (int i = 10; i < 40; i++) {
    idToType.put(i, BlockType.CLIP);
  }

  //BEATS 40
  //TODO change to whatever       
  idToType.put(40, BlockType.BEAT);


  //BOOLEANS 100-109
  for (int i = 100; i < 110; i++) {
    idToType.put(i, BlockType.BOOLEAN);
  }

  //CONDITIONALS 50-59
  for (int i = 50; i < 60; i++) {
    idToType.put(i, BlockType.CONDITIONAL);
  }

  //SPLIT 60
  idToType.put(60, BlockType.SPLIT);

  //LOOPS 61, 62
  idToType.put(121, BlockType.START_LOOP);
  idToType.put(61, BlockType.END_LOOP);


  
}

