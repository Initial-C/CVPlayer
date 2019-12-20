//
//  MTVideoRoomController.swift
//  Mentor
//
//  Created by YAHAHA on 2019/8/14.
//  Copyright © 2019 Mentor. All rights reserved.
//

import UIKit
import SnapKit

class MTVideoRoomController: UIBaseViewController {
    static let shared : MTVideoRoomController = MTVideoRoomController()
    // MARK: orientation
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        isPortrait = isForcePortrait ? true : UIDevice.current.orientation == UIDeviceOrientation.portrait
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
    // private properties
    fileprivate var isPortrait : Bool = true
    fileprivate var isForcePortrait : Bool = false
    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        isHiddenNavigationBar = true
        statusbarStyle = UIStatusBarStyle.lightContent
        statusbarAnim = UIStatusBarAnimation.slide
        setupUI()
    }
    
    
}

// MARK: - UI
extension MTVideoRoomController {
    fileprivate func setupUI() {
        view.addSubview(statusBarView)
        view.addSubview(videoContainer)
        view.addSubview(playerToolBar)
        view.addSubview(replayContainer)
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
            make.height.equalTo((view.frame.width*9/16))
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
        playerToolBar.snp.makeConstraints { (make) in
            make.top.equalTo(videoContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        toolCacheBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-20)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        toolAudioBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(toolCacheBtn.snp.left).offset(-15)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        toolRateBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(toolAudioBtn.snp.left).offset(-15)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        toolQualityBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(toolRateBtn.snp.left).offset(-5)
            make.size.equalTo(CGSize(width: 30, height: 30))
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
            make.height.equalTo(isPortrait ? kZWScreenW*9/16 : kZWScreenW)
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

// MARK: - delegate
extension MTVideoRoomController: MTPlayerViewDelegate {
    // 播放/暂停
    func playerViewPlayAction(_ btn: UIButton) {
        
    }
    // 改变播放进度
    func playerViewSeekAction(_ seekValue: Float) {
        
    }
    // 播放速度选择(全屏)
    func playerViewRateAction(_ rateIndex: Int) {
        
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
    // 分享
    func playerViewMoreAction(_ playerV: MTPlayerView) {

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
}
