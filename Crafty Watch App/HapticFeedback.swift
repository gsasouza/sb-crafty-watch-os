//
//  HapticFeedback.swift
//  Crafty Watch App
//
//  Created by Gabriel Souza on 22/06/24.
//

import SwiftUI

func playHaptic(_ type: WKHapticType) {
    WKInterfaceDevice.current().play(type)
}
