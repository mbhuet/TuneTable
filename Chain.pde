class Chain {

  int numBlocks;
  Block head;
  LinkedList<Block> blocks;
  boolean valid;
  float total_length;

  //good for making fake chains for debugging
  Chain(Block[] b) {
    int x_offset = 0;
    blocks = new LinkedList<Block>();
    for (int i = 0; i< b.length; i++) {
      b[i].x_pos+=x_offset;
            x_offset+=b[i].block_width + 2;
            if (b[i].requiresArgument()){
            b[i].PlaceButtons();
            }

      blocks.add(b[i]);
    }
    numBlocks = b.length;
    valid = isValid();
  }

  Chain(Block head) {
    this.head = head;
    BuildChain();
  }

  public void drawChain() {
    //println("here");



    if (valid) {
      fill(0, 255, 0); //GREEN
    } else {
      fill(255, 0, 0); //RED
    }

    /*
    translate(blocks.get(0).x_pos, blocks.get(0).y_pos);
     rotate(blocks.get(0).rotation);
     translate(-obj_size/2, -obj_size/2);
     rect(0, 0, total_length, obj_size);
     */


    if (valid) {
      stroke(0, 255, 0); //GREEN
    } else {
      stroke(255, 0, 0); //RED
    }
    strokeWeight(block_height * 1.3);
    strokeCap(PROJECT);

    if ((numBlocks != blocks.size())) {
      //println(numBlocks + ", " + blocks.size());
    }

    line(head.x_pos, head.y_pos, blocks.get(numBlocks-1).x_pos, blocks.get(numBlocks-1).y_pos);
     
         strokeWeight(0);
  
        

  }


  boolean isValid() {
    if (blocks.size() <= 1) return false;
    int loop_starts = 0;
    int loop_ends = 0;
    for (Block b : blocks) {
      if (b.type == BlockType.START_LOOP) loop_starts ++;
      if (b.type == BlockType.END_LOOP) loop_ends ++;
      
    }
    //if (loop_starts != loop_ends) return false;
    return true;
  }


  public boolean containsBlock(Block b) {
    return blocks.contains(b);
  }


  public void Remove(Block b) {
    BuildChain();
  }


  void BuildChain() {
    blocks = new LinkedList<Block>();
    blocks.add(head);
    Block cur = head;

    int iter = 0;
    while (cur.right_neighbor != null) {
      cur = cur.right_neighbor;
      //println(cur);
      blocks.add(cur);
      iter++;
      if (iter > 10) {
        //println(cur + " " + cur.right_neighbor);
        break;
      }
    }

    numBlocks = blocks.size();
    valid = isValid();

    //println(numBlocks);
  }


  Block getBlock(int i) {
    if (i >= numBlocks) {
      return null;
    }
    return blocks.get(i);
  }
}

