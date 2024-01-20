// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftyGPIO
import Foundation

let board: SupportedBoard = .RaspberryPi4

let cal = Calendar.current
guard let interfaces = SwiftyGPIO.hardwareI2Cs(for: board) else { fatalError("Could not get interfaces for board \"\(board)\"") }
let i2c = interfaces[1]

print("Waiting for Pico to connect...")
while !i2c.isReachable(0x17) {} // address used in official i2c example
print("Pico connected!")

while true {
    let now = Date()
    let hour   = UInt8(cal.component(.hour,   from: now))
    let minute = UInt8(cal.component(.minute, from: now))
    let second = UInt8(cal.component(.second, from: now))
    i2c.writeData(0x17, command: 0, values: [hour, minute, second])
}