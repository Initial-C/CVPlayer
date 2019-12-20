//
//  MTVideoRoomController.swift
//  Mentor
//
//  Created by YAHAHA on 2019/8/14.
//  Copyright © 2019 Mentor. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import SVProgressHUD

private let studioStr = "http://cn7.7639616.com/hls/20191126/eebb68accf60bff8adffe64c7ac68219/1574769804/index.m3u8$http://cn6.7639616.com/hls/20191126/5732e6c5fd2ba9580797bbac42bc3afa/1574769508/index.m3u8$http://cn6.7639616.com/hls/20191126/4a8f0703560fbf62737a5412e621106c/1574769796/index.m3u8$http://cn6.7639616.com/hls/20191126/92cd1cc6dc8b17f5af5e9ef4e4646f31/1574770052/index.m3u8$http://cn6.7639616.com/hls/20191127/dda0147253cc5614c1ee9dc07db53d4d/1574855943/index.m3u8$http://cn6.7639616.com/hls/20191127/cf70a07ea78d7a49bcb8c8ad143509cb/1574856214/index.m3u8$http://cn7.7639616.com/hls/20191202/6130d5894de49730b8efd518726af6d0/1575289774/index.m3u8$http://cn7.7639616.com/hls/20191202/5764ab97bf8d77657045a9cce212602c/1575290626/index.m3u8$http://cn7.7639616.com/hls/20191202/32bbb815423d075d4fa7dc5709543d70/1575290909/index.m3u8$http://cn7.7639616.com/hls/20191202/d1ba87034a6c2cafc04c426c2d36fa9c/1575290072/index.m3u8$http://cn7.7639616.com/hls/20191202/7e13c54c25302df4b91ac796630970e0/1575290345/index.m3u8$http://cn6.7639616.com/hls/20191203/53260ec7a4b66e59819a294b479f7431/1575374276/index.m3u8$http://cn6.7639616.com/hls/20191203/bcf2643ea292d4c6dc4d4a97a307bcfe/1575374517/index.m3u8$http://cn6.7639616.com/hls/20191204/b6de5e37911e398ced3222ac05bac6cd/1575461531/index.m3u8$http://cn6.7639616.com/hls/20191204/5e664c13bb769d14505ac7bde3ee4c5f/1575461816/index.m3u8$http://cn6.7639616.com/hls/20191205/22cd2b1ea49a2e23c5bced92209dbbd1/1575552029/index.m3u8$http://cn7.7639616.com/hls/20191205/916a0b5ae4898cf8d8711efae0a4c3fe/1575552019/index.m3u8$http://cn7.7639616.com/hls/20191210/b740ab52eddddd94362c6f115295147c/1575981959/index.m3u8$http://cn7.7639616.com/hls/20191210/705ead2f03fb42b5486e02ce37b60f3c/1575982216/index.m3u8$http://cn6.7639616.com/hls/20191210/7207e4d9b553eaf7dc28a6b48c4a9650/1575983199/index.m3u8$http://cn6.7639616.com/hls/20191210/4aad8f826a12afd1344ebcbea7fe5e16/1575983939/index.m3u8$http://cn7.7639616.com/hls/20191211/dc5da261da7723f499e096ba560f6b1a/1576072148/index.m3u8$http://cn7.7639616.com/hls/20191211/13717fa114b4d5acd5dcef6b80680c63/1576071284/index.m3u8$http://cn6.7639616.com/hls/20191211/18f9775f5c6a908a2e4f572326a29edf/1576071251/index.m3u8$http://cn7.7639616.com/hls/20191211/61e986ad5fad7b64958388200fae21e8/1576071659/index.m3u8$http://cn6.7639616.com/hls/20191211/60b8547d81f49a38b9b15a628cc2401d/1576072150/index.m3u8$http://cn6.7639616.com/hls/20191211/c5becb0622315154011b5eb6a8a50068/1576071720/index.m3u8$http://cn7.kankia.com/hls/20191216/1502d3f4cab18c1b420df1eb832460c8/1576499388/index.m3u8$http://cn7.kankia.com/hls/20191216/b25ca0acefce9290b34ff6039bff53da/1576499044/index.m3u8$http://cn7.kankia.com/hls/20191216/54f4d7c9b2c0ff2ad2fa16f47d47787b/1576509615/index.m3u8$http://cn7.kankia.com/hls/20191216/ce7c7408bf80ac15d23360d1be7f7673/1576509006/index.m3u8$http://cn6.kankia.com/hls/20191217/9172fdc56e0f7c5808a5971cdf037d54/1576547595/index.m3u8$http://cn6.kankia.com/hls/20191217/d6408120a4317155193aca5b3b5578ce/1576546261/index.m3u8"
private let studios : [String] = {
    let arr = studioStr.components(separatedBy: "$")
    return arr
}()
class MTVideoRoomController: UIBaseViewController {
    static let shared : MTVideoRoomController = MTVideoRoomController()
    // MARK: orientation
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        isPortrait = isForcePortrait ? true : UIApplication.shared.statusBarOrientation == .portrait
        interactivePopEnable = isPortrait // 手势同步
        if isPortrait {
            isHiddenStatusBar = false
        }
        updateVideoArea()
        return isForcePortrait ? .portrait : .allButUpsideDown//isPortrait ? UIInterfaceOrientationMask.portrait : .landscapeRight // 不随设备旋转而旋转
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait//isPortrait ? .portrait : .landscapeRight // 不随设备旋转而旋转
    }
    // MARK: play view
    fileprivate lazy var statusBarView : UIView = {
        let statusV = UIView()
        statusV.backgroundColor = UIColor.black
        return statusV
    }()
    fileprivate lazy var videoContainer : UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.white
        container.addSubview(playerView)
        playerView.delegate = self
        return container
    }()
    fileprivate lazy var replayContainer : UIView = {
        let replayV = UIView()
        replayV.backgroundColor = .black
        replayV.addSubview(replayBtn)
        replayV.isHidden = true
        let tap = UITapGestureRecognizer.init(target: self, action: nil)
        replayV.addGestureRecognizer(tap)
        return replayV
    }()
    fileprivate lazy var replayBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("重新播放", for: .normal)
        btn.setImage(UIImage(named: "icon_player_cxbf"), for: .normal)
        btn.titleLabel?.font = UIFont(name: kRegularFont, size: 18)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1.0
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(replayAction(_:)), for: .touchUpInside)
        return btn
    }()
    fileprivate lazy var playerView : MTPlayerView = MTPlayerView()
    fileprivate var toolRateBtn : UIButton!
    fileprivate var toolQualityBtn : UIButton!
    fileprivate var toolAudioBtn : UIButton!
    fileprivate var toolCacheBtn : UIButton!
    fileprivate lazy var playerToolBar : UIView = {
        let tool = UIView()
        tool.backgroundColor = .black
        return tool
    }()
    // MARK: tableview
    fileprivate lazy var tableView : UITableView = {
        let tableV = UITableView.init(frame: CGRect.zero, style: .plain)
        tableV.tableFooterView = UIView()
        tableV.sectionFooterHeight = 0.0
        tableV.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 24, right: 0)
        tableV.scrollIndicatorInsets = tableV.contentInset
        tableV.separatorStyle = .singleLine
        tableV.separatorColor = UIColor.init("#e5e5e5")
        tableV.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        tableV.register(UITableViewCell.self, forCellReuseIdentifier: "maincell")
        tableV.backgroundColor = .white
        tableV.delegate = self
        tableV.dataSource = self
        setupAutomatilly(tableV, self)
        if #available(iOS 11, *) {
            tableV.estimatedRowHeight = 0
            tableV.estimatedSectionFooterHeight = 0
            tableV.estimatedSectionHeaderHeight = 0
        }
        return tableV
    }()
    fileprivate lazy var models = [CModel]()
    // MARK: private properties
    fileprivate var isPortrait : Bool = true
    fileprivate var isForcePortrait : Bool = false
    fileprivate var volumnV = SparkMPVolumnView.init()
    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        activateApp()
        title = "庆余年"
        isHiddenNavigationBar = true
        statusbarStyle = UIStatusBarStyle.lightContent
        statusbarAnim = UIStatusBarAnimation.slide
        setupUI()
        // data
        models = studios.enumerated().compactMap({ (i, str) -> CModel in
            let m = CModel()
            m.name = "第\(i+1)集"
            m.isSelected = false
            m.urlStr = str
            return m
        })
        playerView.initialPlayer()
        playerView.loadStudio(models)
        // noti
        NotificationCenter.default.addObserver(self, selector: #selector(exitApp), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitApp), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activateApp), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteHasChangedNotification), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
    }
    // 记录最后一次播放位置
    @objc fileprivate func exitApp() {
        if !isSpaceNULLString(playerView.player.currentUid()) {
            UserDefaults.standard.set(playerView.player.currentUid(), forKey: "last_studio")
            UserDefaults.standard.synchronize()
        }
    }
    @objc fileprivate func activateApp() {
        let session = AVAudioSession.sharedInstance()
        do {
            try _ = session.setCategory(.playback)
        } catch {
            SVProgressHUD.showError(withStatus: "激活媒体失败")
        }
    }
    // airplay 是否断开
    @objc fileprivate func audioRouteHasChangedNotification() {
        let isAirPlay = !isSpaceNULLString(self.activeAirplayOutputRouteName())
        if !isAirPlay {
            SVProgressHUD.showError(withStatus: "AirPlay已断开")
        }
    }
    fileprivate func activeAirplayOutputRouteName() -> String? {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        var name : String?
        currentRoute.outputs.forEach { (outputPort) in
            if outputPort.portType == AVAudioSession.Port.airPlay{
                name = outputPort.portName
            }
        }
        return name
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

// MARK: - UI
extension MTVideoRoomController {
    fileprivate func setupUI() {
        view.addSubview(statusBarView)
        view.addSubview(videoContainer)
        view.addSubview(playerToolBar)
        view.addSubview(replayContainer)
        view.addSubview(tableView)
        view.addSubview(volumnV)
        setupToolBar()
        // layout
        setupLayout()
    }
    
    fileprivate func setupToolBar() {
        toolQualityBtn = UIButton(type: .custom)
        toolQualityBtn.setTitle("高清", for: .normal)
        toolQualityBtn.adjustsImageWhenHighlighted = false
        toolQualityBtn.setTitleColor(.white, for: .normal)
        toolQualityBtn.titleLabel?.font = UIFont(name: kRegularFont, size: 12)
        toolQualityBtn.addTarget(self, action: #selector(toolbarActionQuality(_:)), for: .touchUpInside)
        toolQualityBtn.isHidden = true
        toolRateBtn = UIButton(type: .custom)
        toolRateBtn.setTitle("倍速", for: .normal)
        toolRateBtn.adjustsImageWhenHighlighted = false
        toolRateBtn.setTitleColor(.white, for: .normal)
        toolRateBtn.titleLabel?.font = UIFont(name: kRegularFont, size: 12)
        toolRateBtn.addTarget(self, action: #selector(toolbarActionRate(_:)), for: .touchUpInside)
        toolAudioBtn = UIButton(type: .custom)
        toolAudioBtn.setImage(UIImage(named: "icon_player_switch_audio"), for: .normal)
        toolAudioBtn.setImage(UIImage(named: "icon_player_switch_audio_selected"), for: .selected)
        toolAudioBtn.adjustsImageWhenHighlighted = false
        toolAudioBtn.addTarget(self, action: #selector(toolbarActionAudio(_:)), for: .touchUpInside)
        toolAudioBtn.isHidden = true
        toolCacheBtn = UIButton(type: .custom)
        toolCacheBtn.setImage(UIImage(named: "icon_player_download"), for: .normal)
        toolCacheBtn.adjustsImageWhenHighlighted = false
        toolCacheBtn.addTarget(self, action: #selector(toolbarActionCache(_:)), for: .touchUpInside)
        toolCacheBtn.isHidden = true
        
        playerToolBar.addSubview(toolQualityBtn)
        playerToolBar.addSubview(toolRateBtn)
        playerToolBar.addSubview(toolAudioBtn)
        playerToolBar.addSubview(toolCacheBtn)
    }
    
    // snp
    fileprivate func setupLayout() {
        statusBarView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kIsSpecNavInset)
        }
        videoContainer.snp.makeConstraints { (make) in
            make.top.equalTo(statusBarView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo((kZWScreenW*9/16)).priority(.high)
        }
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        replayContainer.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(videoContainer)
            make.bottom.equalTo(playerToolBar.snp.bottom)
        }
        replayBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 130, height: 40))
        }
        //
        playerToolBar.snp.makeConstraints { (make) in
            make.top.equalTo(videoContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        toolCacheBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-20)
            make.size.equalTo(CGSize(width: 0, height: 30))
        }
        toolAudioBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(toolCacheBtn.snp.left).offset(-15)
            make.size.equalTo(CGSize(width: 0, height: 30))
        }
        toolRateBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(toolAudioBtn.snp.left).offset(0)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        toolQualityBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(toolRateBtn.snp.left).offset(-5)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        //
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(playerToolBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().priority(.medium)
        }
    }
}

// MARK: - logic
extension MTVideoRoomController {
    /// 屏幕旋转视图自适应
    fileprivate func updateVideoArea() {
        if (isPortrait && statusBarView.frame.height != 0) || (!isPortrait && statusBarView.frame.height == 0) {
            return
        }
        statusBarView.snp.updateConstraints { (make) in
            make.height.equalTo(isPortrait ? kIsSpecNavInset : 0.0)
        }
        videoContainer.snp.updateConstraints { (make) in
            make.height.equalTo(isPortrait ? kZWScreenW*9/16 : kZWScreenW).priority(.high)
        }
        playerView.isFullScreen = !isPortrait
    }
    /// 手动控制屏幕旋转
    fileprivate func updateOrientation(_ isFull : Bool) {
        isPortrait = !isFull
        setupFullScreen(isFull)
    }
    /// 倍速
    @objc fileprivate func toolbarActionRate(_ btn : UIButton) {
        if playerView.isHUDLoading { return }
        var selectedIdx = 0
        if let lastSelectedIdx = UserDefaults.standard.object(forKey: "rate_key") as? Int {
            selectedIdx = lastSelectedIdx
        }
        let selectedColor = UIColor.init("#44c08c")
        let normalColor = UIColor.black
        let rates = MTVideoRates
        func handlerRate(_ idx : Int) {
            let rate = rates[idx]
            btn.setTitle(rate, for: .normal)
            playerView.player.rate = Float(rate.replacingOccurrences(of: "x", with: "")) ?? 1.0
            UserDefaults.standard.set(idx, forKey: "rate_key")
            UserDefaults.standard.synchronize()
        }
        let alertVC = UIAlertController.init(title: nil, message: "选择播放倍速", preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "1.0x", style: .default) { (action) in
            handlerRate(0)
        }
        let action2 = UIAlertAction.init(title: "1.25x", style: .default) { (action) in
            handlerRate(1)
        }
        let action3 = UIAlertAction.init(title: "1.5x", style: .default) { (action) in
            handlerRate(2)
        }
        let action4 = UIAlertAction.init(title: "2x", style: .default) { (action) in
            handlerRate(3)
        }
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        cancel.setValue(normalColor, forKey: "titleTextColor")
        alertVC.addAction(cancel)
        let actions = [action1, action2, action3, action4]
        actions.enumerated().forEach { (i, action) in
            alertVC.addAction(action)
            if selectedIdx == i {
                action.setValue(selectedColor, forKey: "titleTextColor")
            } else {
                action.setValue(normalColor, forKey: "titleTextColor")
            }
        }
        self.present(alertVC, animated: true, completion: nil)
    }
    /// 清晰度
    @objc fileprivate func toolbarActionQuality(_ btn : UIButton) {
        
    }
    /// 音频切换
    @objc fileprivate func toolbarActionAudio(_ btn : UIButton) {
        btn.isSelected = !btn.isSelected
        toolQualityBtn.isHidden = btn.isSelected
        playerView.isShowAudioView = btn.isSelected
        isForcePortrait = btn.isSelected
    }
    /// 下载
    @objc fileprivate func toolbarActionCache(_ btn : UIButton) {
        
    }
    /// 重播
    @objc fileprivate func replayAction(_ btn : UIButton) {
        
    }
    
}

// MARK: - playerview delegate
extension MTVideoRoomController: MTPlayerViewDelegate {
    // 重播
    func playerViewReplayAction(_ playerV: MTPlayerView) {
        
    }
    // 播放/暂停
    func playerViewPlayAction(_ btn: UIButton) {
        
    }
    // 改变播放进度
    func playerViewSeekAction(_ seekValue: Float) {
        
    }
    // 播放速度选择(全屏)
    func playerViewRateAction(_ rateIndex: Int) {
        toolRateBtn.setTitle(MTVideoRates[rateIndex], for: .normal)
        UserDefaults.standard.set(rateIndex, forKey: "rate_key")
        UserDefaults.standard.synchronize()
    }
    // 清晰度选择(全屏)
    func playerViewQualityAction(_ qualityIdentifierStr: String) {
        
    }
    // 返回
    func playerViewBackAction(_ playerV: MTPlayerView) {
        if isPortrait {
            navigationController?.popViewController(animated: true)
        } else {
            updateOrientation(false)
        }
    }
    // 投屏
    func playerViewMoreAction(_ playerV: MTPlayerView) {
        playerView.player.pause()
        if let btn = self.volumnV.MPButton {
            btn.sendActions(for: .touchUpInside)
        }
    }
    // 全屏
    func playerViewFullScreenAction(_ playerV: MTPlayerView) {
        updateOrientation(true)
    }
    // 拖动进度结束
    func playerViewLastDragAction(_ seekValue: Float) {
        
    }
    // 显示/隐藏菜单
    func playerViewShowMenuAction(_ isShowMenu: Bool) {
        isHiddenStatusBar = isPortrait ? false : !isShowMenu
    }
    // 同步播放列表位置
    func playerViewCurrentPlay(_ index: Int) {
        tableView.scrollToRow(at: IndexPath.init(row: index, section: 0), at: index == 0 ? .top : .middle, animated: true)
        models.forEach { (m) in
            m.isSelected = false
        }
        models[index].isSelected = true
        tableView.reloadData()
    }
}
// MARK: 列表数据
extension MTVideoRoomController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "maincell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].name
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.init(name: models[indexPath.row].isSelected ? kMediumFont : kRegularFont, size: 15)
        cell.textLabel?.textColor = models[indexPath.row].isSelected ? UIColor.init("#ff6600") : UIColor.init("#333")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        models.forEach { (m) in
            m.isSelected = false
        }
        models[indexPath.row].isSelected = true
        tableView.reloadData()
        playerView.moveTo(models[indexPath.row].name)
    }
}

class CModel: NSObject {
    var name : String = ""
    var isSelected : Bool = false
    var urlStr : String = ""
}
