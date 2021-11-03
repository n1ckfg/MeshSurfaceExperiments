class Stroke {
  
  ArrayList<PVector> points;
  PShape ps;
  int smoothReps = 10;
  int splitReps = 2;
  float rdpEpsilon = 0.5;
  
  Stroke(ArrayList<PVector> _points) {
    points = _points;
    ps = createShape();
    ps.beginShape();
    ps.stroke(randomCol());
    ps.strokeWeight(2);
    ps.noFill();
    for (PVector point : points) {
      ps.vertex(point.x, point.y, point.z);
    }
    ps.endShape();
  }
  
  color randomCol() {
    return color(127 + random(127), 127 + random(127), 127 + random(127));
  }
  
    void smoothStroke() {
    float weight = 18;
    float scale = 1.0 / (weight + 2);
    int nPointsMinusTwo = points.size() - 2;
    PVector lower, upper, center;

    for (int i = 1; i < nPointsMinusTwo; i++) {
      lower = points.get(i-1);
      center = points.get(i);
      upper = points.get(i+1);

      center.x = (lower.x + weight * center.x + upper.x) * scale;
      center.y = (lower.y + weight * center.y + upper.y) * scale;
    }
  }

  void splitStroke() {
    for (int i = 1; i < points.size(); i+=2) {
      PVector center = points.get(i);
      PVector lower = points.get(i-1);
      float x = (center.x + lower.x) / 2;
      float y = (center.y + lower.y) / 2;
      float z = (center.z + lower.z) / 2;
      PVector p = new PVector(x, y, z);
      points.add(i, p);
    }
  }

  void refine() {
    for (int i=0; i<splitReps; i++) {
      splitStroke();  
      smoothStroke();  
    }

    points = rdp.douglasPeucker(points, rdpEpsilon);

    for (int i=0; i<smoothReps - splitReps; i++) {
      smoothStroke();    
     }
  }
  
  void draw() {
    shape(ps);
  }
  
  void run() {
    draw();
  }
  
}
