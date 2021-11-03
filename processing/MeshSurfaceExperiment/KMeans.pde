// based on https://openprocessing.org/sketch/51404/

import java.util.Comparator;
import java.util.Collections;

class Kmeans {

  ArrayList<KParticle> particles;
  ArrayList<KCentroid> centroids;
  ArrayList<PVector> centroidFinalPositions;
  ArrayList<KCluster> clusters;
  
  int numberOfCentroids;
  float minX = 0;
  float maxX = 0;
  float minY = 0;
  float maxY = 0;
  float minZ = 0;
  float maxZ = 0;
  float totalStability = 0;
  float stableThreshold = 0.0001;
  boolean ready = false;

  Kmeans(ArrayList<PVector> _points, int _numCentroids) {
    numberOfCentroids = _numCentroids;
    particles = new ArrayList<KParticle>();
    centroids = new ArrayList<KCentroid>();
    centroidFinalPositions = new ArrayList<PVector>();
    clusters = new ArrayList<KCluster>();
    
    for (int i=0; i<_points.size(); i++) {
      PVector p = _points.get(i);
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
      if (p.z < minZ) minZ = p.z;
      if (p.z > maxZ) maxZ = p.z;
      particles.add(new KParticle(p));
    }
    
    init();
  }
  
  void init() {  
    ready = false;
    centroids.clear();
    clusters.clear();
  
    for (int i = 0; i < numberOfCentroids; i++) {
      KCentroid c = new KCentroid(i, 127+random(127), 127+random(127), 127+random(127), minX, maxX, minY, maxY, minZ, maxZ);
      centroids.add(c);
    }
  }

  void update() {
    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).FindClosestCentroid(centroids);
    }  
    
    totalStability = 0;
    
    for (int i = 0; i < centroids.size(); i++) {
      KCentroid c = centroids.get(i);
      c.update(particles);
      if (c.stability > 0) totalStability += c.stability;
    }
    
    if (totalStability < stableThreshold) {
      for (int i=0; i<centroids.size(); i++) {
        PVector p = centroids.get(i).position;
        clusters.add(new KCluster(p));
        centroidFinalPositions.add(p);
      }
      
      for (int i=0; i<particles.size(); i++) {
        KParticle particle = particles.get(i);
        clusters.get(particle.centroidIndex).points.add(particle.position);
      }
      
      int clusterStartIndex = int(random(clusters.size()));
      Collections.sort(clusters, new ClusterComparator(clusters.get(clusterStartIndex))); // sort clusters by centroid  
      ready = true;
    }
    
    //println(totalStability + " " + ready);
  }
  
  void draw() {
    if (!ready) {
      for (int i = 0; i < particles.size(); i++) {
        particles.get(i).draw();
      }  
    
      for (int i = 0; i < centroids.size(); i++) {
        centroids.get(i).draw();
      }
    }
  }
  
  void run() {
    if (!ready) update();
    draw();
  }

}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

class KCentroid {

  PVector position;
  float colorR, colorG, colorB;
  int internalIndex;
  float stability;

  KCentroid(int _internalIndex, float _r, float _g, float _b, float _minX, float _maxX, float _minY, float _maxY, float _minZ, float _maxZ) {
    position = new PVector(random(_minX, _maxX), random(_minY, _maxY), random(_minZ, _maxZ));
    colorR = _r;
    colorG = _g;
    colorB = _b;
    internalIndex = _internalIndex;
    stability = -1;
  }

  void update(ArrayList<KParticle> _particles) {
    //println("-----------------------");
    //println("K-Means KCentroid Tick");
    // move the centroid to its new position

    PVector newPosition = new PVector(0.0, 0.0);

    float numberOfAssociatedParticles = 0;

    for (int i = 0; i < _particles.size(); i++) {
      KParticle curParticle = _particles.get(i);

      if (curParticle.centroidIndex == internalIndex) {
        newPosition.add(curParticle.position); 
        numberOfAssociatedParticles++;
      }
    }

    newPosition.div(numberOfAssociatedParticles);
    stability = position.dist(newPosition);
    position = newPosition;
  }

  void draw() {
    pushMatrix();

    translate(position.x, position.y, position.z);
    strokeWeight(10);
    stroke(colorR, colorG, colorB);
    point(0,0);
    
    popMatrix();
  }
  
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

class KParticle {

  PVector position;
  PVector velocity;
  int centroidIndex;
  float colorR, colorG, colorB;
  float brightness = 0.8;

  KParticle(PVector _position) {
    position = _position;
  }

  void FindClosestCentroid(ArrayList<KCentroid> _centroids) {
    int closestCentroidIndex = 0;
    float closestDistance = 100000;

    // find which centroid is the closest
    for (int i = 0; i < _centroids.size(); i++) {      
      KCentroid curCentroid = _centroids.get(i);

      float distanceCheck = position.dist(curCentroid.position); 

      if (distanceCheck < closestDistance) {
        closestCentroidIndex = i;
        closestDistance = distanceCheck;
      }
    }

    // now that we have the closest centroid chosen, assign the index,
    centroidIndex = closestCentroidIndex;

    // and grab the color for the visualization    
    KCentroid curCentroid = _centroids.get(centroidIndex);
    colorR = curCentroid.colorR * brightness;
    colorG = curCentroid.colorG * brightness;
    colorB = curCentroid.colorB * brightness;
  }

  void draw() {
    pushMatrix();
    translate(position.x, position.y, position.z);
    strokeWeight(2);
    stroke(colorR, colorG, colorB);
    point(0, 0);
    popMatrix();
  }
  
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 class KCluster {
 
   ArrayList<PVector> points;
   PVector centroid;
   
   KCluster(PVector _centroid) {
     centroid = _centroid;
     points = new ArrayList<PVector>();
   }
   
 }
 
 
 class ClusterComparator implements Comparator<KCluster> {

  KCluster compareToV;

  ClusterComparator(KCluster compareToV) {
    this.compareToV = compareToV;
  }

  int compare(KCluster v1, KCluster v2) {
    float d1 = v1.centroid.dist(compareToV.centroid);
    float d2 = v2.centroid.dist(compareToV.centroid);

    if (d1 < d2) {
      return -1;
    } else if (d1 > d2) {
      return 1;
    } else {
      return 0;
    }
  } 
  
}
