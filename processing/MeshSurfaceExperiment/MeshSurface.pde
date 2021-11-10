import java.util.Comparator;
import java.util.Collections;

class MeshSurface {
  
  ArrayList<PVector> points;
  ArrayList<PVector> strokePoints;
  ArrayList<Stroke> strokes;
  int maxStrokePointCount = 200;
  float maxPointDistance = 200;
  float globalScale = 1000;
  PShape ps;
  boolean ready = false;
  int resample = 10;
  PVector startPos;
  int startPosIndex;
  int pointsCounter = 0;
  
  MeshSurface(String url) { 
    points = loadFromShape(url);
    println("Loaded " + points.size() + " points");
    strokes = new ArrayList<Stroke>();
    generateShape();
   
    chooseStartPos();   
  }
  
  void generateShape() {
    ps = createShape();
    ps.beginShape(POINTS);
    ps.stroke(0);
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
    for (int i=0; i<shp.getVertexCount(); i += resample) {
      PVector p = shp.getVertex(i).mult(globalScale);
      returns.add(p);
    }
    
    // then look for child objects
    for (int i=0; i<shp.getChildCount(); i++) {
      PShape child = shp.getChild(i);
      for (int j=0; j<child.getVertexCount(); j += resample) {
        PVector p = child.getVertex(j).mult(globalScale);
        returns.add(p);
      }
    }
    
    return returns;
  }
  
  void chooseStartPos() {
    strokePoints = new ArrayList<PVector>();
    startPosIndex = int(random(points.size() - maxStrokePointCount));
    startPos = points.get(startPosIndex);
    strokePoints.add(startPos);
    Collections.sort(points, new DistanceComparator(startPos));    
    pointsCounter++;
  }
  
  void advanceStroke() {
    strokes.add(new Stroke(strokePoints));
    chooseStartPos();
  }
  
  void update() {
    if (!ready) {
      if (pointsCounter > points.size() - maxStrokePointCount) {
        ready = true;
      } else {
        if (strokePoints.size() < maxStrokePointCount) {
          PVector current = points.get(strokePoints.size() - 1);
          PVector next = points.get(strokePoints.size());
          if (current.dist(next) < maxPointDistance) {
            strokePoints.add(next);
            pointsCounter++;
          } else {
            advanceStroke();
          }
        } else {
          advanceStroke();
        }
      }
    }
  }
  
  void draw() {
    shape(ps);
    
    for (Stroke stroke : strokes) {
      stroke.run();
    }
  }
  
  void run() {
    update();
    draw();
  }
  
}
