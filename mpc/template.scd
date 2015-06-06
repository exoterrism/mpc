
SynthDef(\b1, { | out=2, level=1, pan=0, atk= 0.01,decay = 0.2,release=0.26, fratio=1.5,noise=1,done=2,freq1= 120,freq2=30,freq3=30,dc=1,aamp1=1,aamp2=1,aamp3=1,aamp4=1,curve1= (-4),curve2=(-2),curve3=(-4),famp1,famp2,famp3,famp4,p1,oamp=0.1,owhich2=0,ochoose=0|
	var env0,env1,
env1m, son, son2,son3,son4,p2;

	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0],[atk,decay,release],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0,SinOsc.kr(0.025) ,doneAction:done);
env1 = EnvGen.ar(env1);
env1m = env1.midicps;

son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = Pan2.ar(son,pan);
son = LeakDC.ar(son,dc,30);

//son = son ;

son = LPF.ar(son+ WhiteNoise.ar(1*noise), env1m*fratio, env0);

	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, [p1,p2], env0), LFSaw.ar(env1m, [p1,p2], env0);, LFPulse.ar(env1m, [p1,p2], env0), LFTri.ar(env1m, [p1,p2], env0)]);

son = son * 1;
//son = son.clip2(1);
son = son * level.distort;
son = Pan2.ar(son, pan);
OffsetOut.ar(0, son*level).tanh;

},

).add;

SynthDef(\b3, { | out = 0,level=1, pan=0, atk= 0.01,decay = 0.2,release=0.26, fratio=1.5,noise=1,done=2,freq1= 120,freq2=30,freq3=30,dc=1,aamp1=1,aamp2=1,aamp3=1,aamp4=1,curve1= (-4),curve2=(-2),curve3=(-4),famp1,famp2,famp3,famp4,p1,oamp=0.1,owhich2=0,ochoose=0|
	var env0,env1,
env1m, son, son2,son3,son4,p2;
	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0],[atk,decay,release],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0, doneAction:2);
env1 = EnvGen.ar(env1);
	env1m = env1.midicps;
son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

son = SelectX.ar(ochoose,[son,son2,son3,son4]);
son = LeakDC.ar(son,dc,30);
son = son ;
son = LPF.ar(son, env1m, env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, [p1,p2], env0), LFSaw.ar(env1m, [p1,p2], env0), LFPulse.ar(env1m, [p1,p2], env0), LFTri.ar(env1m, [p1,p2], env0)]);
	son =  HPF.ar(son +WhiteNoise.ar(env0*noise),fratio);
//son = son.clip2(1);

	son = Limiter.ar(son,1);
	son = son * level.distort;
son = Pan2.ar(son, pan);

OffsetOut.ar(0, son*level).tanh;

},
).add;



MIDIIn.connectAll;

//KNOB 1

MIDIdef.cc(\test1, {arg value;
	var pages = (value/8).asInt;
	(pages).postln;
	case{pages == 0}{
		"page0".postln;
		~pagesamples.(~numpads,\kick);
	}
	{pages == 1}{
		"page1".postln;
		~pagesamples.(~numpads,\snare);
	}
	{pages == 2}{
		"page2".postln;
		~pagesamples.(~numpads,\hats);
	}

}, 74);


//
~pagesamples = {arg num,function;
num.size.do{arg x;
		MIDIdef.noteOn((\numpad++x).asSymbol, {arg val;
			~play[x].(val,function)},
		num[x])
};
	};


~numpads = [60,61,62,63,56,57,58,59,52,53,54,55,48,49,50,51];

~play =[
	{arg val,function;currentEnvironment[function].one(val)},
	{arg val,function;currentEnvironment[function].two(val)},
	{arg val,function;currentEnvironment[function].three(val)},
	{arg val,function;currentEnvironment[function].four(val)},
	{arg val,function;currentEnvironment[function].five(val)},
	{arg val,function;currentEnvironment[function].six(val)},
	{arg val,function;currentEnvironment[function].seven(val)},
	{arg val,function;currentEnvironment[function].eight(val)},
	{arg val,function;currentEnvironment[function].nine(val)},
	{arg val,function;currentEnvironment[function].twelve(val)},

];

currentEnvironment[\kick] = (
 one: 	 {arg self,value; Synth(\b1,[\level,value/127,\freq1,120,\freq2,40,\freq3,30,\release,1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		two:  { arg self,val;Synth(\b3,[\level,val/127,\freq1,120,\freq2,40,\freq3,30,\release,0.1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		three: { arg self,val; Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		four:{ arg self, val;Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,1,\famp3,1,\ochoose,3,\owhich2,0])},
		five: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,0.1,\ochoose,3,\owhich2,0])},
		six: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,0.1,\ochoose,3,\owhich2,0])},
		seven: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,1,\famp3,1,\ochoose,3,\owhich2,0])},
		eight: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		nine: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,30,\release,0.1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		twelve: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,30,\release,0.1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
	);


currentEnvironment[\snare] = (
 one: 	 {arg self,value; Synth(\b3,[\level,value/127,\freq1,120,\freq2,40,\freq3,30,\release,1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		two:  { arg self,val;Synth(\b3,[\level,val/127,\freq1,120,\freq2,40,\freq3,30,\release,0.1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		three: { arg self,val; Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		four:{ arg self, val;Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,1,\famp3,1,\ochoose,3,\owhich2,0])},
		five: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,0.1,\ochoose,3,\owhich2,0])},
		six: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,0.1,\ochoose,3,\owhich2,0])},
		seven: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,1,\famp3,1,\ochoose,3,\owhich2,0])},
		eight: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,100,\release,1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		nine: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,30,\release,0.1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
		twelve: { arg self,val;	Synth(\b1,[\level,val/127,\freq1,120,\freq2,40,\freq3,30,\release,0.1,\famp1,0.01,\famp2,0.01,\ochoose,3,\owhich2,0])},
	);




