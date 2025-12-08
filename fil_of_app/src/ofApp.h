#pragma once

#include "ofMain.h"
#include "ofxGui.h"
#include "ofxOsc.h"
using namespace std;

struct Segment {
  string id;
  string name;
  ofRectangle rect; // in pixels
  ofColor color;

  // Animation/Visual states
  bool visible = true;     // Is it currently logically "on"? (for presets)
  float activeLevel = 0.0; // 0.0 to 1.0 for fade animation

  // For sorting/search
  bool operator==(const string &_id) const { return id == _id; }
};

class ofApp : public ofBaseApp {

public:
  void setup();
  void update();
  void draw();

  void keyPressed(int key);
  void mouseMoved(int x, int y);
  void mouseDragged(int x, int y, int button);
  void mousePressed(int x, int y, int button);
  void mouseReleased(int x, int y, int button);
  void windowResized(int w, int h);

  // Setup helper
  void loadSegments();
  void applyPreset(string mode);
  void buildAnimOrder();
  void startAnimation();
  void stopAnimation();
  void stepAnimation(); // Logic to trigger next segment

  // Data
  int cols, rows;
  vector<Segment> segments;

  // Grid config
  const int CELL_SIZE = 10;
  int offsetX = 0;
  int offsetY = 0;

  // Animation State
  bool isAnimating = false;
  vector<int> animOrder; // Indices of segments
  int animIndex = 0;
  float lastStepTime = 0; // For timing the 'speed'

  // Animation Paramters (wrapped in GUI)
  // Values in milliseconds
  // We use ofxFloatSlider which casts effectively to float
  ofxFloatSlider paramSpeed;
  ofxFloatSlider paramOverlap;
  ofxFloatSlider paramFade;
  ofxFloatSlider
      paramWordmarkProb; // 0.0 to 1.0. 1.0 = All Wordmark. 0.0 = All Infra.

  // GUI
  ofxPanel gui;
  bool isGuiVisible = true;

  // OSC
  ofxOscReceiver receiver;

  // Auto-Pattern State
  bool isHolding = false;
  float holdStartTime = 0;
  string currentPresetName = "satellite";
  bool wasAnimating = false;
  bool isDebug = false;

  // Helper to parse web rgba string
  ofColor parseColor(string rgba);

  // Auto-Pattern State
  float lastPatternChangeTime = 0;
  float patternChangeInterval = 5000; // Change every 5 seconds
  vector<string> patterns = {"satellite", "wordmark", "infrapositive"};
  int currentPatternIndex = 0;

  // For "active" segment tracking during animation (overlap logic)
  // We track when a segment should turn off if overlap > 0
  struct ActiveAnim {
    int segmentIndex;
    float startTime;
    float lifeTime;
  };
  vector<ActiveAnim> activeAnims;
};
