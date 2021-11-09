import peasy.*;

PeasyCam cam;
RDP rdp;
MeshSurfaceK ms;
String url = "battle_pod_remesh.obj";

void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 600);
  ms = new MeshSurfaceK(url);
  rdp = new RDP();
}

void draw() {
  background(127);
  
  ms.run();
  
  surface.setTitle("" + frameRate);
}
