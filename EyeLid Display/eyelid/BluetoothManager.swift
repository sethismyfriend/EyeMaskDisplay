//
//  BluetoothManager.swift
//  BluetoothManager
//
//  Created by Seth Hunter on 11/30/21.
//

import Foundation
import CoreBluetooth
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class BluetoothManager: NSObject, ObservableObject, Identifiable {
    var id = UUID()
    
    //MARK: - Interface
    @Published var output = "Disconnected"
    @Published var connected = false
    @Published var continuousUpdate = false
    var allLEDColors1 = Array(repeating: Color.black, count: 64) //right eye (wired first)
    var allLEDColors2 = Array(repeating: Color.black, count: 64) //left eye
    var brightness: Double = 3.0
    
    //MARK: - DataToSend
    //a byte at the end to terminate the string
    //a byte at the beginning for brightness value
    private var dataToSend: [UInt8] = Array(repeating: 0, count: (64*6)+2)
    
    var timer: Timer?
    
    
    @objc func startContinuous() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0/20.0, target: self, selector: #selector(Update), userInfo: nil, repeats: true)
        print("Continuous Update started...")
        continuousUpdate = true
    }

    @objc func Update() {
        //print("Timer fired!")
        formatData(brightness: UInt8(brightness))
        sendData()
    }
    
    @objc func stopContinuous() {
        print("Contiuous Update stopped...")
        self.timer?.invalidate()
        continuousUpdate = false;
    }
    
    public func setLeftEye(leftEye: [Color]) {
        allLEDColors2 = leftEye
    }
    
    public func setRightEye(rightEye: [Color]) {
        allLEDColors1 = rightEye
    }
    
    
    //function to pass data into?
    //todo - change value to also include brightness?
    func formatData(brightness: UInt8) {
        var i = 0
        let l: Double = 1  //cannot send 0 char because it's end of string
        let h: Double = 255
        
        
        dataToSend[i] = brightness
        i += 1
        
        let flipHorizontal = true;
        
        if(!flipHorizontal) {
            for led in allLEDColors1 {
                
                let redVal: UInt8 =  UInt8(((led.components?.r ?? 0) * 255).clamped(to: l...h))
                dataToSend[i] = redVal
                i += 1
                let greenVal: UInt8 = UInt8(((led.components?.g ?? 0) * 255).clamped(to: l...h))
                dataToSend[i] = greenVal
                i += 1
                let blueVal: UInt8 = UInt8(((led.components?.b ?? 0) * 255).clamped(to: l...h))
                dataToSend[i] = blueVal
                i += 1
            }
            
            for led in allLEDColors2 {
                let redVal: UInt8 = UInt8(((led.components?.r ?? 0) * 255).clamped(to: l...h))
                dataToSend[i] = redVal
                i += 1
                let greenVal: UInt8 = UInt8(((led.components?.g ?? 0) * 255).clamped(to: l...h))
                dataToSend[i] = greenVal
                i += 1
                let blueVal: UInt8 = UInt8(((led.components?.b ?? 0) * 255).clamped(to: l...h))
                dataToSend[i] = blueVal
                i += 1
            }
        } else {
            
            let rowI: Int = 8
            var k = 0;
            var kb = 7; //k backwards
            
            
            for led in allLEDColors1 {
                
                kb = ((rowI-k%rowI) + (k-k%rowI) - 1)*3 + i
                //print("\(kb),")
                let redVal: UInt8 =  UInt8(((led.components?.r ?? 0) * 255).clamped(to: l...h))
                dataToSend[kb] = redVal
                
                
                //print("\(kb+1),")
                let greenVal: UInt8 = UInt8(((led.components?.g ?? 0) * 255).clamped(to: l...h))
                dataToSend[kb+1] = greenVal
              
               
                //print("\(kb+2),")
                let blueVal: UInt8 = UInt8(((led.components?.b ?? 0) * 255).clamped(to: l...h))
                dataToSend[kb+2] = blueVal
                k += 1
                
            }
            
            for led in allLEDColors2 {
                kb = ((rowI-k%rowI) + (k-k%rowI) - 1)*3 + i
                let redVal: UInt8 = UInt8(((led.components?.r ?? 0) * 255).clamped(to: l...h))
                dataToSend[kb] = redVal
    
                let greenVal: UInt8 = UInt8(((led.components?.g ?? 0) * 255).clamped(to: l...h))
                dataToSend[kb+1] = greenVal
                
                let blueVal: UInt8 = UInt8(((led.components?.b ?? 0) * 255).clamped(to: l...h))
                dataToSend[kb+2] = blueVal
                k += 1
            }
            
            
        }
        
        //print(dataToSend)
    }
    
    func sendData () {
        guard let peripheral = connectedPeripheral,
              let inputChar = inputChar else {
                  output = "Connection error"
                  return
              }
        
        peripheral.writeValue(Data(dataToSend), for: inputChar, type: .withoutResponse)
    }
    
    
    // MARK: - BLE
    private var centralQueue: DispatchQueue?
    
    private let serviceUUID = CBUUID(string: "384B14B0-A048-4C76-B0A3-5430592032DA")
    
    private let inputCharUUID = CBUUID(string: "627F7CE9-97FD-4381-9BDC-AB8C08EF0044")
    private var inputChar: CBCharacteristic?
    private let outputCharUUID = CBUUID(string: "33C57932-ED8D-4050-8165-BBE019ABA141")
    private var outputChar: CBCharacteristic?
    
    // service and peripheral objects
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    func connectToMask() {
        output = "Connecting..."
        centralQueue = DispatchQueue(label: "test.discovery")
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func disconnectMask() {
        guard let manager = centralManager,
              let peripheral = connectedPeripheral else { return }
        
        manager.cancelPeripheralConnection(peripheral)
    }
    
}


extension BluetoothManager: CBCentralManagerDelegate {
    // This method monitors the Bluetooth radios state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager state changed: \(central.state)")
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    // Called for each peripheral found that advertises the serviceUUID
    // This test program assumes only one peripheral will be powered up
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "UNKNOWN")")
        central.stopScan()
        
        connectedPeripheral = peripheral
        central.connect(peripheral, options: nil)
    }
    
    // After BLE connection to peripheral, enumerate its services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "UNKNOWN")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    // After BLE connection, cleanup
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "UNKNOWN")")
        
        centralManager = nil
        
        DispatchQueue.main.async {
            self.connected = false
            self.output = "Disconnected"
        }
    }
    
}

extension BluetoothManager : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services for \(peripheral.name ?? "UNKNOWN")")
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovered characteristics for \(peripheral.name ?? "UNKNOWN")")
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for ch in characteristics {
            switch ch.uuid {
            case inputCharUUID:
                inputChar = ch
            case outputCharUUID:
                outputChar = ch
                // subscribe to notification events for the output characteristic
                peripheral.setNotifyValue(true, for: ch)
            default:
                break
            }
        }
        
        DispatchQueue.main.async {
            self.connected = true
            self.output = "Connected."
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Notification state changed to \(characteristic.isNotifying)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
       // print("Characteristic updated: \(characteristic.uuid)")
        if characteristic.uuid == outputCharUUID, let data = characteristic.value {
            let bytes:[UInt8] = data.map {$0}
            
            if let answer = bytes.first {
                DispatchQueue.main.async {
                    //place output into a debug area to confrim write
                    self.output = "reply = \(answer)"
                }
            }
        }
    }
}

//random thing to enable the clampled function
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

//exposes the float values of the colors
extension Color {
    
    var components: (r: Double, g: Double, b: Double, o: Double)? {
        let uiColor: UIColor
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        if self.description.contains("NamedColor") {
            let lowerBound = self.description.range(of: "name: \"")!.upperBound
            let upperBound = self.description.range(of: "\", bundle")!.lowerBound
            let assetsName = String(self.description[lowerBound..<upperBound])
            
            uiColor = UIColor(named: assetsName)!
        } else {
            uiColor = UIColor(self)
        }
        
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &o) else { return nil }
        
        return (Double(r), Double(g), Double(b), Double(o))
    }
}
