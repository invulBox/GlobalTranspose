// @description MIDI Global Transpose Slave (with Independent Octave)
// @version 1.0
// @author HelloFromTokyo
// @about
//   Transposes incoming MIDI notes based on key and semitone transpose sliders.

desc:MIDI Global Transpose Slave (with Independent Octave)

// Reads global semitone value from Master and applies transpose to incoming MIDI
// Adds independent octave control per instance

slider1:0<-64,64,1>Global transpose semitones (read-only)
slider2:0<-4,4,1>Independent octave transpose

in_pin:none
out_pin:none

@init
gmem_index = 0;

@block
// Read shared transpose value
slider1 = gmem[gmem_index];

// Combine semitone + octave transpose
total_transpose = slider1 + (slider2 * 12);

while (
    midirecv(offset, msg1, msg2, msg3) ? (
        status = msg1 & 0xF0;

        // Note On or Note Off
        (status == 0x90 || status == 0x80) ? (
            note = msg2 + total_transpose;
            note = max(0, min(127, note)); // clamp to valid MIDI range
            midisend(offset, msg1, note, msg3);
        ) : (
            // pass through other MIDI messages
            midisend(offset, msg1, msg2, msg3);
        );
    );
);
