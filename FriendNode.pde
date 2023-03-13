// Happy Place
// j.tarbell  March, 2004
// Albuquerque, New Mexico
// complexification.net

// Processing 0085 Beta syntax update
// j.tarbell   April, 2005

int friendTotal = 64;
Friend[] friends= new Friend[friendTotal];

int palMax = 512;
int palNum = 0;
color[] palette = new color[palMax];

void setup() {
  size(1000, 1000);
  pixelDensity(2);
  fillPalette("monet.jpg");
  resetAll();

  background(255);
}

void draw() {
  // move friends to happy places
  for (int i=0; i<friendTotal; i++) {
    friends[i].move();
    friends[i].renderConnections();
  }

  if (frameCount%2==0) for (int i=0; i<friendTotal; i++) {
    friends[i].calcVelocity();
  }
}

void mousePressed () {
  resetAll();
  background(255);
}


void resetAll() {
  // make some friend entities
  for (int i=0; i<friendTotal; i++) {
    float fx = width/2 + 0.4*width*cos(TWO_PI*i/friendTotal);
    float fy = width/2 + 0.4*width*sin(TWO_PI*i/friendTotal);
    friends[i] = new Friend(fx, fy, i);
  }

  // make some random friend connections
  for (int k=0; k<friendTotal*2.1; k++) {
    int a = int(floor(random(friendTotal)));
    int b = int(floor(random(friendTotal)));
    if (a!=b) {
      friends[a].connectTo(b);
      friends[b].connectTo(a);
    }
  }
}

// OBJECTS ---------------------------------------------------------------

class Friend {
  float x, y;
  float dx, dy;
  float vx, vy;
  int id;

  int friendMaxCount = 10;
  int perceptionRange = 30+int(random(50));
  IntList connections = new IntList();

  // brush painters
  int brushNum = 3;
  Brush[] brushes = new Brush[brushNum];

  color myc = palette[int(random(palNum))];

  Friend(float X, float Y, int Id) {
    // position
    dx = x = X;
    dy = y = Y;
    id = Id;
    for (int n=0; n<brushNum; n++) {
      brushes[n] = new Brush();
    }
  }

  void move() {
    // add velocity to position
    x+=vx;
    y+=vy;

    // damping
    vx*=0.92;
    vy*=0.92;
  }

  void renderConnections() {
    // render connection with all friends
    for (int i=0; i<connections.size(); i++) {
      float fx = friends[connections.get(i)].x;
      float fy = friends[connections.get(i)].y;

      // multuple brushes
      for (int s=0; s<brushNum; s++) {
        brushes[s].brushBetween(x, y, fx, fy);
      }
    }
  }

  void connectTo(int a) {
    if (connections.size()<friendMaxCount) {
      if (!friendWith(a)) {
        connections.push(a);
      }
    }
  }

  boolean friendWith(int a) {
    for (int index : connections) {
      if (index==a) return true;
    }
    return false;
  }

  void calcVelocity() {
    PVector pos=new PVector(x,y);
    PVector steering=new PVector();
    
    for (int i=0; i<friendTotal; i++) {
      Friend current=friends[i];
      PVector friendPos=new PVector(current.x,current.y);
      if (current!=this) {
        float d = dist(current.x, current.y, x, y);
        //attract
        if (friendWith(i)&&d>perceptionRange) {
          steering.add(PVector.sub(friendPos,pos).setMag(2));
        }
        // repulse
        if (!friendWith(i)&&d<perceptionRange) {
          steering.add(PVector.sub(pos,friendPos).setMag(perceptionRange-d));
        }
      }
    }
    vx+=steering.x/42.2;
    vy+=steering.y/42.2;
  }
}

class Brush {
  float p;
  color c;
  float theta;
  float maxtheta;

  Brush() {
    p = random(1.0);
    c = palette[int(random(palNum))];
    theta = random(0.01, 0.1);
    maxtheta=0.22;
  }

  void brushBetween(float x1, float y1, float x2, float y2) {
    theta+=random(-0.050, 0.050);
    theta=constrain(theta, -maxtheta, maxtheta);

    // 以起终点百分比p处为中心涂抹
    stroke(c, 28);
    point(x1+(x2-x1)*p, y1+(y2-y1)*p);

    // 涂抹在百分比p处的附近，百分比波动范围为pOffset
    // Number of brushing points around p-percetage point
    int scatterNum = 11;
    for (int i=0; i<scatterNum; i++) {
      float alpha = 255*0.1*(1-i/scatterNum);
      float pOffset = sin(i*theta*0.1);
      stroke(c, alpha);
      point(x1+(x2-x1)*(p+pOffset), y1+(y2-y1)*(p + pOffset));
      point(x1+(x2-x1)*(p-pOffset), y1+(y2-y1)*(p - pOffset));
    }
  }
}

void fillPalette(String fn) {
  PImage b;
  b = loadImage(fn);
  image(b, 0, 0, width, height);

  for (int x=0; x<width; x++) {
    for (int y=0; y<height; y++) {
      color c = get(x, y);
      boolean exists = false;
      for (int n=0; n<palNum; n++) {
        if (c==palette[n]||dist(red(c),green(c),blue(c),red(palette[n]),green(palette[n]),blue(palette[n]))<30) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        // add color to pal
        if (palNum<palMax) {
          palette[palNum] = c;
          palNum++;
        } else
        {
          break;
        }
      }
    }
  }

  // 调色板加入黑白的颜色来控制的颜色的饱和度
  // Add white and black to palette to control saturation
  int saturationControl=5;
  if (palNum<palMax-saturationControl) {
    for (int i=0; i<saturationControl; i++) {
      palette[palNum]=#000000;
      palNum++;
      palette[palNum]=#FFFFFF;
      palNum++;
    }
  }
  println(palNum);
}
