public void dashedCircle(int x, int y, int radius, int numDashes){
  noFill();
  for(int i = 0; i < numDashes; i++){
      arc(x, y, radius, radius, (i + .3) * (2*PI)/numDashes, (i + 1 - .3) * (2*PI) / numDashes);
  }
}
