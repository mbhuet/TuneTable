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

HashMap<Integer, FunctionBlock> funcMap;

void SetupFuncMap() {
  funcMap = new HashMap<Integer, FunctionBlock>();
}


HashMap<Integer, String[]> clipDict;

void SetupClipDict() {
  clipDict = new HashMap<Integer, String[]>();
  
  clipDict.put(10, new String[] {
    "eightbit/1_eight-bit Atari Pad-001", 
    "eightbit/1_eight-bit Atari SineDot-002", 
    "eightbit/1_eight-bit Atari SineDot-003"
  });
  
  clipDict.put(11, new String[] {
    "eightbit/2_eight-bit Atari Lead-004", 
    "eightbit/2_eight-bit Atari Pad-002", 
    "eightbit/2_eight-bit Atari Pad-003"
  });
  clipDict.put(12, new String[] {
    "eightbit/3_eight-bit Atari Lead-010", 
    "eightbit/3_eight-bit Atari Synth-001", 
    "eightbit/3_eight-bit Atari Synth-002"
  });
  clipDict.put(13, new String[] {
    "eightbit/4_eight-bit Atari Bassline-003", 
    "eightbit/4_eight-bit Atari Bassline-004", 
    "eightbit/4_eight-bit Atari Bassline-005"
  });
  clipDict.put(14, new String[] {
    "eightbit/5_eight-bit Atari Lead-008", 
    "eightbit/5_eight-bit Atari Lead-009", 
    "eightbit/5_eight-bit Atari Lead-011"
  });
  clipDict.put(15, new String[] {
    "eightbit/6_eight-bit Atari Lead-003", 
    "eightbit/6_eight-bit Atari Pad-004", 
    "eightbit/6_eight-bit Atari Synth-003"
  });
  
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

  //BEATS 40-45
  for (int i = 40; i < 46; i++) {
    idToType.put(i, BlockType.BEAT);
  }

  //CONDITIONALS 50-59
  for (int i = 50; i < 60; i++) {
    idToType.put(i, BlockType.CONDITIONAL);
  }
      idToType.put(110, BlockType.CONDITIONAL);


  //SPLIT 60
  idToType.put(60, BlockType.SPLIT);
    idToType.put(120, BlockType.SPLIT);


  //LOOPS 61, 62
  idToType.put(121, BlockType.START_LOOP);
  idToType.put(61, BlockType.END_LOOP);


  //BOOLEANS 100-109
  for (int i = 100; i < 110; i++) {
    idToType.put(i, BlockType.BOOLEAN);
  }
}

