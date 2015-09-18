HashMap<Long, Block> blockMap;

void SetupBlockMap(){
  blockMap = new HashMap<Long, Block>();
  
}


HashMap<Integer, ClipInfo> clipDict;

void SetupClipDict(){
  clipDict = new HashMap<Integer, ClipInfo>();
  
  clipDict.put(1,  new ClipInfo("Bass1-Dip1-1Sec",      1));
  clipDict.put(2,  new ClipInfo("Bass1-Dip1-1Sec",      1));
  clipDict.put(3,  new ClipInfo("Bass1-Fall1-1Sec",     1));
  clipDict.put(4,  new ClipInfo("Bass1-Hold1-1Sec",     1));
  clipDict.put(5,  new ClipInfo("Bass1-Hold1-2Sec",     2));
  clipDict.put(6,  new ClipInfo("Bass1-Hold2-1Sec",     1));
  clipDict.put(7,  new ClipInfo("Bass1-Jump1-1Sec",     1));
  clipDict.put(8,  new ClipInfo("Bass1-Rise1-1Sec",     1));
  
  clipDict.put(9,  new ClipInfo("Bass2-DipJump1-1Sec",  1));
  clipDict.put(10, new ClipInfo("Bass2-DipJump2-1Sec",  1));
  clipDict.put(11, new ClipInfo("Bass2-DipJump3-1Sec",  1));
  clipDict.put(12, new ClipInfo("Bass2-Fall1-1Sec",     1));
  clipDict.put(13, new ClipInfo("Bass2-Hold1-1Sec",     1));
  clipDict.put(14, new ClipInfo("Bass2-Hold1-2Sec",     1));
  clipDict.put(15, new ClipInfo("Bass2-Hold2-1Sec",     1));
  
  clipDict.put(16, new ClipInfo("Bell1-Hold1-1Sec",     1));
  clipDict.put(17, new ClipInfo("Bell1-Rise1-1Sec",     1));
  
  clipDict.put(18, new ClipInfo("Bell2-Hold1-1Sec",     1));
  clipDict.put(19, new ClipInfo("Bell2-Hold1-4Sec",     4));
  clipDict.put(20, new ClipInfo("Bell2-Hold2-4Sec",     4));
  clipDict.put(21, new ClipInfo("Bell2-Kill-1Sec",      1));
  
  clipDict.put(22, new ClipInfo("Brass1-Attack1-1Sec",  1));
  clipDict.put(23, new ClipInfo("Brass1-Attack1-2Sec",  2));
  clipDict.put(24, new ClipInfo("Brass1-Attack1-3Sec",  3));
  clipDict.put(25, new ClipInfo("Brass1-Attack2-1Sec",  1));
  clipDict.put(26, new ClipInfo("Brass1-Attack2-2Sec",  2));
  clipDict.put(27, new ClipInfo("Brass1-Attack2-3Sec",  3));
  clipDict.put(28, new ClipInfo("Brass1-Bump1-1Sec",    1));
  clipDict.put(29, new ClipInfo("Brass1-Hold1-1Sec",    1));
  clipDict.put(30, new ClipInfo("Brass1-Hold1-2Sec",    2));
  clipDict.put(31, new ClipInfo("Brass1-Hold2-1Sec",    1));
  clipDict.put(32, new ClipInfo("Brass1-Hold2-2Sec",    2));
  clipDict.put(33, new ClipInfo("Brass1-Jump1-1Sec",    1));
  
  clipDict.put(34, new ClipInfo("Clap1-Begin-1Sec",     1));
  clipDict.put(35, new ClipInfo("Clap1-Middle-1Sec",    1));
  
  clipDict.put(36, new ClipInfo("Crash1-Hold1-2Sec",    2));
  
  clipDict.put(37, new ClipInfo("Drumpad1-Hold1-1Sec",  1));
  clipDict.put(38, new ClipInfo("Drumpad1-Hold1-2Sec",  2));
  clipDict.put(39, new ClipInfo("Drumpad1-Hold1-3Sec",  3));
  clipDict.put(40, new ClipInfo("Drumpad1-Hold1-4Sec",  4));
  clipDict.put(41, new ClipInfo("Drumpad1-Triple1-1Sec",1));
  clipDict.put(42, new ClipInfo("Drumpad1-Triple2-1Sec",1));
  
  clipDict.put(43, new ClipInfo("Electro1-Hold1-1Sec",  1));
  clipDict.put(44, new ClipInfo("Electro1-Hold1-2Sec",  2));
  clipDict.put(45, new ClipInfo("Electro1-Hold1-3Sec",  3));
  
  clipDict.put(46, new ClipInfo("Electro2-Hold1-1Sec",  1));
  clipDict.put(47, new ClipInfo("Electro2-Hold1-2Sec",  2));
  clipDict.put(48, new ClipInfo("Electro2-Hold1-3Sec",  3));
  clipDict.put(49, new ClipInfo("Electro2-Hold1-4Sec",  4));
  
  clipDict.put(50, new ClipInfo("FX1-Hold1-1Sec",       1));
  
  clipDict.put(51, new ClipInfo("FXBuild1-Hold1-1Sec", 1));
  clipDict.put(52, new ClipInfo("FXBuild1-Hold1-2Sec", 2));
  clipDict.put(53, new ClipInfo("FXBuild1-Hold1-3Sec", 3));
  
  clipDict.put(54, new ClipInfo("HiHats1-Hold1-1Sec", 1));
  clipDict.put(55, new ClipInfo("HiHats1-Hold1-2Sec", 2));
  
  clipDict.put(56, new ClipInfo("Percussion1-Hold1-2Second", 2));
  clipDict.put(57, new ClipInfo("Percussion1-Hold2-3Second", 3));
  
  clipDict.put(58, new ClipInfo("Percussion2-Double1-1Second", 1));
  clipDict.put(59, new ClipInfo("Percussion2-Double1-2Second", 2));
  clipDict.put(60, new ClipInfo("Percussion2-Double2-1Second", 1));
  clipDict.put(61, new ClipInfo("Percussion2-Hold1-1Second", 1));
  clipDict.put(62, new ClipInfo("Percussion3-Double1-1Second", 1));
  clipDict.put(63, new ClipInfo("Percussion3-Hold1-1Second", 1));
  clipDict.put(64, new ClipInfo("Scify1-End1-1Seconds", 1));
  clipDict.put(65, new ClipInfo("Scify1-Hold1-2Seconds", 2));
  clipDict.put(66, new ClipInfo("Scify1-Hold1-3Seconds", 3));
  clipDict.put(67, new ClipInfo("Scify1-Hold1-4Seconds", 4));
  clipDict.put(68, new ClipInfo("Scify1-Rise1-1Seconds", 1));

}


HashMap<Integer, Integer> idToEffect;

void SetupIdToEffect(){
  idToEffect = new HashMap<Integer, Integer>();
}



HashMap<Integer, Integer> idToArg;

void SetupIdToArg(){
  idToArg = new HashMap<Integer, Integer>();
  idToArg.put(100, 0);
  idToArg.put(101, 1);
  idToArg.put(102, 2);
  idToArg.put(103, 3);
  idToArg.put(104, 4);
  idToArg.put(105, 5);
  idToArg.put(106, 6);
  idToArg.put(107, 7);
  idToArg.put(108, 8);
  idToArg.put(109, 9);
  idToArg.put(110, 10);
  
}

HashMap<Integer, BlockType> idToType;

void SetupIdToType(){
  idToType = new HashMap<Integer, BlockType>();
  
  //PLAY
  idToType.put(0, BlockType.FUNCTION);
  
  //CLIPS
  for(int i = 1; i < 100; i++){
    idToType.put(i, BlockType.CLIP);
  }
  
  //LOOPS
  idToType.put(111, BlockType.COUNTDOWN);
  idToType.put(112, BlockType.CONDITIONAL);
  idToType.put(113, BlockType.BOOLEAN);
  
}
