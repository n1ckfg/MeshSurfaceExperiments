import java.util.Comparator;
import java.util.Collections;

class MeshSurface {
  
  ArrayList<PVector> points;
  ArrayList<PVector> strokePoints;
  ArrayList<Stroke> strokes;
  int maxStrokePointCount = 200;
  float maxPointDistance = 500;
  float globalScale = 1000;
  PShape ps;
  
  MeshSurface(String url) { 
    points = loadFromShape(url);
    strokes = new ArrayList<Stroke>();

    chooseStartingPoint();
  }
  
  void regenerateShape() {
    ps = createShape();
    ps.beginShape(POINTS);
    ps.strokeWeight(3);
    for (PVector point : points) {
      ps.vertex(point.x, point.y, point.z);
    }
    ps.endShape();
  }
  
  ArrayList<PVector> loadFromShape(String _url) {
    PShape shp = loadShape(_url);
    ArrayList<PVector> returns = new ArrayList<PVector>();
   
    // first get root vertices
    for (int i=0; i<shp.getVertexCount(); i++) {
      PVector p = shp.getVertex(i).mult(globalScale);
      returns.add(p);
    }
    
    // then look for child objects
    for (int i=0; i<shp.getChildCount(); i++) {
      PShape child = shp.getChild(i);
      for (int j=0; j<child.getVertexCount(); j++) {
        PVector p = child.getVertex(j).mult(globalScale);
        returns.add(p);
      }
    }
    
    return returns;
  }
    
  void chooseStartingPoint() {
    strokePoints = new ArrayList<PVector>();
    int index = int(random(points.size()));
    PVector startPos = points.get(index);
    points.remove(index);
    strokePoints.add(startPos);
    Collections.sort(points, new DistanceComparator(startPos)); // sort points by distance from centroid
    regenerateShape();
  }
  
  void advanceStroke() {
    if (strokePoints.size() > 1) {
      Stroke stroke = new Stroke(strokePoints);
      stroke.refine();
      strokes.add(stroke);
    }
    chooseStartingPoint();    
  }
  
  void update() {
    if (points.size() > 0) {
      if (strokePoints.size() < maxStrokePointCount) {
        PVector currentPos = strokePoints.get(strokePoints.size()-1);
        PVector nextPos = points.get(0);
        points.remove(0);
        
        float nextDist = currentPos.dist(nextPos);
        println("Next distance: " + nextDist);
        if (nextDist < maxPointDistance) {
          strokePoints.add(nextPos);
        }
      } else {
        advanceStroke();
      }
    }
  }
  
  void draw() {
    shape(ps);
    
    //strokeWeight(0.001);
    for (Stroke stroke : strokes) {
      stroke.run();
    }
  }
  
  void run() {
    update();
    draw();
  }
  
}


class DistanceComparator implements Comparator<PVector> {

  PVector compareToVector;

  DistanceComparator(PVector compareToVector) {
    this.compareToVector = compareToVector;
  }

  int compare(PVector v1, PVector v2) {
    float d1 = v1.dist(compareToVector);
    float d2 = v2.dist(compareToVector);

    if (d1 < d2) {
      return -1;
    } else if (d1 > d2) {
      return 1;
    } else {
      return 0;
    }
  } 
  
}
