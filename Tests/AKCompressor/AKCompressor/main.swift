//
//  main.swift
//  AudioKit
//
//  Customized by Nick Arner and Aurelius Prochazka on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMix(
            input1: audio.leftOutput,
            input2: audio.rightOutput,
            balance: 0.5.ak)
        connect(mono)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let compressionRatio = AKLine(firstPoint: 0.5.ak, secondPoint: 2.ak, durationBetweenPoints: testDuration.ak)
        connect(compressionRatio)

        let attackTime = AKLine(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: testDuration.ak)
        connect(attackTime)

        let compressor = AKCompressor(input: audioSource, controllingInput: audioSource)
        compressor.compressionRatio = compressionRatio
        compressor.attackTime = attackTime
        connect(compressor)

        let output = AKBalance(input: compressor, comparatorAudioSource: audioSource)
        connect(output)

        enableParameterLog(
            "Compression Ratio = ",
            parameter: compressor.compressionRatio,
            timeInterval:0.2
        )

        enableParameterLog(
            "Attack Time = ",
            parameter: compressor.attackTime,
            timeInterval:0.2
        )

        connect(AKAudioOutput(audioSource:output))

        resetParameter(audioSource)
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(testDuration)

processor.play()
instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
