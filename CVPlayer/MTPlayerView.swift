//
//  MTPlayerView.swift
//  Mentor
//
//  Created by YAHAHA on 2019/8/15.
//  Copyright © 2019 Mentor. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD
import MediaPlayer
import UIColor_Hex_Swift

protocol MTPlayerViewDelegate : NSObjectProtocol {
    func playerViewBackAction(_ playerV : MTPlayerView) -> Void
    func playerViewMoreAction(_ playerV : MTPlayerView) -> Void
    func playerViewPlayAction(_ btn : UIButton) -> Void
    func playerViewSeekAction(_ seekValue : Float) -> Void
    func playerViewFullScreenAction(_ playerV : MTPlayerView) -> Void
    func playerViewRateAction(_ rateIndex : Int) -> Void
    func playerViewQualityAction(_ qualityIdentifierStr : String) -> Void
    func playerViewLastDragAction(_ seekValue : Float) -> Void
    func playerViewShowMenuAction(_ isShowMenu : Bool) -> Void
    func playerViewReplayAction(_ playerV : MTPlayerView) -> Void
    func playerViewCurrentPlay(_ index : Int) -> Void
}
let MTVideoQualityStrs = ["ld", "sd", "hd"]
let MTVideoRates = ["1.0x", "1.25x", "1.5x", "2.0x"]
class MTPlayerView: UIView {
    weak var delegate : MTPlayerViewDelegate?
    fileprivate lazy var contentView : UIView = {
        let content = UIView()
        content.backgroundColor = .black
        content.clipsToBounds = true
        return content
    }()
    lazy var videoContainerView : UIView = {
        let content = UIView()
        content.backgroundColor = UIColor.init("#ffcc00")
        content.clipsToBounds = true
        return content
    }()
    fileprivate lazy var hudView : MTSmartHUDView = {
        let hud = MTSmartHUDView()
        return hud
    }()
    // MARK: Control Gesture
    fileprivate var controlPan : UIPanGestureRecognizer!
    fileprivate var control_leftArea_Y : CGFloat = 0.0
    fileprivate var control_RightArea_Y : CGFloat = 0.0
    fileprivate var control_Area_X : CGFloat = 0.0
    fileprivate var isPanSeeking : Bool = false
    fileprivate var controlLRWidth : CGFloat {
        return isFullScreen ? kZWScreenH*0.5 : kZWScreenW*0.5
    }
    // MARK: AudioView
    fileprivate lazy var audioView : UIView = {
        let audioV = UIView()
        audioV.backgroundColor = .white
        audioV.clipsToBounds = true
        audioV.addSubview(audioBackImv)
        audioV.addSubview(audioAvatarImv)
        audioV.isHidden = true
        return audioV
    }()
    fileprivate lazy var audioBackImv : UIImageView = {
        let audioBackV = UIImageView()
        audioBackV.contentMode = UIView.ContentMode.scaleAspectFill
        audioBackV.backgroundColor = .clear
        return audioBackV
    }()
    fileprivate lazy var audioAvatarImv : UIImageView = {
        let imv = UIImageView.init(image: UIImage(named: "icon_mine_header_avatar"))
        imv.contentMode = UIView.ContentMode.scaleAspectFill
        imv.clipsToBounds = true
        imv.layer.cornerRadius = 45
        imv.layer.masksToBounds = true
        return imv
    }()
    fileprivate var audioAvatarImg : UIImage? {
        didSet {
            if let img = audioAvatarImg {
                audioAvatarImv.image = img
                audioBackImv.image = getBlurImage(img, nil, nil, false)
            }
        }
    }
    // MARK: Replay View
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
        btn.addTarget(self, action: #selector(actionReplay(_:)), for: .touchUpInside)
        return btn
    }()
    // MARK: bottom
    fileprivate lazy var bottomBackImV : UIImageView = {
        let imv = UIImageView.init(image: UIImage(named: "bg_player_gradient_below"))
        imv.isHidden = true
        return imv
    }()
    fileprivate lazy var timeLb : UILabel = {
        let lb = UILabel()
        lb.text = "--:-- / --:--"
        lb.textColor = .white
        lb.font = UIFont.init(name: kRegularFont, size: 10)
        lb.sizeToFit()
        return lb
    }()
    fileprivate var bufferRightConst : Constraint!
    fileprivate var bufferFullScreenRConst : Constraint!
    fileprivate lazy var bufferProgressView : UIProgressView = {
        let progressV = UIProgressView()
        progressV.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressV.progressTintColor = UIColor.init("#d2d2d2").withAlphaComponent(0.3)
//        progressV.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.5)
        return progressV
    }()
    fileprivate lazy var progressSlider : MTSmartSlider = {
        let progressS = MTSmartSlider()
        progressS.trackHeight = 3
        progressS.setThumbImage(UIImage(named: "icon_player_video_slider_normal"), for: .normal)
        progressS.setThumbImage(UIImage(named: "icon_player_video_slider_highlighted"), for: .highlighted)
        progressS.minimumValue = 0
        progressS.maximumValue = 1
        progressS.minimumTrackTintColor = UIColor.init("#36f1a2")
        progressS.maximumTrackTintColor = UIColor.clear
        return progressS
    }()
    fileprivate lazy var fullScreenBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon_player_fullscreen"), for: .normal)
        btn.addTarget(self, action: #selector(actionFullScreen(_:)), for: .touchUpInside)
        return btn
    }()
    fileprivate lazy var playBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon_player_play"), for: .normal)
        btn.setImage(UIImage(named: "icon_player_pause"), for: .selected)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(actionPlay(_:)), for: .touchUpInside)
        return btn
    }()
    fileprivate lazy var rateBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.tag = -1
        btn.setTitle("倍速", for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: kRegularFont, size: 12)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(actionShowHalfBoard(_:)), for: .touchUpInside)
        return btn
    }()
    fileprivate lazy var qualityBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.tag = -2
        btn.setTitle("高清", for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: kRegularFont, size: 12)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(actionShowHalfBoard(_:)), for: .touchUpInside)
        return btn
    }()
    fileprivate lazy var bottomControlView : UIView = {
        let controlV = UIView()
        controlV.backgroundColor = .clear
        controlV.addSubview(playBtn)
        controlV.addSubview(timeLb)
        controlV.addSubview(fullScreenBtn)
        controlV.addSubview(bufferProgressView)
        controlV.addSubview(progressSlider)
        controlV.addSubview(qualityBtn)
        controlV.addSubview(rateBtn)
        return controlV
    }()
    fileprivate lazy var bottomView : UIView = {
        let bottomV = UIView()
        bottomV.addSubview(bottomBackImV)
        bottomV.addSubview(bottomControlView)
        return bottomV
    }()
    // MARK: Top
    fileprivate lazy var topBackImV : UIImageView = {
        let imv = UIImageView.init(image: UIImage(named: "bg_player_gradient_above"))
        imv.image?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 5, left: 0.3, bottom: 5, right: 0.3))
        imv.isHidden = true
        return imv
    }()
    fileprivate lazy var topView : UIView = {
        let topV = UIView()
        topV.addSubview(topBackImV)
        return topV
    }()
    fileprivate lazy var coverImageView : UIImageView = {
        let imv = UIImageView(image: UIImage(named: "placeHolder_subjectTop"))
        imv.contentMode = UIView.ContentMode.scaleAspectFill
        imv.clipsToBounds = true
        imv.isHidden = true
        imv.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: nil)
        imv.addGestureRecognizer(tap)
        return imv
    }()
    fileprivate lazy var backBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon_player_back"), for: .normal)
        btn.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        return btn
    }()
    fileprivate lazy var moreBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon_player_share"), for: .normal)
        btn.addTarget(self, action: #selector(actionMore(_:)), for: .touchUpInside)
        return btn
    }()
    fileprivate lazy var titleLb : UILabel = {
        let lb = UILabel()
        lb.text = "庆余年"
        lb.textColor = .white
        lb.font = UIFont(name: kMediumFont, size: 15)
        lb.isHidden = true
        return lb
    }()
    // MARK: Board
    fileprivate var isShowHanlfBoard : Bool = false
    fileprivate lazy var halfBoard : UIView = {
        let board = UIView()
        board.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        board.addSubview(qualityMenu)
        board.addSubview(rateMenu)
        return board
    }()
    fileprivate lazy var qualityMenu : UIView = {
        let menu = UIView()
        let btnNames = ["超清", "高清", "标清"]
        let margin : CGFloat = (kZWScreenW - 120) / 6
        btnNames.enumerated().forEach({ (i, str) in
            let topY = margin * 2 + CGFloat(i) * (margin + 40)
            let btn = UIButton(type: .custom)
            btn.tag = abs(i-2)
            btn.setTitle(str, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.setTitleColor(UIColor.init("#44c08c"), for: .selected)
            btn.titleLabel?.font = UIFont(name: kRegularFont, size: 15)
            btn.addTarget(self, action: #selector(qualityMenuClick(_:)), for: .touchUpInside)
            btn.frame = CGRect(x: 0, y: topY, width: 300, height: 40)
            menu.addSubview(btn)
        })
        return menu
    }()
    fileprivate lazy var rateMenu : UIView = {
        let menu = UIView()
        let btnNames = MTVideoRates
        let oriY : CGFloat = (kZWScreenW - 210) * 0.5
        let margin : CGFloat = 30
        btnNames.enumerated().forEach({ (i, str) in
            let topY = oriY + CGFloat(i)*margin*2
            let btn = UIButton(type: .custom)
            btn.tag = i
            btn.setTitle(str, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.setTitleColor(UIColor.init("#44c08c"), for: .selected)
            btn.titleLabel?.font = UIFont(name: kRegularFont, size: 15)
            btn.addTarget(self, action: #selector(rateMenuClick(_:)), for: .touchUpInside)
            btn.frame = CGRect(x: 0, y: topY, width: 300, height: margin)
            menu.addSubview(btn)
        })
        return menu
    }()
    // MARK: 公开api
    var isHUDLoading : Bool {
        return !hudView.isInteractionEnabled
    }
    /// 是否切换到音频
    var isShowAudioView : Bool = false {
        didSet {
            audioView.isHidden = !isShowAudioView
            appearMenus(true)
            fullScreenBtn.isHidden = isShowAudioView
            bufferRightConst.update(offset: isShowAudioView ? -15 : -68)
            // temp
            audioAvatarImg = UIImage(named: "icon_mine_header_avatar")
        }
    }
    /// 是否只显示封面
    var isShowCoverView : Bool = false {
        didSet {
            coverImageView.isHidden = !isShowCoverView
            controlPan.isEnabled = !isShowCoverView
            if isShowCoverView {
                isCancelHideMenu = true
            } else {
                isCancelHideMenu = false
                delayHideMenus()
            }
        }
    }
    /// 设置全屏
    var isFullScreen : Bool = false {
        didSet {
            fullScreenBtn.isHidden = isFullScreen
            rateBtn.isHidden = !isFullScreen
            qualityBtn.isHidden = true//rateBtn.isHidden
            _ = isFullScreen ? bufferRightConst.deactivate() : bufferRightConst.activate()
            _ = isFullScreen ? bufferFullScreenRConst.activate() : bufferFullScreenRConst.deactivate()
            contentView.snp.updateConstraints { (make) in
                make.left.equalTo(isFullScreen ? videoLRMargin : 0)
                make.right.equalTo(isFullScreen ? -videoLRMargin : 0)
            }
            if !isFullScreen {
                appearMenus(true)
            } else {
                if !isShowMenu {
                    isShowMenu = false
                }
            }
            backBtn.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(isFullScreen && !isShowMenu ? -52 : 12)
            }
            backBtn.isHidden = !isFullScreen
//            moreBtn.isHidden = isFullScreen
//            titleLb.isHidden = !isFullScreen
        }
    }
    // 设置倍速 0~3
    var rate : Int = 0 {
        didSet {
            rateMenu.subviews.forEach { (subV) in
                if let btn = subV as? UIButton {
                    if btn.isSelected {
                        btn.isSelected = false
                    }
                    if btn.tag == rate {
                        btn.isSelected = true
                    }
                }
            }
        }
    }
    // 设置清晰度 0~2
    var qualityStr : String = "sd" {
        didSet {
            qualityMenu.subviews.forEach { (subV) in
                if let btn = subV as? UIButton {
                    if btn.isSelected {
                        btn.isSelected = false
                    }
                    if let idx = MTVideoQualityStrs.firstIndex(of: qualityStr), btn.tag == idx {
                        btn.isSelected = true
                    }
                }
            }
        }
    }
    // 设置进度 0~1
    var progress : CGFloat = 0.0 {
        didSet {
            progressSlider.value = Float(progress)
        }
    }
    /// 是否显示重播
    var isShowReplayView : Bool = false {
        didSet {
            replayContainer.isHidden = !isShowReplayView
        }
    }
    // MARK: 私有api
    fileprivate var totalTime : TimeInterval = 0.0
    /// 最后一次滑动位置
    fileprivate var lastMarkedSeconds : Int = 0
    /// 是否正在拖动
    fileprivate var isDraging : Bool = false
    /// 左右间距
    fileprivate let videoLRMargin : CGFloat = kIsIPhoneXSpec ? (kZWScreenH - kZWScreenW*16/9)*0.5 : 0
    /// 是否显示菜单
    fileprivate var isShowMenu : Bool = true {
        didSet {
            if let delegate = delegate {
                delegate.playerViewShowMenuAction(isShowMenu)
            }
        }
    }
    /// 是否取消自动隐藏菜单
    fileprivate var isCancelHideMenu : Bool = false
    /// 音量
    fileprivate var volumeSlider : UISlider? {
        get {
            var vS : UISlider?
            volumeView.subviews.forEach { (view) in
                let cName = view.className()
                if cName == "MPVolumeSlider" {
                    vS = (view as! UISlider)
                }
            }
            return vS
        }
    }
    fileprivate lazy var volumeView : MPVolumeView = {
        let vV = MPVolumeView()
        vV.isHidden = true
        self.window?.addSubview(vV)
        return vV
    }()
    fileprivate var initialVolume : Float = 0.0
    fileprivate var appVolume : Float = 0.0 {
        didSet {
            if let vS = self.volumeSlider {
                self.volumeView.showsVolumeSlider = true
                vS.setValue(appVolume, animated: false)
                vS.sendActions(for: UIControl.Event.touchUpInside)
                self.volumeView.sizeToFit()
            }
        }
    }
    // MARK: player
    var player : AliListPlayer!
    var currentTime : TimeInterval {
        return TimeInterval(player.currentPosition / 1000)
    }
    var duration : TimeInterval {
        return TimeInterval(player.duration / 1000)
    }
    var isPlaying : Bool {
        return playerState == AVPStatusStarted
    }
    var playerState : AVPStatus = AVPStatusIdle
    var curProgress : Float {
        return Float(player.currentPosition / player.duration)
    }
    fileprivate lazy var models = [CModel]()
    var curModel : CModel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        self.clipsToBounds = true
        // gesture
        let menuTap = UITapGestureRecognizer.init(target: self, action: #selector(tapMenus))
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(actionPlayOrPause))
        doubleTap.numberOfTapsRequired = 2
        menuTap.require(toFail: doubleTap)
        self.addGestureRecognizer(menuTap)
        self.addGestureRecognizer(doubleTap)
        controlPan = UIPanGestureRecognizer.init(target: self, action: #selector(actionControlWithPan(_:)))
        self.addGestureRecognizer(controlPan)
        addSubview(contentView)
        contentView.addSubview(videoContainerView)
        contentView.addSubview(audioView)
        contentView.addSubview(bottomView)
        contentView.addSubview(halfBoard)
        contentView.addSubview(topView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(moreBtn)
        contentView.addSubview(replayContainer)
        contentView.addSubview(hudView)
        contentView.addSubview(backBtn)
        contentView.addSubview(titleLb)
        setupLayout()
        setupSlider()
        //
        hudView.isVisableHUD = true
        delayHideMenus()
        syncSystemVolume()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("释放了View")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func setupLayout() {
        contentView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        hudView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        videoContainerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        // audio snp
        audioView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        audioBackImv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        audioAvatarImv.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 90, height: 90))
        }
        // bottom snp
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(95)
        }
        bottomBackImV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        bottomControlView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(44)
        }
        playBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        timeLb.snp.makeConstraints { (make) in
            make.left.equalTo(playBtn.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        fullScreenBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 45, height: 45))
        }
        bufferProgressView.snp.makeConstraints { (make) in
            make.left.equalTo(timeLb.snp.right).offset(8)
            bufferRightConst = make.right.equalToSuperview().offset(-68).priority(.high).constraint
            bufferFullScreenRConst = make.right.equalTo(rateBtn.snp.left).offset(-8).priority(.medium).constraint
            bufferFullScreenRConst.deactivate()
            make.height.equalTo(2)
            make.centerY.equalToSuperview()
        }
        progressSlider.snp.makeConstraints { (make) in
            make.left.right.centerY.equalTo(bufferProgressView)
            make.height.equalTo(20)
        }
        rateBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        qualityBtn.snp.makeConstraints { (make) in
            make.size.equalTo(rateBtn)
            make.right.equalTo(rateBtn.snp.left).offset(-5)
            make.centerY.equalToSuperview()
        }
        halfBoard.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(300)
            make.width.equalTo(300)
        }
        qualityMenu.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        rateMenu.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        // top snp
        topView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(84)
        }
        topBackImV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        moreBtn.snp.makeConstraints {[weak self] (make) in
            guard let sSelf = self else { return }
            make.top.equalTo(sSelf.topView.snp.top).offset(10)
            make.right.equalToSuperview().offset(-9)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        backBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(11)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        titleLb.snp.makeConstraints { (make) in
            make.left.equalTo(backBtn.snp.right).offset(10)
            make.centerY.equalTo(backBtn)
        }
        // replay snp
        replayContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        replayBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 130, height: 40))
        }
        // cover snp
        coverImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    fileprivate func setupSlider() {
        progressSlider.addTarget(self, action: #selector(changeProgress(_:)), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        let sliderTap = UITapGestureRecognizer.init(target: self, action: #selector(tapSliderAction(_:)))
        progressSlider.addGestureRecognizer(sliderTap)
    }
    // 音量同步
    private func syncSystemVolume() {
        initialVolume = AVAudioSession.sharedInstance().outputVolume
        if let vS = volumeSlider, vS.value > 0 {
            initialVolume = vS.value
        }
    }
    // 释放弹窗
    func hudFree(_ isFree : Bool) {
        hudView.isVisableHUD = !isFree
    }

}
// MARK: - slider
extension MTPlayerView {
    @objc fileprivate func changeProgress(_ slider : UISlider) {
        seekingHandler(slider.value)
    }
    @objc fileprivate func progressSliderTouchBegan(_ slider : UISlider) {
        sliderTouchBegan(slider)
    }
    @objc fileprivate func progressSliderValueChanged(_ slider : UISlider) {
        sliderTouchChanging()
    }
    @objc fileprivate func progressSliderTouchEnded(_ slider : UISlider) {
        sliderTouchEnded()
        seekingHandler(slider.value)
    }
    @objc fileprivate func tapSliderAction(_ tap : UITapGestureRecognizer) {
        if let tapView = tap.view, tapView.isKind(of: MTSmartSlider.self) {
            let slider = tapView as! MTSmartSlider
            let point = tap.location(in: slider)
            let length = slider.frame.width
            let tapValue = point.x / length
            //
            seekingHandler(Float(tapValue))
        }
    }
    fileprivate func seekingHandler(_ value : Float) {
        seekToTime(Int(Float(duration) * value))
        if let delegate = delegate {
            delegate.playerViewSeekAction(value)
        }
        hudView.showLoadingHUD()
    }
    fileprivate func sliderTouchEnded() {
        hudView.hide()
        isDraging = false
        if let delegate = delegate {
            delegate.playerViewLastDragAction(progressSlider.value)
        }
        if !isPlaying {
            player.start()
        }
        if isFullScreen {
            delayHideMenus()
        }
    }
    fileprivate func sliderTouchBegan(_ slider : UISlider?) {
        isDraging = true // 用于监听判断
        if slider != nil || isFullScreen  {
            isCancelHideMenu = true
            appearMenus(true)
        } else {
            appearMenus(false)
        }
    }
    fileprivate func sliderTouchChanging() {
        hudView.showSeekingHUD(progressSlider.value, second: totalTime) // TODO: 同步进度时间
    }
    
}
// MARK: logic
extension MTPlayerView {
    /// 显示/隐藏菜单
    @objc fileprivate func tapMenus() {
        if isShowAudioView { return }
        if isShowHanlfBoard {
            actionShowHalfBoard(nil)
            return
        }
        isCancelHideMenu = false
        appearMenus(!isShowMenu)
    }
    // 显示/隐藏菜单
    @objc fileprivate func autoHideMenus() {
//        print("隐藏")
        appearMenus(false)
    }
    @objc fileprivate func cancelAutoHideMenus() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoHideMenus), object: nil)
    }
    @objc fileprivate func delayHideMenus() {
        cancelAutoHideMenus()
        perform(#selector(autoHideMenus), afterDelay: 5.0)
    }
    @objc fileprivate func appearMenus(_ isShow : Bool) {
        // 取消自动隐藏任务
        cancelAutoHideMenus()
        //
        if isShow == isShowMenu {
            isShowMenu = isShow
            if isShow {
                if isCancelHideMenu {
                    isCancelHideMenu = false
                } else {
                    delayHideMenus()
                }
            }
            return
        }
        if isShow {
            if isCancelHideMenu { // 取消自动隐藏
                isCancelHideMenu = false
            } else {
                delayHideMenus()
            }
        } else {
            if isCancelHideMenu { return }
        }
        UIView.animate(withDuration: 0.15) {
            self.bottomView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().offset(isShow ? 0 : 95)
            })
            self.topView.snp.updateConstraints({ (make) in
                make.top.equalToSuperview().offset(isShow ? 0 : -84)
            })
            if self.isFullScreen {
                self.backBtn.snp.updateConstraints({ (make) in
                    make.top.equalToSuperview().offset(isShow ? 10 : -50)
                })
            }
            self.layoutIfNeeded()
        }
        isShowMenu = isShow
    }
    /// 手势控制
    @objc fileprivate func actionControlWithPan(_ panGesture : UIPanGestureRecognizer) {
        if isHUDLoading { return }
        guard let gestureV = panGesture.view else { return }
        switch panGesture.state {
        case .began:
            control_leftArea_Y = panGesture.location(in: gestureV).y
            control_RightArea_Y = panGesture.location(in: gestureV).y
            control_Area_X = panGesture.location(in: gestureV).x
            syncSystemVolume()
            break
        case .changed:
            let translationP = panGesture.translation(in: self)
            let absX = fabsf(Float(translationP.x))
            let absY = fabsf(Float(translationP.y))
            if max(absX, absY) < 10 { return } // 忽略滑动距离过小
            if absX > absY {    // horizontal
                isPanSeeking = true
                sliderTouchBegan(nil)
                let curX = panGesture.location(in: gestureV).x
                let ratio = (curX - control_Area_X) / (isFullScreen ? kZWScreenH : kZWScreenW) * 0.5
                progressSlider.value += (progressSlider.maximumValue - progressSlider.minimumValue) * Float(ratio)
                sliderTouchChanging()
                control_Area_X = curX
            } else if absY > absX { // vertical
                let curPointY = panGesture.location(in: gestureV).y
                if control_Area_X < controlLRWidth { // 左边控制亮度
                    isPanSeeking = false
                    let ratio = (control_leftArea_Y - curPointY) / gestureV.frame.height
                    let curBrightness = UIScreen.main.brightness + ratio
                    hudView.showBrightNess(Float(curBrightness))
//                    print("MT Current play brightness == \(Float(curBrightness))")
                    control_leftArea_Y = curPointY
                } else if control_Area_X > controlLRWidth  { // 右边控制音量
                    isPanSeeking = false
                    let ratio = (control_RightArea_Y - curPointY) / gestureV.frame.height
                    initialVolume += Float(ratio)
                    initialVolume = min(initialVolume, 1.0)
                    initialVolume = max(initialVolume, 0.0)
                    appVolume = initialVolume
                    control_RightArea_Y = curPointY
                }
            }
            break
        default:
            if isPanSeeking {
                isPanSeeking = false
                control_Area_X = 0.0
                sliderTouchEnded()
                seekingHandler(progressSlider.value)
            } else {
                // 亮度
                if control_leftArea_Y != 0 {
                    control_leftArea_Y = 0.0
                    hudView.hide()
                }
                // 音量
                control_RightArea_Y = 0.0
            }
            break
        }
    }
    /// 播放/暂停
    @objc fileprivate func actionPlayOrPause() {
        actionPlay(playBtn)
    }
    @objc fileprivate func actionPlay(_ btn : UIButton) {
        btn.isSelected = !btn.isSelected
        if !btn.isSelected {
            player.pause()
        } else {
            player.start()
        }
        if let delegate = delegate {
            delegate.playerViewPlayAction(btn)
        }
    }
    /// 重播
    @objc fileprivate func actionReplay(_ btn : UIButton) {
        if let delegate = delegate {
            delegate.playerViewReplayAction(self)
        }
    }
    /// 全屏
    @objc fileprivate func actionFullScreen(_ btn : UIButton) {
        if let delegate = delegate {
            delegate.playerViewFullScreenAction(self)
        }
    }
    /// 显示/隐藏面板
    @objc fileprivate func actionShowHalfBoard(_ btn : UIButton?) {
        if let btn = btn { // 显示
            appearMenus(false)
            isShowHanlfBoard = true
            rateMenu.isHidden = btn.tag == -2
            qualityMenu.isHidden = btn.tag == -1
        } else { // 隐藏
            appearMenus(true)
            isShowHanlfBoard = false
        }
        UIView.animate(withDuration: 0.25) {
            self.halfBoard.snp.updateConstraints({[weak self] (make) in
                guard let sSelf = self else { return }
                make.right.equalToSuperview().offset(sSelf.isShowHanlfBoard ? 0 : 300)
            })
            self.layoutIfNeeded()
        }
    }
    /// 返回
    @objc fileprivate func actionBack(_ btn : UIButton) {
        if let delegate = delegate {
            delegate.playerViewBackAction(self)
        }
    }
    /// 更多/分享
    @objc fileprivate func actionMore(_ btn : UIButton) {
        if let delegate = delegate {
            delegate.playerViewMoreAction(self)
        }
    }
    /// 清晰度选择
    @objc fileprivate func qualityMenuClick(_ btn : UIButton) {
        qualityMenu.subviews.forEach { (subV) in
            if let btn = subV as? UIButton, btn.isSelected {
                btn.isSelected = false
            }
        }
        btn.isSelected = true
        if let delegate = delegate {
            delegate.playerViewQualityAction(MTVideoQualityStrs[btn.tag])
        }
        actionShowHalfBoard(nil)
    }
    /// 倍速选择
    @objc fileprivate func rateMenuClick(_ btn : UIButton) {
        rateMenu.subviews.forEach { (subV) in
            if let btn = subV as? UIButton, btn.isSelected {
                btn.isSelected = false
            }
        }
        btn.isSelected = true
        player.rate = Float(MTVideoRates[btn.tag].replacingOccurrences(of: "x", with: "")) ?? 1.0
        if let delegate = delegate {
            delegate.playerViewRateAction(btn.tag)
        }
        actionShowHalfBoard(nil)
    }
    /// 刷新UI
    @objc fileprivate func refresh(_ curTime : TimeInterval) {
//        let curTime = player.currentTime()
        totalTime = duration
        var progress : Float = Float(curTime / totalTime)
        if progress > 1.0 {
            progress = 1.0
        } else if progress < 0.0 {
            progress = 0.0
        }
//        if playBtn.isSelected != player.isPlaying() {
//            playBtn.isSelected = player.isPlaying()
//        }
        //
        let totalTimeStr = formatDuration(totalTime)
        if curTime > 0 && totalTime > 0 {
            if isDraging {
                let curTimeWithDragged = Double(progressSlider.value) * totalTime
                timeLb.text = formatDuration(curTimeWithDragged) + " / " + totalTimeStr
            } else {
                timeLb.text = formatDuration(curTime) + " / " + totalTimeStr
                self.progress = CGFloat(progress)
            }
        } else {
            timeLb.text = "--:-- / --:--"
            self.progress = 0.0
        }
        //
        if isHUDLoading && isPlaying {
            hudView.hide()
        }

    }
    func showLoadingHUD() {
        hudView.showLoadingHUD()
    }
}
// MARK: 播放器
extension MTPlayerView: AVPDelegate {
    func initialPlayer() {
        player = AliListPlayer.init()
        player.isLoop = false
        player.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT
        player.isAutoPlay = false
        player.enableLog = false
        player.isMuted = false
        player.delegate = self
        player.enableHardwareDecoder = true
        // config
        if let config = player.getConfig() {
            config.maxDelayTime = 5000
            config.maxBufferDuration = 30000
            config.highBufferDuration = 3000
            config.startBufferDuration = 500
            config.networkTimeout = 5000
            config.networkRetryCount = 3
            player.setConfig(config)
        }
        // cache
        let cacheConfig = AVPCacheConfig.init()
        cacheConfig.enable = true
        cacheConfig.maxDuration = 120*60
        var isDir = ObjCBool.init(true)
        let cachePath = kDocumentFolder + "/CC_TempVideo"
        if !FileManager.default.fileExists(atPath: cachePath, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
            } catch {}
        }
        cacheConfig.path = cachePath
        cacheConfig.maxSizeMB = 600
        player.setCacheConfig(cacheConfig)
        
    }
    
    func loadStudio(_ models : [CModel]) {
        self.models = models
        // 列表播放方式, 只支持非hls流
//        models.forEach { (model) in
//            player.addUrlSource(model.urlStr, uid: model.name)
//        }
//        player.prepare()
//        if let lastStudio = UserDefaults.standard.object(forKey: "last_studio") as? String, !isSpaceNULLString(lastStudio) {
//            player.move(to: lastStudio)
//        } else {
//            player.move(to: models.first!.name)
//        }
        // 点播方式
        if let lastStudio = UserDefaults.standard.object(forKey: "last_studio") as? String, !isSpaceNULLString(lastStudio) {
            moveTo(lastStudio)
        } else {
            moveTo(models.first!.name)
        }
        player.playerView = videoContainerView
    }

    func seekToTime(_ seconds : Int) {
            if seconds < 3 { return }
            player.seek(toTime: Int64(seconds * 1000), seekMode: AVP_SEEKMODE_INACCURATE)
            showLoadingHUD()
    }
    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
        switch eventType {
        case AVPEventPrepareDone:   // 准备完成
            if let currentVideoInfo = player.getCurrentTrack(AVPTRACK_TYPE_VIDEO), let tracks = player.getMediaInfo()?.tracks {
                tracks.forEach { (info) in
                    print("码率索引==\(info.trackIndex), bit==\(info.trackBitrate), 画面高度==\(info.videoHeight)/n")
                }
                print("当前画面高度==\(currentVideoInfo.videoHeight)")
            }
            hudView.showLoadingHUD()
            player.start()
            break
        case AVPEventLoadingStart:  // 加载开始
            hudView.showLoadingHUD()
            break
        case AVPEventLoadingEnd:    // 加载完成
            SVProgressHUD.dismiss()
            break
        case AVPEventSeekEnd:   // 跳转完成
            SVProgressHUD.dismiss()
            break
        case AVPEventCompletion: // 播放完成
//            if let lastVod = models.last {
//                if self.player.currentUid() == lastVod.name {
//                    self.isShowReplayView = true
//                } else {
//                    self.player.moveToNext()
//                }
//            }
            moveToNext()
            break
        default:
            break
        }
    }
    func onPlayerStatusChanged(_ player: AliPlayer!, oldStatus: AVPStatus, newStatus: AVPStatus) {
//        /** @brief 空转，闲时，静态 */
//        AVPStatusIdle = 0,
//        /** @brief 初始化完成 */
//        AVPStatusInitialzed,
//        /** @brief 准备完成 */
//        AVPStatusPrepared,
//        /** @brief 正在播放 */
//        AVPStatusStarted,
//        /** @brief 播放暂停 */
//        AVPStatusPaused,
//        /** @brief 播放停止 */
//        AVPStatusStopped,
//        /** @brief 播放完成 */
//        AVPStatusCompletion,
//        /** @brief 播放错误 */
//        AVPStatusError
        playerState = newStatus
        switch newStatus {
        case AVPStatusStarted:
            playBtn.isSelected = true
            break
        case AVPStatusPaused,AVPStatusStopped:
            playBtn.isSelected = false
            break
        case AVPStatusError:
            playBtn.isSelected = false
            timeLb.text = "--:-- / --:--"
            progressSlider.value = 0.0
            break
        case AVPStatusInitialzed:
            break
        default:
            break
        }
    }
    func onError(_ player: AliPlayer!, errorModel: AVPErrorModel!) {
        appearMenus(true)
        hudView.showFailureHUD(errorModel.message)
        //
    }
    func onTrackChanged(_ player: AliPlayer!, info: AVPTrackInfo!) {
        switch info.trackType {
        case AVPTRACK_TYPE_VIDEO:
            SVProgressHUD.showInfo(withStatus: "清晰度切换完成")
            break
        default:
            break
        }
    }
    func onCurrentPositionUpdate(_ player: AliPlayer!, position: Int64) {
        refresh(TimeInterval(position/1000))
    }
    func onPlayerEvent(_ player: AliPlayer!, eventWithString: AVPEventWithString, description: String!) {
        if eventWithString == EVENT_PLAYER_CACHE_SUCCESS {
            print("缓存成功")
        }
        if eventWithString == EVENT_SWITCH_TO_SOFTWARE_DECODER {
            print("已切换为软解")
        }
    }
    
    func moveTo(_ videoID : String) {
        if let m = models.filter({$0.name == videoID}).first {
            curModel = m
            if let delegate = delegate, let idx = models.firstIndex(of: m) {
                delegate.playerViewCurrentPlay(idx)
            }
            
            let source = AVPUrlSource.init()
            source.playerUrl = URL.init(string: m.urlStr)
            player.setUrlSource(source)
            showLoadingHUD()
            player.prepare()
        }
    }
    fileprivate func moveToNext() {
        if curModel != nil, var curIdx = models.firstIndex(of: curModel) {
            if curIdx+1 >= models.count {
                curIdx = 0
            } else {
                curIdx += 1
            }
            if let delegate = delegate {
                delegate.playerViewCurrentPlay(curIdx)
            }
            let source = AVPUrlSource.init()
            source.playerUrl = URL.init(string: models[curIdx].urlStr)
            player.setUrlSource(source)
            showLoadingHUD()
            player.prepare()
        }
    }
    
}
// MARK: slider
class MTSmartSlider: UISlider {
    var trackHeight : CGFloat = 0.0
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect.init(x: 0, y: (self.bounds.height-self.trackHeight)*0.5, width: self.bounds.width, height: self.trackHeight)
    }
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {

        if self.isHighlighted {
            var temprect = rect
            temprect.origin.x = rect.origin.x - 25
            temprect.size.width = rect.size.width + 50
            return super.thumbRect(forBounds: bounds, trackRect: temprect, value: value).insetBy(dx: 25, dy: 25)
        } else {
            return super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        }
    }
}
class MTSmartHUDView : UIView {
    
    var seekingProgressView : UIProgressView!
    var seekingTimeLb : UILabel!
    var failureLb : UILabel!
    var isInteractionEnabled : Bool = true
    var isVisableHUD : Bool = true {
        didSet {
            SVProgressHUD.setMinimumDismissTimeInterval(2)
            if isVisableHUD {
                SVProgressHUD.setContainerView(self)
            } else {
                SVProgressHUD.setContainerView(nil)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        self.alpha = 0.0
        //
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        seekingProgressView = UIProgressView()
        seekingProgressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        seekingProgressView.progressTintColor = UIColor.init("#36f1a2").withAlphaComponent(0.8)
        seekingTimeLb = UILabel()
        seekingTimeLb.textColor = .white
        seekingTimeLb.font = UIFont(name: kMediumFont, size: 32)
        seekingTimeLb.text = "00:00"
        seekingTimeLb.sizeToFit()
        //
        failureLb = UILabel()
        failureLb.textColor = .white
        failureLb.text = "网络信号弱，请检查你的网络状态"
        failureLb.font = UIFont(name: kRegularFont, size: 15)
        failureLb.sizeToFit()
        //
        addSubview(seekingProgressView)
        addSubview(seekingTimeLb)
        addSubview(failureLb)
        //
        seekingTimeLb.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        seekingProgressView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(seekingTimeLb.snp.bottom).offset(10)
            make.size.equalTo(CGSize(width: 130, height: 2))
        }
        failureLb.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    func showSeekingHUD(_ value : Float, second : TimeInterval) {
        self.alpha = 1.0
        self.isHidden = false
        isInteractionEnabled = true
        SVProgressHUD.dismiss()
        failureLb.isHidden = true
        seekingTimeLb.isHidden = false
        seekingProgressView.isHidden = false
        seekingProgressView.progress = value
        seekingTimeLb.text = formatDuration(Double(value)*second)
        seekingTimeLb.sizeToFit()
    }
    func showLoadingHUD() {
        if self.isHidden == false && SVProgressHUD.isVisible() { return }
        self.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
        }
        isInteractionEnabled = false
        if isVisableHUD {
            SVProgressHUD.show(withStatus: "Loading...")
        }
        failureLb.isHidden = true
        seekingTimeLb.isHidden = true
        seekingProgressView.isHidden = true
    }
    func showBrightNess(_ progress : Float) {
        self.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
        }
        isInteractionEnabled = true
        if isVisableHUD {
            SVProgressHUD.showProgress(progress, status: "亮度")
        }
        failureLb.isHidden = true
        seekingTimeLb.isHidden = true
        seekingProgressView.isHidden = true
        UIScreen.main.brightness = CGFloat(progress)
    }
    func showFailureHUD(_ str : String) {
        self.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
        }
        isInteractionEnabled = false
        failureLb.isHidden = false
        failureLb.text = str
        SVProgressHUD.dismiss()
        seekingTimeLb.isHidden = true
        seekingProgressView.isHidden = true
    }
    func hide() {
        isInteractionEnabled = true
        SVProgressHUD.dismiss()
        if self.isHidden { return }
        failureLb.isHidden = true
        seekingTimeLb.isHidden = true
        seekingProgressView.isHidden = true
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0.0
        }) { (completion) in
            self.isHidden = true
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class SparkMPVolumnView: MPVolumeView {
    weak var MPButton : UIButton?
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.showsVolumeSlider = false
        self.tag = 2233
        self.initialMPButton()
    }
    
    fileprivate func initialMPButton() {
        self.subviews.forEach { (subV) in
            if subV.isKind(of: UIButton.self) {
                MPButton = subV as? UIButton
            }
        }
        if let btn = MPButton {
            btn.setImage(nil, for: .normal)
            btn.setImage(nil, for: .highlighted)
            btn.setImage(nil, for: .selected)
            btn.bounds = CGRect.zero
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
