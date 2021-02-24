// This file takes the first digits of the decimal of pi and maps it to a routine. The routine plays in order and a chord with the number of voices of the digit is played. If the digit is higher than 7, the chord is arpeggiated instead of played polyphonically.

// 1st - Boot the server, then define the ~pi100 variable.
~pi100=[1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,0,2,8,8,4,1,9,7,1,6,9,3,9,9,3,7,5,1,0,5,8,2,0,9,7,4,9,4,4,5,9,2,3,0,7,8,1,6,4,0,6,2,8,6,2,0,8,9,9,8,6,2,8,0,3,4,8,2,5,3,4,2,1,1,7,0,6,7,9]


// 2nd - Add the SynthDef's to the library.
SynthDef("piSound",
	{
		arg frequency, noteDuration, panpos, amp;
		var sound, envelope, amplitude, mix, panmix;
		sound = Resonz.ar(LFTri.ar(frequency)+SinOsc.ar(frequency)+(Saw.ar(frequency)*0.2),1100,1.5);
		envelope = XLine.ar(1, 0.000001, noteDuration, doneAction:2);
		amplitude = amp;
		mix = sound*envelope*amplitude;
		panmix = Pan2.ar(mix,panpos);
		Out.ar(0,panmix);
	}
).add

SynthDef("piPerc",
	{
		arg cutoff, panpos, amp, dur;
		var wave, pan, env, mix, filter;
		wave = WhiteNoise.ar;
		env = XLine.ar(0.000001,amp,dur,doneAction:2);
		mix = wave*env;
		filter = LPF.ar(mix, cutoff);
		pan = Pan2.ar(filter,panpos);
		Out.ar(0,pan);
	}
).add;

// 3rd - define the ~scale variable. It's based on a D Dorian b2 scale.
~scale=[50,50,50,53,67,57,59,59,60,72,63,65,71,74,75,77];

// 4th - define the ~chordsFromData Routine variable.
~chordsFromData=Routine({
	(~pi100.size).do{
		arg count;
		var voices;
		voices = ~pi100.at(count);
		//if there are less than 8 voices, the chord is played polyphonically. If there are more than 7 voices, the chord is arpeggiated.
		if (voices<8,
			{voices.do{
				var scale;
				scale = ~scale.choose.midicps;
				Synth("piSound",[\frequency,scale,\noteDuration,8,\panpos,rrand(-0.85,0.85),\amp,rrand(0.3,0.4)]);
				Synth("piPerc", [\cutoff, rrand(3000,12000),\panpos, rrand(-1.0,1.0),\amp, rrand(0.1,0.3),\dur,rrand(0.1,0.75)]);
			};
			"Chord- # of Voices:".postln; ~pi100.at(count).postln;
			0.8.wait;},
			{voices.do{
				var scale;
				scale = ~scale.choose.midicps*rrand(1.49,1.51);
				"arpeggiation".postln;
				Synth("piSound",[\frequency,scale,\noteDuration,4,\panpos,rrand(-0.85,0.85),\amp,rrand(0.3,0.4)]);
				Synth("piPerc", [\cutoff, rrand(5000,15000),\panpos, rrand(-1.0,1.0),\amp, rrand(0.1,0.3),\dur,rrand(0.03,0.13)]);
				0.15.wait;
			}
		});
	}
});

// 5th - Call the Routine.
~chordsFromData.reset;~chordsFromData.play;

		