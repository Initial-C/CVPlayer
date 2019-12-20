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
}
let MTVideoQualityStrs = ["ld", "sd", "hd"]
class MTPlayerView: UIView {
    weak var delegate : MTPlayerViewDelegate?
    fileprivate lazy var contentView : UIView = {
        let content = UIView()
        content.backgroundColor = UIColor.init("#ffcc00")
        content.clipsToBounds = true
        return content
    }()
    fileprivate lazy var hudView : MTSmartHUDView = {
        let hud = MTSmartHUDView()
        return hud
    }()
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
    // MARK: bottom
    fileprivate lazy var bottomBackImV : UIImageView = {
        let imv = UIImageView.init(image: UIImage(named: "bg_player_gradient_below"))
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
        progressV.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.5)
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
        lb.text = "视频标题"
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
        let btnNames = ["1.0x", "1.25x", "1.5x", "2.0x"]
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
        }
    }
    /// 设置全屏
    var isFullScreen : Bool = false {
        didSet {
            fullScreenBtn.isHidden = isFullScreen
            rateBtn.isHidden = !isFullScreen
            qualityBtn.isHidden = rateBtn.isHidden
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
            titleLb.isHidden = !isFullScreen
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
    // MARK: 私有api
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
    fileprivate var isCancleHideMenu : Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        self.clipsToBounds = true
        let menuTap = UITapGestureRecognizer.init(target: self, action: #selector(tapMenus))
        self.addGestureRecognizer(menuTap)
        addSubview(contentView)
        addSubview(hudView)
        contentView.addSubview(audioView)
        contentView.addSubview(bottomView)
        contentView.addSubview(halfBoard)
        contentView.addSubview(topView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(backBtn)
        contentView.addSubview(moreBtn)
        contentView.addSubview(titleLb)
        setupLayout()
        setupSlider()
        //
        delayHideMenus()
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
        hudView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
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
            bufferFullScreenRConst = make.right.equalTo(qualityBtn.snp.left).offset(-8).priority(.medium).constraint
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
    //TODO: 滑动
    @objc fileprivate func changeProgress(_ slider : UISlider) {
        seekingHandler(slider.value)
    }
    @objc fileprivate func progressSliderTouchBegan(_ slider : UISlider) {
        isDraging = true // 用于监听判断
        isCancleHideMenu = true
        appearMenus(true)
    }
    @objc fileprivate func progressSliderValueChanged(_ slider : UISlider) {
        sliderTouchBegan()
    }
    @objc fileprivate func progressSliderTouchEnded(_ slider : UISlider) {
        seekingHandler(slider.value)
        sliderTouchEnded()
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
        if let delegate = delegate {
            delegate.playerViewSeekAction(value)
        }
    }
    fileprivate func sliderTouchEnded() {
        isDraging = false
        if let delegate = delegate {
            delegate.playerViewLastDragAction(progressSlider.value)
        }
        delayHideMenus()
        hudView.hide()
    }
    fileprivate func sliderTouchBegan() {
        hudView.showSeekingHUD(progressSlider.value, second: 320) // TODO: 同步进度时间
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
        isCancleHideMenu = false
        appearMenus(!isShowMenu)
    }
    // 显示/隐藏菜单
    @objc fileprivate func autoHideMenus() {
        print("隐藏")
        appearMenus(false)
    }
    @objc fileprivate func cancelAutoHideMenus() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoHideMenus), object: nil)
    }
    @objc fileprivate func delayHideMenus() {
        perform(#selector(autoHideMenus), afterDelay: 5.0)
    }
    @objc fileprivate func appearMenus(_ isShow : Bool) {
        // 取消自动隐藏任务
        cancelAutoHideMenus()
        //
        if isShow == isShowMenu {
            isShowMenu = isShow
            if isShow && !isCancleHideMenu {
                delayHideMenus()
            }
            return
        }
        if isShow {
            if isCancleHideMenu { // 取消自动隐藏
                isCancleHideMenu = false
            } else {
                delayHideMenus()
            }
        } else {
            if isCancleHideMenu { return }
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
    /// 播放/暂停
    @objc fileprivate func actionPlay(_ btn : UIButton) {
        btn.isSelected = !btn.isSelected
        if let delegate = delegate {
            delegate.playerViewPlayAction(btn)
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
        if let delegate = delegate {
            delegate.playerViewRateAction(btn.tag)
        }
        actionShowHalfBoard(nil)
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        self.alpha = 0.0
        SVProgressHUD.setMaxSupportedWindowLevel(UIWindow.Level.statusBar)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setBackgroundColor(UIColor.init("#333333db"))
        SVProgressHUD.setForegroundColor(.white)
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
        SVProgressHUD.dismiss()
        failureLb.isHidden = true
        seekingTimeLb.isHidden = false
        seekingProgressView.isHidden = false
        seekingProgressView.progress = value
        seekingTimeLb.text = formatDuration(second)
        seekingTimeLb.sizeToFit()
    }
    func showLoadingHUD(_ isShow : Bool) {
        self.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
        }
        SVProgressHUD.show(withStatus: "Loading...")
        failureLb.isHidden = true
        seekingTimeLb.isHidden = true
        seekingProgressView.isHidden = true
    }
    func showFailureHUD(_ str : String) {
        self.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
        }
        failureLb.isHidden = false
        failureLb.text = str
        SVProgressHUD.dismiss()
        seekingTimeLb.isHidden = true
        seekingProgressView.isHidden = true
    }
    func hide() {
        SVProgressHUD.dismiss()
        failureLb.isHidden = true
        seekingTimeLb.isHidden = true
        seekingProgressView.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {
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

