// An ImageJ macro tool to visualise Leica Stellaris Tau contrast images
// version 0.3 add calibration with formula from leica
// add warning about using proper IRF value
// Tau values are not absolute lifetime measurements
// 09-12-2022
// jerome.mutterer[AT]cnrs.fr

var params = newArray(0.1,0.2,0.0,0.8);
var range = newArray(0,255);
var distances = newArray(params.length);
var names = newArray("Intensity","Intensity (not used)","Lifetime");
var h=20;
var lll=call('ij.Prefs.get','rangetool.lll',true);

macro "TauDisplay Tool - C00cT0f12TT6f10aTcf10u" {
  irf=call('ij.Prefs.get','rangetool.irf',0.291);
  original=getImageID;
  setBatchMode(1);
  Stack.setChannel(3);
  getMinAndMax(min, max);
  if (max==pow(2,16)-1) {
    Stack.getDimensions(width, height, channels, slices, frames);
    for (i=1;i<=channels;i++) {
      Stack.setChannel(i);
      setMetadata("Label", names[i-1]);
      getRawStatistics(nPixels, mean, min, max, std, histogram);
      setMinAndMax(min, max);
    }
     Stack.setChannel(3);
     run("Calibrate...", "function=[Straight Line] unit=[ns] text1=[10 100] text2=["+0.097*10-irf+" "+0.097*100-irf+"] show");
  }
  selectImage(original);
  Stack.setChannel(3);
  getCursorLoc(x, y, z, flags);
  while (flags&16>0) {
    getCursorLoc(x, y, z, flags);
    while (Overlay.size>7) Overlay.removeSelection(0);
    active=-1;
    if ((y<(h*2))||(y>(getHeight-h*2))) {
      active = getClosestTick(x,y);
      params[active] = x/getWidth;
    }
    intensity=getIntensity();
    setMinAndMax(255*params[2],255*params[3]);
    run("Apply LUT");
    Image.copy;
    close();
    addCompositeOverlay();
    addLut();
    addTicks();
    wait(15);
  }
}

macro "TauDisplay Tool Options" {
  lut =  call('ij.Prefs.get','rangetool.lut','Jet');
  lll = call('ij.Prefs.get','rangetool.lll',true);
  luts = getList("LUTs");
  Dialog.create("Options");
  Dialog.addCheckbox("Leica Lifetime LUT", lll);
  Dialog.addChoice("lut", luts, lut);
  Dialog.addMessage("Important Info for Tau estimates:");
  Dialog.addMessage("Tau = pixel Value * 0.097 - IRF");
  Dialog.addMessage("IRF has to be measured with the same setup\n-the same day\n-with the same laser\n-and the same detector.");
  Dialog.addMessage("IRF cannot currently be read from your files.");
  Dialog.addNumber("IRF", 0.291, 4, 6, "ns");
  Dialog.show();
  lll = Dialog.getCheckbox();
  lut =  Dialog.getChoice();
  call('ij.Prefs.set','rangetool.lll',lll);
  call('ij.Prefs.set','rangetool.lut',lut);
}

function addLut() {
  lut =  call('ij.Prefs.get','rangetool.lut','Jet');
  newImage("lut", "8-bit ramp", getWidth, h, 1);
  idLut=getImageID;
  setMinAndMax(255*params[2],255*params[3]);
  selectImage(original);
  run("Add Image...", "image=[lut] x=0 y="+getHeight-h+" opacity=100");
  selectImage(idLut);
  setLifetimeLut(); 
  setMinAndMax(255*params[0],255*params[1]);
  selectImage(original);
  run("Add Image...", "image=[lut] x=0 y=0 opacity=100");
  selectImage(idLut);
  close();

}

function addTicks() {
  selectImage(original);
  for (i=0;i<params.length;i++) {
    x=getWidth*params[i];
    color='yellow'; 
    if (i>1) color= 'red';     
    makeLine(x, (i>1)*(getHeight-h*0.9), x, (i<2)*(h*0.9)+(i>1)*getHeight);
    Overlay.addSelection(color, 2);
  }
  run("Select None");
  Overlay.show;
}

function getClosestTick(x,y) {
  for (i=0;i<params.length;i++) {
    distances[i] = pow((x-getWidth*params[i]),2);
  }
  if (y>getHeight/2) { distances[0]=1E10; distances[1]=1E10; }
  else { distances[2]=1E10; distances[3]=1E10; }
  rankPos = Array.rankPositions(distances);
  return rankPos[0];
}

function getIntensity() {
  selectImage(original);
  Stack.setChannel(1);
  run("Duplicate...", "title=intensity");
  run("8-bit");
  return getImageID;
}
function getLifetime() {
  lut =  call('ij.Prefs.get','rangetool.lut','Jet');
  selectImage(original);
  Stack.setChannel(3);
  run("Duplicate...", "title=lifetime");
  setLifetimeLut();
  setMinAndMax(calibrate(255)*params[0],calibrate(255)*params[1]);
  run("RGB Color");
  run("HSB Stack");
  return getImageID;
}
function initialize() {
  
}
function addCompositeOverlay() {
  lifetime=getLifetime();
  selectImage(lifetime);
  setSlice(3);
  Image.paste(0,0, "copy");
  run("RGB Color");
  rename("overlay");
  makeRectangle(0,h,getWidth,getHeight-h*2);
  run("Crop");
  selectImage(original);
  run("Add Image...", "image=[overlay] x=0 y=&h opacity=100");
  selectImage(lifetime);
  close();
}

function setLifetimeLut() {
if (lll==true) { 
reds = newArray(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 7, 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51, 54, 58, 62, 66, 70, 74, 78, 82, 86, 90, 94, 98, 102, 105, 109, 113, 117, 121, 125, 129, 133, 137, 141, 145, 149, 153, 156, 160, 164, 168, 172, 176, 180, 184, 188, 192, 196, 200, 204, 207, 211, 215, 219, 223, 227, 231, 235, 239, 243, 247, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254);
greens = newArray(0, 3, 7, 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51, 55, 59, 63, 67, 71, 75, 79, 83, 87, 91, 95, 99, 103, 107, 111, 115, 119, 123, 127, 131, 135, 139, 143, 147, 151, 155, 159, 163, 167, 171, 175, 179, 183, 187, 191, 195, 199, 203, 207, 211, 215, 219, 223, 227, 231, 235, 239, 243, 247, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 250, 246, 242, 238, 234, 230, 226, 222, 218, 214, 211, 207, 203, 199, 195, 191, 187, 183, 179, 175, 171, 168, 164, 160, 156, 152, 148, 144, 140, 136, 132, 128, 125, 121, 117, 113, 109, 105, 101, 97, 93, 89, 85, 82, 78, 74, 70, 66, 62, 58, 54, 50, 46, 42, 39, 35, 31, 27, 23, 19, 15, 11, 7, 3);
blues = newArray(255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 251, 247, 243, 239, 235, 231, 227, 223, 219, 215, 211, 207, 204, 200, 196, 192, 188, 184, 180, 176, 172, 168, 164, 160, 156, 153, 149, 145, 141, 137, 133, 129, 125, 121, 117, 113, 109, 105, 102, 98, 94, 90, 86, 82, 78, 74, 70, 66, 62, 58, 54, 51, 47, 43, 39, 35, 31, 27, 23, 19, 15, 11, 7, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
setLut(reds, greens, blues);
}  else { run(lut); }
}
