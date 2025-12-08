#include "ofMain.h"
#include "ofApp.h"

//========================================================================
int main( ){
    // Use ofGLFWWindowSettings for more control if needed, but standard loop is fine.
    // The grid is 145 cols * 10 = 1450 px wide
    // The grid is 86 rows * 10 = 860 px high
    // Plus some padding. Let's make it 1600x1000 to be safe and spacious.
	ofSetupOpenGL(1600, 1000, OF_WINDOW);			// <-------- setup the GL context

	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp(new ofApp());

}
