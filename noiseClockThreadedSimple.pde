volatile PixelArray PA;

// fld: controls the field ( background, outline, or fill )
volatile float[] fld0;
volatile float[] fld1;
volatile float[] hue0;
volatile float[] hue1;
volatile float[] sat0;
volatile float[] sat1;
volatile float[] bri0;
volatile float[] bri1;
volatile float fldProgress = 0;
volatile float currentProgress = 0;
volatile boolean fldFlag_thread_readyToUpdate = false;
volatile boolean fldFlag_draw_goUpdate = false;
volatile boolean fldFlag_thread_doneUpdating = false;
volatile boolean fldFlag_draw_requestProgress = false;
volatile boolean fldFlag_thread_progressReady = false;

volatile color[] col0;
int num0;
volatile color[] col1;
int num1;
volatile boolean colFlg_draw_goRender0 = false;
volatile boolean colFlg_draw_goRender1 = false;
volatile boolean colFlg_thread_Rendering0 = false;
volatile boolean colFlg_thread_Rendering1 = false;
volatile boolean colFlg_thread_doneRendering0 = false;
volatile boolean colFlg_thread_doneRendering1 = false;
volatile boolean colFlg_draw_goUpdate0 = false;
volatile boolean colFlg_draw_goUpdate1 = false;
volatile boolean colFlag_thread_Updating0 = false;
volatile boolean colFlag_thread_Updating1 = false;
volatile boolean colFlag_thread_doneUpdating0 = false;
volatile boolean colFlag_thread_doneUpdating1 = false;
volatile boolean colFlag_thread_loopComplete0 = false;
volatile boolean colFlag_thread_loopComplete1 = false;


// resolution helpers
int halfWidth;
int halfHeight;

PGraphics pg;

// clock constants
float outerRadius;
float innerRadius;
float hRadFront;
float hRadBack;
float hWidthFront;
float hWidthBack;
float mRadFront;
float mRadBack;
float mWidthFront;
float mWidthBack;
float sRadFront;
float sRadBack;
float sWidthFront;
float sWidthBack;



float borderWidth;
int millisOffset; 

void setup() {
  size( 800 , 480 );
  halfWidth = width/2;
  halfHeight = height/2;
  background(bgColor);
  noFill();
  stroke(255);
  strokeWeight( 5);
  millisOffset = hour()%12*60*60*1000 + minute()*60*1000 + second()*1000 - millis();
  
  
  outerRadius = 0.5*width - 10;
  innerRadius = 0.45*height;
  borderWidth = 2;
  hRadFront = 0.50*innerRadius;
  hRadBack = 0.10*innerRadius;
  hWidthFront = 0.04*innerRadius;
  hWidthBack = 0.10*innerRadius;
  mRadFront = 0.64*innerRadius;
  mRadBack = 0.14*innerRadius;
  mWidthFront = 0.04*innerRadius;
  mWidthBack = 0.08*innerRadius;
  sRadFront = 0.80*innerRadius;
  sRadBack = 0.16*innerRadius;
  sWidthFront = 0.02*innerRadius;
  sWidthBack = 0.04*innerRadius;


  
  noFill();
  strokeWeight(2*borderWidth);
  stroke(bgColor);
  ellipse( 0.5*width , 0.5*height , 2*outerRadius , 2*outerRadius );
  stroke(outlineColor);
  ellipse( 0.5*width , 0.5*height , 2*outerRadius-3 , 2*outerRadius-3 );
  
  
  
  PA = new PixelArray();
  fld0 = new float[PA.num];
  fld1 = new float[PA.num];
  hue0 = new float[PA.num];
  hue1 = new float[PA.num];
  sat0 = new float[PA.num];
  sat1 = new float[PA.num];
  bri0 = new float[PA.num];
  bri1 = new float[PA.num];
  for( int i = 0 ; i < PA.num ; i++ ) {
    fld0[i] = 0;
    fld1[i] = 0;
    hue0[i] = 0;
    hue1[i] = 0;
    sat0[i] = 0;
    sat1[i] = 0;
    bri0[i] = 0;
    bri1[i] = 0;
  }
  num0 = PA.num/2;
  num1 = PA.num-num0;
  col0 = new color[num0];
  col1 = new color[num1];
  for( int i = 0 ; i < num0 ; i++ ) {
    col0[i] = color(0);
  }
  for( int i = 0 ; i < num1 ; i++ ) {
    col1[i] = color(0);
  }
  
  
  thread( "threadFCalc" );
  while( !fldFlag_thread_readyToUpdate ) {
    // wait until fld data ready
  }
  fldFlag_thread_readyToUpdate = false;
  fldFlag_draw_goUpdate = true;
  while( !fldFlag_thread_doneUpdating ) {
    // wait until done updating
  }
  fldFlag_thread_doneUpdating = false;
  
  while( !fldFlag_thread_readyToUpdate ) {
    // wait until fld data ready
  }
  fldFlag_thread_readyToUpdate = false;
  fldFlag_draw_goUpdate = true;
  while( !fldFlag_thread_doneUpdating ) {
    // wait until done updating
  }
  fldFlag_thread_doneUpdating = false;
  
  thread( "threadCCalc0" );
  thread( "threadCCalc1" );
}




boolean logOut = false;
void draw() {
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  FRAMESTART" ); }
  
  // request fld progress
  fldFlag_draw_requestProgress = true;
  while( !fldFlag_thread_progressReady ) {
    // wait until progress is ready
  }
  currentProgress = fldProgress;
  fldFlag_thread_progressReady = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PROGRESSUPDATED" ); }
  
  
  colFlg_draw_goRender0 = true;
  while( !colFlg_thread_Rendering0 ) {}
  colFlg_thread_Rendering0 = false;
  colFlg_draw_goRender0 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  RENDERSTART0" ); }
   
  colFlg_draw_goRender1 = true;
  while( !colFlg_thread_Rendering1 ) {}
  colFlg_thread_Rendering1 = false;
  colFlg_draw_goRender1 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  RENDERSTART1" ); }
  
  
  loadPixels();
  for( int i = 0 ; i < width*height ; i++ ) {
    
    if( PA.I[i] >=0 ) {
      if( PA.I[i] < num0 ) {
        pixels[ i ] = col0[ PA.I[i] ];
      } else {
        pixels[ i ] = col1[ PA.I[i]-num0 ];
      }
    }
  }
  updatePixels();
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXELSDONE" ); }
  
  while( !colFlg_thread_doneRendering0 ) {}
  colFlg_thread_doneRendering0 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  RENDERDONE0" ); }
  while( !colFlg_thread_doneRendering1 ) {}
  colFlg_thread_doneRendering1 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  RENDERDONE1" ); }
  
  colFlg_draw_goUpdate0 = true;
  while( !colFlag_thread_Updating0 ) {}
  colFlag_thread_Updating0 = false;
  colFlg_draw_goUpdate0 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXEL UPDATE STARTED0" ); }
  
  colFlg_draw_goUpdate1 = true;
  while( !colFlag_thread_Updating1 ) {}
  colFlag_thread_Updating1 = false;
  colFlg_draw_goUpdate1 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXEL UPDATE STARTED1" ); }
  
  if( fldFlag_thread_readyToUpdate ) {
    fldFlag_thread_readyToUpdate = false;
    fldFlag_draw_goUpdate = true;
    if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  FLD UPDATE STARTED" ); }
    while( !fldFlag_thread_doneUpdating ) {
      // wait until done updating
    }
    fldFlag_thread_doneUpdating = false;
    if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  FLD UPDATE DONE" ); }
  }
  
  
  while( !colFlag_thread_doneUpdating0 ) {}
  colFlag_thread_doneUpdating0 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXELS UPDATE DONE0" ); }
  while( !colFlag_thread_doneUpdating1 ) {}
  colFlag_thread_doneUpdating1 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXELS UPDATE DONE1" ); }
  
  while( !colFlag_thread_loopComplete0 ) {}
  colFlag_thread_loopComplete0 = false;
  while( !colFlag_thread_loopComplete1 ) {}
  colFlag_thread_loopComplete1 = false;
  
  if( frameCount%60 == 0 ) {
    println( "frameRate: " , frameRate );
  }
  
  
  
  noStroke();
  fill(outlineColor);
  
  int t = millis() + millisOffset;
  float sPart = float(t)/(60000)%1;
  float mPart = float(t)/(3600000)%1;
  float hPart = float(t)/(43200000)%1;
  float sAng = (-0.25+sPart)*TWO_PI;
  float mAng = (-0.25+mPart)*TWO_PI;
  float hAng = (-0.25+hPart)*TWO_PI;
  
  
  strokeWeight(2*borderWidth);
  stroke(bgColor);
  noFill();
  ellipse( 0.5*width , 0.5*height , 2*outerRadius , 2*outerRadius );
  fill(0 , 0 , 0 ,32 );
  ellipse( 0.5*width , 0.5*height , 2*innerRadius-borderWidth , 2*innerRadius-borderWidth );
  stroke(outlineColor);
  noFill();
  ellipse( 0.5*width , 0.5*height , 2*outerRadius-borderWidth , 2*outerRadius-borderWidth );
  ellipse( 0.5*width , 0.5*height , 2*innerRadius , 2*innerRadius );
  
  
  
  stroke(outlineColor);
  fill(bgColor);
  strokeWeight( borderWidth );
  strokeJoin(MITER);
  pushMatrix();
  translate( halfWidth , halfHeight );
  
  // hour
  pushMatrix();
  rotate( hAng );
  beginShape();
  vertex( hRadFront , -0.5*hWidthFront );
  vertex( hRadFront , 0.5*hWidthFront );
  vertex( -hRadBack , 0.5*hWidthBack );
  vertex( -hRadBack , -0.5*hWidthBack );
  endShape(CLOSE);
  popMatrix();
  
  // minute
  pushMatrix();
  rotate( mAng );
  beginShape();
  vertex( mRadFront , -0.5*mWidthFront );
  vertex( mRadFront , 0.5*mWidthFront );
  vertex( -mRadBack , 0.5*mWidthBack );
  vertex( -mRadBack , -0.5*mWidthBack );
  endShape(CLOSE);
  popMatrix();
  
  // second
  pushMatrix();
  rotate( sAng );
  beginShape();
  vertex( sRadFront , -0.5*sWidthFront );
  vertex( sRadFront , 0.5*sWidthFront );
  vertex( -sRadBack , 0.5*sWidthBack );
  vertex( -sRadBack , -0.5*sWidthBack );
  endShape(CLOSE);
  popMatrix();
  
  popMatrix();
  
}