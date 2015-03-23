class Chain {

  int numBlocks;
  Block head;
  LinkedList<Block> blocks;
  boolean valid;
  float total_length;

  //good for making fake chains for debugging
  Chain(Block[] b) {
    blocks = new LinkedList<Block>();
    for (int i = 0; i< b.length; i++) {
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


    pushMatrix();

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
    popMatrix();


    if (valid) {
      stroke(0, 255, 0); //GREEN
    } else {
      stroke(255, 0, 0); //RED
    }
    strokeWeight(block_height * 1.3);
    strokeCap(PROJECT);

    if ((numBlocks != blocks.size())) {
      println(numBlocks + ", " + blocks.size());
    }

    line(head.x_pos, head.y_pos, blocks.get(numBlocks-1).x_pos, blocks.get(numBlocks-1).y_pos);
  }


  boolean isValid() {
    if (blocks.size() <= 1) return false;

    for (Block b : blocks) {
      if (b.requiresArgument() && b.parameter == -1) {
        //return false;
      }
    }
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
        println(cur + " " + cur.right_neighbor);
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

