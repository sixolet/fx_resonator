FxResonator : FxBase {

    *new { 
        var ret = super.newCopyArgs(nil, \none, (
            gate: 0,
            note: 48,
            structure: 0.25,
            brightness: 0.5,
            damping: 0.7,
            position: 0.25,
            model: 0,
            poly: 1,
            excite: 1,
            easteregg: 0,
            sendA: 0,
            sendB: 0,
            amp: 1,
        ), nil, 1);
        ^ret;
    }

    *initClass {
        FxSetup.register(this.new);
    }

    subPath {
        ^"/fx_resonator";
    }  

    symbol {
        ^\fxResonator;
    }

    listenOSC {
        super.listenOSC;
        OSCFunc.new({|msg, time, addr, recvPort|
            var note = msg[1].asFloat;
            if (syn == nil, {
                var mySyn;
                "new synth".postln;
                syn = Synth.new(\fxResonator, [
                        \inamp, 0,
                        \outBus, Server.default.outputBus,
                        \temporary, 1,
                        \note, note,
                        \gate, 0
                        ] ++ params.asPairs);
                mySyn = syn;
                mySyn.onFree({if (mySyn === syn, {syn = nil});});
            });
            syn.set(\note, note, \gate, 1);
        }, this.subPath ++ "/note");    
    }

    addSynthdefs {
        SynthDef(\fxResonator, {|inBus, outBus, sendABus, sendBBus|
            var input = In.ar(inBus, 2);
            var sound = MiRings.ar(
                in: \inamp.kr(1)*input, 
                trig: \gate.tr(0), 
                pit: \note.kr(48), 
                struct: \structure.kr(0.25), 
                bright: \brightness.kr(0.5),
                damp: \damping.kr(0.7),
                pos: \position.kr(0.25),
                model: \model.kr(0),
                poly: \poly.kr(1),
                intern_exciter: 1,
                easteregg: \easteregg.kr(0));
            sound =[Pan2.ar(sound[0], \pan.kr(0) + \width.kr(0.3)), Pan2.ar(sound[1], \pan.kr(0) - \width.kr(0.3))];
            DetectSilence.ar(\temporary.ir(0)*Mix.ar(sound), amp: 0.00005, time: 0.1, doneAction: Done.freeSelf);
            Out.ar(outBus, \amp.kr(1)*sound);
            Out.ar(sendABus, \sendA.kr(0)*sound);
            Out.ar(sendBBus, \sendB.kr(0)*sound);
        }).add;
    }

}