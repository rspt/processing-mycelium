// https://github.com/rspt/processing-pointillisme.git

import java.util.Iterator;

ArrayList cells;
ArrayList newcells;
PImage img;
float food[][];

String filename = "original/capucine.jpg";
boolean inverted = false; // true -> white background

void setup()
{
  size(1800, 996);
  img = loadImage(filename);
  food = new float[width][height];
  for (int x = 0; x < width; ++x)
    for (int y = 0; y < height; ++y) {
      food[x][y] = ((img.pixels[(x+y*width)] >> 8) & 0xFF)/255.0;
      if (inverted) food[x][y] = 1-food[x][y];
    }
  if (inverted) {
    background(255);
  } else {
    background(0);
  }
  cells = new ArrayList();
  newcells = new ArrayList();
  Cell c = new Cell();
  c.xpos = width/2;
  c.ypos = height/4;
  cells.add(c);
}
void keyPressed() {
  saveFrame("export"+filename+"/e-#####.tiff");
} 
void draw()
{
  loadPixels();
  newcells.clear();
  Iterator<Cell> itr = cells.iterator();
  while (itr.hasNext ()) {
    Cell c = itr.next();
    c.draw();
    c.update();
  }

  cells.addAll(newcells);
  updatePixels();
}

float feed(int x, int y, float thresh) {
  float r = 0.0;
  if (x >= 0 && x < width && y >= 0 && y < height) {
    if (food[x][y] > thresh) {
      r = thresh;
      food[x][y] -= thresh;
    } else {
      r = food[x][y];
      food[x][y] = 0.0;
    }
  }
  return r;
}

class Cell {
  float xpos, ypos;
  float dir;
  float state;
  Cell() {
    xpos = random(width);
    ypos = random(height);
    dir = random(2*PI);
    state = 0;
  }
  Cell(Cell c) {
    xpos = c.xpos;
    ypos = c.ypos;
    dir = c.dir;
    state = c.state;
  }
  void draw() {
    if (state > 0.001 && xpos >= 0 && xpos < width && ypos >= 0 && ypos < height) {
      if (inverted) {
        pixels[ int(xpos) + int(ypos) * width ] = color(0, 0, 0);
      } else {
        pixels[ int(xpos) + int(ypos) * width ] = color(255, 255, 255);
      }
    }
  }
  void update()
  {
    state += feed(int(xpos), int(ypos), 0.3) - 0.295;
    xpos += cos(dir);
    ypos += sin(dir);
    dir += random(-PI/4, PI/4);
    if (state > 0.15 && cells.size() < 100) {
      divide();
    } else
      if (state < 0) {
      xpos += random(-15, +15);
      ypos += random(-15, +15);
      state = 0.001;
    }
  }
  void divide() {
    state /= 2;
    Cell c = new Cell(this);
    float dd = random(PI/4);
    dir += dd;
    c.dir -= dd;
    newcells.add(c);
  }
}

