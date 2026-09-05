// @description MIDI Global Transpose Master
// @version 1.0
// @author HelloFromTokyo
// @about
//   Transposes incoming MIDI notes based on key and semitone transpose sliders.

desc:MIDI Global Transpose Master
slider1:0<0,11,1{C,C#,D,D#,E,F,F#,G,G#,A,A#,B}>Key (note)
slider2:0<-64,64,1>Master transpose

in_pin:none
out_pin:none

@init
gmem[0] = 0;
last_slider1 = slider1;
last_slider2 = slider2;

@slider
// detect which slider changed
changed1 = (slider1 != last_slider1);
changed2 = (slider2 != last_slider2);

base_offset = floor(slider2 / 12) * 12; // how many octaves up/down

// if semitone slider moved, update note slider
changed2 ? (
  offset = slider2 % 12;
  offset < 0 ? offset += 12;
  slider1 = offset;
);

// if note name slider moved, update semitone slider
changed1 ? (
  // keep same octave offset, just change note within that octave
  slider2 = base_offset + slider1;
);

last_slider1 = slider1;
last_slider2 = slider2;

gmem[0] = slider2;
