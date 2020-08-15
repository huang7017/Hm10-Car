//
//  ViewController.swift
//  CarControl
//
//  Created by 黃凱偉 on 2020/7/25.
//  Copyright © 2020 黃凱偉. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController ,CBCentralManagerDelegate,CBPeripheralDelegate{

    @IBOutlet weak var StatsLabel: UILabel!//標籤
    @IBOutlet weak var ScanButton: UIButton!//搜尋按鈕
    @IBOutlet weak var peripheralName: UILabel!//名單
    @IBOutlet weak var connectButton: UIButton!//連線
    @IBOutlet weak var disconnectButton: UIButton!//中斷
    @IBOutlet weak var goButton: UIButton!//前進
    @IBOutlet weak var stopButton: UIButton!//停
    @IBOutlet weak var gobackButton: UIButton!//後退
    @IBOutlet weak var turnLeftButton: UIButton!//左
    @IBOutlet weak var turnRightButton: UIButton!//右
    @IBOutlet weak var backLeftButton: UIButton!
    @IBOutlet weak var backRightButton: UIButton!
    @IBOutlet weak var dumperUpButton: UIButton!
    @IBOutlet weak var dumperDnButton: UIButton!
    
    
    var service:CBService!
    var centralManager : CBCentralManager!
    let serviceUUID = CBUUID(string: "FFE0")
    let charaUUID = CBUUID(string: "FFE1")
    
    var bluetoothDevice: CBPeripheral?
    var bluetoothCharacteristic:CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self,queue: nil)
        DispatchQueue.main.async {
            self.connectButton.isEnabled = false
            self.disconnectButton.isEnabled = false
            self.goButton.isEnabled = false
            self.stopButton.isEnabled = false
            self.gobackButton.isEnabled = false
            self.turnLeftButton.isEnabled = false
            self.turnRightButton.isEnabled = false
            self.backLeftButton.isEnabled = false
            self.backRightButton.isEnabled = false
            self.dumperUpButton.isEnabled = false
            self.dumperDnButton.isEnabled = false
        }
        addLongPressGesture()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("Bluetooth status is UNKNOWN")
            StatsLabel.text = "藍芽錯誤"
        case .resetting:
            print("Bluetooth status is RESETTING")
            StatsLabel.text = "藍芽重啟"
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
            StatsLabel.text = "藍芽不支援"
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
            StatsLabel.text = "Bluetooth status is UNAUTHORIZED"
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            StatsLabel.text = "藍芽關閉"
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            StatsLabel.text = "藍芽開啟, 請搜尋"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            self.StatsLabel.text = "來源: "
            self.peripheralName.text = peripheral.name!
            self.connectButton.isEnabled = true
        }
        decodePeripheralState(peripheralState: peripheral.state)
        // STEP 4.2: MUST store a reference to the peripheral in
        // class instance variable
        bluetoothDevice = peripheral
        // STEP 4.3: since HeartRateMonitorViewController
        // adopts the CBPeripheralDelegate protocol,
        // the peripheralHeartRateMonitor must set its
        // delegate property to HeartRateMonitorViewController
        // (self)
        bluetoothDevice?.delegate = self
        
        // STEP 5: stop scanning to preserve battery life;
        // re-scan if disconnected
        centralManager?.stopScan()
        
    } // END func centralManager(... didDiscover peripheral
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        bluetoothDevice?.discoverServices([serviceUUID])
        DispatchQueue.main.async {
            self.StatsLabel.text = "Connected!"
            self.connectButton.isEnabled = false
            self.disconnectButton.isEnabled = true
            self.goButton.isEnabled = true
            self.stopButton.isEnabled = true
            self.gobackButton.isEnabled = true
            self.turnLeftButton.isEnabled = true
            self.turnRightButton.isEnabled = true
            self.backLeftButton.isEnabled = true
            self.backRightButton.isEnabled = true
            self.dumperUpButton.isEnabled = true
            self.dumperDnButton.isEnabled = true
        }
        decodePeripheralState(peripheralState: bluetoothDevice!.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
         print("Disconnected")
         DispatchQueue.main.async {
            self.StatsLabel.text = "Disconnected!"
            self.peripheralName.text = "..."
            self.disconnectButton.isEnabled = false
            self.goButton.isEnabled = false
            self.stopButton.isEnabled = false
            self.gobackButton.isEnabled = false
            self.turnLeftButton.isEnabled = false
            self.turnRightButton.isEnabled = false
            self.backLeftButton.isEnabled = false
            self.backRightButton.isEnabled = false
            self.dumperUpButton.isEnabled = false
            self.dumperDnButton.isEnabled = false
         }
         decodePeripheralState(peripheralState: bluetoothDevice!.state)
     }
    
    func addLongPressGesture(){
        //前進
        let goButtonlongPress = UILongPressGestureRecognizer(target: self, action: #selector(golongPress(gesture:)))
        goButtonlongPress.minimumPressDuration = 0.5
        self.goButton.addGestureRecognizer(goButtonlongPress)
        //後退
        let goBack = UILongPressGestureRecognizer(target: self, action: #selector(gobacklongPress(gesture:)))
        goBack.minimumPressDuration = 0.5
        self.gobackButton.addGestureRecognizer(goBack)
        //左轉
        let turnLeft = UILongPressGestureRecognizer(target: self, action: #selector(trunleftlongPress(gesture:)))
        turnLeft.minimumPressDuration = 0.5
        self.turnLeftButton.addGestureRecognizer(turnLeft)
        
        let turnright = UILongPressGestureRecognizer(target: self, action: #selector(rightlongPress(gesture:)))
        turnright.minimumPressDuration = 0.5
        self.turnRightButton.addGestureRecognizer(turnright)
        
        let backleft = UILongPressGestureRecognizer(target: self, action: #selector(backleftlongPress(gesture:)))
        backleft.minimumPressDuration = 0.5
        self.backLeftButton.addGestureRecognizer(backleft)
        
        
        let backright = UILongPressGestureRecognizer(target: self, action: #selector(backrightlongPress(gesture:)))
        backright.minimumPressDuration = 0.5
        self.backRightButton.addGestureRecognizer(backright)
    }
    
    @IBAction func ScanDevice(_ sender: Any) {
        DispatchQueue.main.async {
            self.StatsLabel.text = "搜尋ＨＭ10藍牙晶片..."
        }
        centralManager?.scanForPeripherals(withServices: [serviceUUID])
    }
    
    @IBAction func connectDevice(_ sender: Any) {
        DispatchQueue.main.async {
            self.StatsLabel.text = "Connecting'''"
        }
        centralManager?.connect(bluetoothDevice!)
    }
    
    @IBAction func disconnectDevice(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            self.centralManager?.cancelPeripheralConnection(self.bluetoothDevice!)
            self.ScanButton.isEnabled = true
        }
    }
    
    @IBAction func StopButtonSend(_ sender: Any) {
        allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }
    //前進按鈕
    @IBAction func goButtonSend(_ sender: UIButton) {
        send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "F000")
        usleep(500000)
        allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }
    //前進長按func
    @objc func golongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began{
            send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "F000")
        }
        else{
            allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
        }
    }
    
    //後退
    @IBAction func gobackSend(_ sender: Any) {
        send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "B000")
        usleep(500000)
        allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }
    //後退長按
    @objc func gobacklongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began{
            send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "B000")
        }
        else{
            allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
        }
    }
    //左
    @IBAction func turnLeft(_ sender: Any) {
    
    send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "L000")
    usleep(500000)
    allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }
    @objc func trunleftlongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began{
            send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "L000")
        }
        else{
            allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
        }
    }
    
    @IBAction func rightSend(_ sender: Any) {
        send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "R000")
         usleep(500000)
         allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }
    @objc func rightlongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began{
            send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "R000")
        }
        else{
            allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
        }
    }
    
    @IBAction func backLeft(_ sender: Any) {
        send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "K000")
         usleep(500000)
         allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }
    @objc func backleftlongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began{
            send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "K000")
        }
        else{
            allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
        }
    }
    
    @IBAction func backRight(_ sender: Any) {
        send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "Q000")
         usleep(500000)
         allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }
    @objc func backrightlongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began{
            send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "Q000")
        }
        else{
            allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
        }
    }
    
    @IBAction func dumperUp(_ sender: Any) {
        send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "y000")
         usleep(500000)
         allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }

    
    @IBAction func dumperDn(_ sender: Any) {
        send(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic,someString: "z000")
         usleep(500000)
         allStop(device: bluetoothDevice, deviceCharacterisitc: self.bluetoothCharacteristic)
    }
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
        case .connected:
            print("Peripheral state: connected")
        case .connecting:
            print("Peripheral state: connecting")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        }
    }
    
    //發送
    func send(device: CBPeripheral?,deviceCharacterisitc:CBCharacteristic?,someString:String) {
        let data = someString.data(using: .utf8)
        device?.writeValue(data! , for: deviceCharacterisitc! , type:.withoutResponse)
        print("wrot \(someString)")
    }
    //停止
    func allStop(device: CBPeripheral?,deviceCharacterisitc:CBCharacteristic?) {
        let someString = "S000"
        let data = someString.data(using: .utf8)
        device?.writeValue(data! , for: deviceCharacterisitc! , type:.withoutResponse)
        print("wrot \(someString)")
    }
    
}

extension ViewController {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
            }
            bluetoothCharacteristic = characteristic
            allStop(device: bluetoothDevice, deviceCharacterisitc: bluetoothCharacteristic)
        }
    }
}
