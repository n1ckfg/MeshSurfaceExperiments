import java.util.Comparator;
import java.util.Collections;

class MeshSurface {
  
  ArrayList<PVector> points;
  ArrayList<PVector> strokePoints;
  ArrayList<Stroke> strokes;
  int maxStrokePointCount = 200;
  float maxPointDistance = 100;
  float globalScale = 1000;
  PShape ps;
  boolean ready = false;
  boolean firstRun = true;
  int resample = 10;
  
  MeshSurface(String url) { 
    points = loadFromShape(url);
    strokes = new ArrayList<Stroke>();
  }
  
  void regenerateShape() {
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
    
  void chooseStartingPoint() {  
    if (points.size() > 0) {
      ready = false;
      strokePoints = new ArrayList<PVector>();
      
      int index = int(random(points.size()));
      PVector startPos = points.get(index);
      points.remove(index);
      strokePoints.add(startPos);
      Collections.sort(points, new DistanceComparator(startPos)); // sort points by distance from centroid        
    } else {
      ready = true;
    }
  }
  
  void advanceStroke() {
    if (strokePoints.size() > 1) {
      Stroke stroke = new Stroke(strokePoints);
      //stroke.refine();
      strokes.add(stroke);
    }
    
    chooseStartingPoint();
  }
  
  void update() {
    if (!ready) {
      if (firstRun) {
        regenerateShape();
        chooseStartingPoint();
        firstRun = false;
      } else {
        if (strokePoints.size() < maxStrokePointCount && points.size() > 1) {
          PVector currentPos = strokePoints.get(strokePoints.size()-1);
          PVector nextPos = points.get(0);
          points.remove(0);
          
          float nextDist = currentPos.dist(nextPos);
          if (nextDist < maxPointDistance) {
            strokePoints.add(nextPos);
          }
        } else {
          advanceStroke();
        }
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
    if (!ready) update();
    draw();
  }
  
}
