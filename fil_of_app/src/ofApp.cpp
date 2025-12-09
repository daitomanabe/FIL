
#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {
  ofBackground(0);
  ofSetFrameRate(60);
  ofEnableAlphaBlending();

  loadSegments();

  // Start auto cycle
  startAnimation();
  isHolding = false;
  wasAnimating = true; // To trigger the hold check correctly eventually

  // GUI Setup
  gui.setup();
  gui.add(paramSpeed.setup("Speed (ms)", 100.0, 10.0, 1000.0));
  gui.add(paramOverlap.setup("Overlap (ms)", 50.0, -200.0, 500.0));
  gui.add(paramFade.setup("Fade/Lifetime (ms)", 0.0, 0.0, 2000.0));
  gui.add(paramWordmarkProb.setup("Wordmark Prob", 0.5, 0.0, 1.0));

  // Load settings
  gui.loadFromFile("settings.xml");

  // OSC Setup
  receiver.setup(12345);
}

//--------------------------------------------------------------
void ofApp::loadSegments() {
  ofJson json = ofLoadJson("segments.json");
  if (json.empty()) {
    ofLogError() << "Failed to load segments.json";
    return;
  }

  cols = json["frame"]["cols"];
  rows = json["frame"]["rows"];

  // Calculate offset to center grid in window
  // Window is 1600x1000
  // Grid is cols*CELL_SIZE, rows*CELL_SIZE
  // This will be overridden by scaling in draw(), but kept for reference if
  // needed
  float gridW = cols * CELL_SIZE;
  float gridH = rows * CELL_SIZE;
  offsetX = (ofGetWidth() - gridW) / 2;
  offsetY = (ofGetHeight() - gridH) / 2;

  segments.clear();
  for (auto &item : json["segments"]) {
    Segment seg;
    seg.id = item["id"];
    seg.name = item["name"];

    float x = item["x"].get<float>() * CELL_SIZE;
    float y = item["y"].get<float>() * CELL_SIZE;
    float w = item["w"].get<float>() * CELL_SIZE;
    float h = item["h"].get<float>() * CELL_SIZE;

    seg.rect.set(x, y, w, h);
    seg.color = parseColor(item["color"]);
    // Force initial state
    seg.visible = true;
    seg.activeLevel = 1.0;

    segments.push_back(seg);
  }

  // Default preset
  applyPreset("satellite");
}

ofColor ofApp::parseColor(string s) {
  if (s.empty())
    return ofColor::white;
  const char *p = s.c_str();
  while (*p && *p != '(')
    p++;
  if (!*p)
    return ofColor::white;
  p++;
  int v[4] = {255, 255, 255, 255};
  int i = 0;
  while (*p && *p != ')' && i < 4) {
    v[i] = 0;
    while (*p >= '0' && *p <= '9')
      v[i] = v[i] * 10 + (*p++ - '0');
    if (*p == '.') { // float alpha?
      p++;
      float f = 0, d = 10;
      while (*p >= '0' && *p <= '9') {
        f += (*p++ - '0') / d;
        d *= 10;
      }
      v[i] = (v[i] + f) * 255;
    }
    while (*p && (*p < '0' || *p > '9') && *p != ')')
      p++;
    i++;
  }
  return ofColor(v[0], v[1], v[2], i > 3 ? v[3] : 255);
}

//--------------------------------------------------------------
void ofApp::update() {
  while (receiver.hasWaitingMessages()) {
    ofxOscMessage m;
    receiver.getNextMessage(m);
    string a = m.getAddress();
    if (a == "/speed")
      paramSpeed = m.getArgAsFloat(0);
    else if (a == "/overlap")
      paramOverlap = m.getArgAsFloat(0);
    else if (a == "/fade")
      paramFade = m.getArgAsFloat(0);
    else if (a == "/prob")
      paramWordmarkProb = m.getArgAsFloat(0);
  }
  float t = ofGetElapsedTimeMillis();
  if (wasAnimating && !isAnimating) {
    isHolding = true;
    holdStartTime = t;
  }
  wasAnimating = isAnimating;

  float holdDuration = (currentPresetName == "satellite" ? 7000.0 : 3000.0);
  if (isHolding && (t - holdStartTime > holdDuration)) {
    isHolding = false;
    if (currentPresetName == "satellite") {
      currentPresetName = "wordmark";
    } else if (currentPresetName == "wordmark") {
      currentPresetName = "infrapositive";
    } else {
      currentPresetName = "satellite";
    }
    applyPreset(currentPresetName);
    startAnimation();
  }

  if (isAnimating && (t - lastStepTime > paramSpeed))
    stepAnimation();

  for (int i = activeAnims.size() - 1; i >= 0; i--) {
    if (t - activeAnims[i].startTime > activeAnims[i].lifeTime) {
      segments[activeAnims[i].segmentIndex].activeLevel = 0.0;
      activeAnims.erase(activeAnims.begin() + i);
    }
  }

  float dt = 1.0f / 60.0f, r = (paramFade > 0 ? 1000.0f / paramFade : 8.33f);
  Segment *s = segments.data();
  for (size_t i = 0, n = segments.size(); i < n; ++i, ++s) {
    float tgt = 0.0;
    if (!isAnimating)
      tgt = s->visible ? 1.0 : 0.0;
    else {
      for (auto &a : activeAnims)
        if (a.segmentIndex == i) {
          tgt = 1.0;
          break;
        }
    }
    if (s->activeLevel < tgt)
      s->activeLevel = min((float)tgt, s->activeLevel + r * dt);
    else if (s->activeLevel > tgt)
      s->activeLevel = max((float)tgt, s->activeLevel - r * dt);
  }
}

//--------------------------------------------------------------
void ofApp::draw() {
  float w = ofGetWidth(), h = ofGetHeight();
  float gw = cols * CELL_SIZE, gh = rows * CELL_SIZE;
  float p = 50.0f, aw = w - p * 2, ah = h - p * 2;
  float s = min(aw / gw, ah / gh);

  ofPushMatrix();
  ofTranslate((w - gw * s) / 2, (h - gh * s) / 2);
  ofScale(s, s);

  ofSetColor(255, 10);
  for (int i = 0; i <= cols; i++)
    ofDrawLine(i * CELL_SIZE, 0, i * CELL_SIZE, gh);
  for (int i = 0; i <= rows; i++)
    ofDrawLine(0, i * CELL_SIZE, gw, i * CELL_SIZE);

  Segment *ptr = segments.data();
  for (size_t i = 0, n = segments.size(); i < n; ++i, ++ptr) {
    if (ptr->activeLevel > 0.01f) {
      ofSetColor(255, ptr->activeLevel * 255);
      ofDrawRectangle(ptr->rect);
    }
  }
  ofPopMatrix();

  if (isDebug) {
    ofSetColor(255);
    gui.draw();
    string ft = "FPS: " + ofToString(ofGetFrameRate()) +
                "\nMode: " + (currentPresetName) + "\nState: " +
                (isHolding ? "HOLD" : (isAnimating ? "ANIM" : "IDLE"));
    ofDrawBitmapString(ft, 20, 200);
  }
}

//--------------------------------------------------------------
void ofApp::startAnimation() {
  if (segments.empty())
    return;

  buildAnimOrder();
  if (animOrder.empty())
    return;

  stopAnimation();
  isAnimating = true;
  lastStepTime = ofGetElapsedTimeMillis() - paramSpeed; // Force immediate start

  stepAnimation();
}

void ofApp::stopAnimation() {
  isAnimating = false;
  activeAnims.clear();
}

void ofApp::buildAnimOrder() {
  animOrder.clear();
  for (int i = 0; i < segments.size(); i++) {
    if (segments[i].visible)
      animOrder.push_back(i);
  }
  // Shuffle
  ofRandomize(animOrder);
  animIndex = 0;
}

void ofApp::stepAnimation() {
  if (!isAnimating || animOrder.empty())
    return;
  if (animIndex >= animOrder.size()) {
    stopAnimation();
    return;
  }
  float now = ofGetElapsedTimeMillis();
  if (paramOverlap <= 0)
    activeAnims.clear();
  float lt = (paramOverlap <= 0) ? paramSpeed : (paramSpeed + paramOverlap);
  activeAnims.push_back({animOrder[animIndex++], now, lt});
  lastStepTime = now;
}

void ofApp::applyPreset(string mode) {
  // Logic from web presets (hardcoded IDs)
  // WORDMARK_SEGMENTS, INFRAPOS_SEGMENTS

  vector<string> wordmark = {"V_TL_01", "V_TM_01", "V_TR_01",
                             "V_BL_01", "V_BM_01", "V_BR_01",
                             "H_TL_01", "H_ML_01", "H_BR_01"};

  vector<string> infrapos = {"V_TM_01", "V_BM_01", "H_TL_01", "H_ML_01",
                             "H_MR_01", "H_BR_01", "H_MM_01"};

  currentPresetName = mode;

  if (mode == "satellite") {
    for (auto &s : segments)
      s.visible = true;
  } else if (mode == "wordmark") {
    for (auto &s : segments)
      s.visible = false;
    for (auto &id : wordmark) {
      for (auto &s : segments)
        if (s.id == id)
          s.visible = true;
    }
  } else if (mode == "infrapositive") {
    for (auto &s : segments)
      s.visible = false;
    for (auto &id : infrapos) {
      for (auto &s : segments)
        if (s.id == id)
          s.visible = true;
    }
  }

  // Do NOT trigger buildAnimOrder here if we are controlling it via update()
  // state machine
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key) {
  if (key == ' ') {
    if (isAnimating)
      stopAnimation();
    else
      startAnimation();
  }

  if (key == '1')
    applyPreset("satellite");
  if (key == '2')
    applyPreset("wordmark");
  if (key == '3')
    applyPreset("infrapositive");

  if (key == 'd')
    isDebug = !isDebug;
  if (key == 'f')
    ofToggleFullscreen();
  if (key == 's')
    gui.saveToFile("settings.xml");

  if (key == OF_KEY_UP)
    paramSpeed = paramSpeed + 10;
  if (key == OF_KEY_DOWN)
    paramSpeed = max(10.0f, (float)paramSpeed - 10);

  if (key == OF_KEY_RIGHT)
    paramOverlap = paramOverlap + 10;
  if (key == OF_KEY_LEFT)
    paramOverlap = max(0.0f, (float)paramOverlap - 10);

  if (key == 'q')
    paramFade = paramFade + 10;
  if (key == 'a')
    paramFade = max(0.0f, (float)paramFade - 10);
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y) {}
void ofApp::mouseDragged(int x, int y, int button) {}
void ofApp::mousePressed(int x, int y, int button) {}
void ofApp::mouseReleased(int x, int y, int button) {}
void ofApp::windowResized(int w, int h) {}
