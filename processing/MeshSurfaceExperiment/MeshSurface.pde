import java.util.Comparator;
import java.util.Collections;

class MeshSurface {
  
  ArrayList<PVector> points;
  ArrayList<PVector> strokePoints;
  ArrayList<Stroke> strokes;
  int maxStrokePointCount = 200;
  float maxPointDistance = 100;
  int numCentroids = 300;
  float globalScale = 1000;
  PShape ps;
  Kmeans kmeans;
  int whichCluster = 0;
  KCluster currentCluster;
  boolean ready = false;
  boolean firstRun = true;
  int minClusterPointsRemaining = 10;
  
  MeshSurface(String url) { 
    points = loadFromShape(url);
    strokes = new ArrayList<Stroke>();
    kmeans = new Kmeans(points, numCentroids);
  }
  
  void regenerateShape() {
    ps = createShape();
    ps.beginShape(POINTS);
    ps.stroke(0);
    ps.strokeWeight(3);
    for (KCluster cluster : kmeans.clusters) {
      for (PVector point : cluster.points) {
        ps.vertex(point.x, point.y, point.z);
      }
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
    if (whichCluster < kmeans.clusters.size()) {
      currentCluster = kmeans.clusters.get(whichCluster);
  
      if (currentCluster.points.size() > 0) {
        ready = false;
        strokePoints = new ArrayList<PVector>();
      
        int index = int(random(currentCluster.points.size()));
        PVector startPos = currentCluster.points.get(index);
        currentCluster.points.remove(index);
        strokePoints.add(startPos);
        Collections.sort(currentCluster.points, new DistanceComparator(startPos)); // sort points by distance from centroid        
      } else {
        advanceCluster();
      }
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
    
    if (currentCluster.points.size() < minClusterPointsRemaining) advanceCluster();
    chooseStartingPoint();
  }
  
  void advanceCluster() {
    whichCluster++;
    if (whichCluster < kmeans.clusters.size()-1) {
      chooseStartingPoint();    
    } else {
      ready = true;
    }
  }
  
  void update() {
    if (!ready && kmeans.ready) {
      if (firstRun) {
        regenerateShape();
        chooseStartingPoint();
        firstRun = false;
      } else {
        if (strokePoints.size() < maxStrokePointCount && currentCluster.points.size() > 1) {
          PVector currentPos = strokePoints.get(strokePoints.size()-1);
          PVector nextPos = currentCluster.points.get(0);
          currentCluster.points.remove(0);
          
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
    if (!kmeans.ready) {
      kmeans.run();
    } else {
      update();
      draw();
    }
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
