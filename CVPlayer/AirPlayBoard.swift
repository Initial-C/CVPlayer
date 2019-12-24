//
//  AirPlayBoard.swift
//  CVPlayer
//
//  Created by William Chang on 2019/12/21.
//  Copyright © 2019 IMUST. All rights reserved.
//

import UIKit
import SVProgressHUD

class AirPlayBoard: UIView, UITableViewDelegate, UITableViewDataSource, Nibloadable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var holdView: UIView!
    var closeHandler : (()->Void)?
    fileprivate lazy var devices = [MYCAirplayDevice]()
    var connectDevice : MYCAirplayDevice?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = kZWScreenBounds
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "boardcell")
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.sectionFooterHeight = 0.0001
        tableView.sectionHeaderHeight = 0.0001
        tableView.delegate = self
        tableView.dataSource = self
        MYCAirplayManager.shared()?.delegate = self
//        let tap = UITapGestureRecognizer.init(target: self, action: nil)
//        holdView.addGestureRecognizer(tap)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hiddenBoard()
    }
    
    
    @IBAction func actionBreakOut(_ sender: UIButton) {
//        [[MYCAirplayManager sharedManager] closeSocket];
//        [[MYCAirplayManager sharedManager] stop];
        MYCAirplayManager.shared()?.closeSocket()
        MYCAirplayManager.shared()?.stop()
        connectDevice = nil
    }
    func actionSearchDevice() {
        MYCAirplayManager.shared()?.searchAirplayDevice(withTimeOut: 15)
        SVProgressHUD.show(withStatus: "正在检索设备")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardcell", for: indexPath)
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        if !isSpaceNULLString(devices[indexPath.row].displayName) {
            cell.textLabel?.text = devices[indexPath.row].displayName
        }
        cell.textLabel?.textColor = devices[indexPath.row].isConnected ? UIColor.init("#ff6600") : UIColor.init("#333")
        cell.textLabel?.font = UIFont.init(name: kRegularFont, size: 12)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        [[MYCAirplayManager sharedManager] activateSocketToDevice:[MYCAirplayManager sharedManager].deviceList.firstObject];
        MYCAirplayManager.shared()?.activateSocket(to: devices[indexPath.row])
        self.hiddenBoard()
    }
    
}

extension AirPlayBoard : MYCAirplayManagerDelegate {
    func mycAirplayManager(_ airplayManager: MYCAirplayManager!, searchAirplayDeviceFinish deviceList: NSMutableArray!) {
        print("设备搜索结束")
        SVProgressHUD.dismiss()
    }
    func mycAirplayManager(_ airplayManager: MYCAirplayManager!, searchedAirplayDevice deviceList: NSMutableArray!) {
//        SVProgressHUD.showSuccess(withStatus: "检索完成")
        SVProgressHUD.dismiss()
        devices = deviceList as! [MYCAirplayDevice]
        if let lastDevice = connectDevice {
            devices.forEach({$0.isConnected = false})
            devices.filter({$0.hostName == lastDevice.hostName}).first?.isConnected = true
        }
        self.tableView.reloadData()
    }
    func mycAirplayManager(_ airplayManager: MYCAirplayManager!, selectedDeviceOnLine airplayDevice: MYCAirplayDevice!) {
        connectDevice = airplayDevice
        SVProgressHUD.showSuccess(withStatus: "已连接到"+airplayDevice.displayName)
        MYCAirplayManager.shared()?.playVideo(on: airplayDevice, videoUrlStr:MTVideoRoomController.shared.playerView.curModel.urlStr)//"http://v3.cztv.com/cztv/vod/2018/06/28/7c45987529ea410dad7c088ba3b53dac/h264_1500k_mp4.mp4") 
    }
    func mycAirplayManager(_ airplayManager: MYCAirplayManager!, selectedDeviceDisconnect airplayDevice: MYCAirplayDevice!) {
        SVProgressHUD.showInfo(withStatus: "设备已断开")
    }
    func hiddenBoard() {
        SVProgressHUD.dismiss()
        self.isHidden = true
        if let handler = closeHandler {
            handler()
        }
    }
}
