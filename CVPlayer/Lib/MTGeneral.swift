//
//  MTGeneral.swift
//  Mentor
//
//  Created by YAHAHA on 2019/5/15.
//  Copyright © 2019 馒头科技. All rights reserved.
//

import Foundation
import UIKit
import YYWebImage
import ObjectMapper
import UserNotifications

// MARK: base internet
//private let TestURL = "http://192.168.8.111:8002/"
//private let BaseURL = "http://120.27.145.26:8000/"
let kCNotificationStatusBarClickKey = "StatusBarDidClickedNotificationName" // statusBar点击
let idNumber = UIDevice.current.identifierForVendor?.uuidString //设备udid
//
typealias CModelProtocol = ObjectMapper.Mappable
typealias CMMappable = ObjectMapper.ImmutableMappable
typealias CMapper = ObjectMapper.Mapper
// font
let kSemiboldFont = "PingFangSC-Semibold"
let kMediumFont = "PingFangSC-Medium"
let kRegularFont = "PingFangSC-Regular"
let kHeavyFont = "PingFangSC-Heavy"
// color
let kMainColor = UIColor.init("#44c08c")
// size
let kZWScreenW = UIScreen.main.bounds.size.width
let kZWScreenH = UIScreen.main.bounds.size.height
let kZWScreenBounds = UIScreen.main.bounds
let kIsIPhoneXSpec = kZWScreenH/kZWScreenW > 1.8
let kZWNavH : CGFloat = kIsIPhoneXSpec ? 88 : 64
let kZWTabBarH : CGFloat = kIsIPhoneXSpec ? 83 : 49
let kIsSpecNavInset : CGFloat = kIsIPhoneXSpec ? 44 : 20
let kIsSpecNavMargin : CGFloat = kIsIPhoneXSpec ? 44 : 0
let kIsSpecTabMargin : CGFloat = kIsIPhoneXSpec ? 34 : 0
let kZWCenter = CGPoint.init(x: kZWScreenW * 0.5, y: kZWScreenH * 0.5)
let kSizeRatio = UIScreen.main.scale
// ratio
let kIPhoneHeightRatio = kZWScreenH / 667
let kIPhoneWidthRatio = kZWScreenW / 375
let kIPhoneXWidthRatio = kIsIPhoneXSpec ? 1.0 : kIPhoneWidthRatio
let kIPhoneXHeightRatio = kIsIPhoneXSpec ? 1.0 : kIPhoneHeightRatio

func kConvertHeight(_ h : CGFloat) -> CGFloat {
    return kIPhoneXHeightRatio * h
}
func kConvertWidth(_ w : CGFloat) -> CGFloat {
    return kIPhoneXWidthRatio * w
}
func kConvertX(_ x : CGFloat) -> CGFloat {
    return kIPhoneXWidthRatio * x
}
func kConvertY(_ y : CGFloat) -> CGFloat {
    return kIPhoneXHeightRatio * y
}

let kIPhoneUsefulHeight = kZWScreenH - kIsSpecNavMargin - kIsSpecTabMargin

// 自偏移ScrollView
func setupAutomatilly(_ scrollView : UIScrollView, _ vc : UIViewController) {
    if #available(iOS 11, *) {
        scrollView.contentInsetAdjustmentBehavior = .never
    } else {
        vc.automaticallyAdjustsScrollViewInsets = false
    }
}
// 原图
func getOriImage(_ image: UIImage) -> UIImage {
    let newImage = image.withRenderingMode(.alwaysOriginal)
    return newImage
}
// 通用高斯模糊
func getBlurImage(_ image: UIImage, _ radius : CGFloat?, _ blackRadius : CGFloat?, _ isWhiteTintColor : Bool) -> UIImage {
    let img = image.byBlurRadius(radius ?? 5.0, tintColor: UIColor.init(white: isWhiteTintColor ? 1.0 : 0.0, alpha: blackRadius ?? 0.1), tintMode: CGBlendMode.normal, saturation: 1, maskImage: nil)
    return img!
}
func getUniversalBlurView(_ rect: CGRect, _ style: UIBlurEffect.Style) -> UIVisualEffectView {
    let beffect = UIBlurEffect.init(style: style)
    let visualEftView = UIVisualEffectView.init(frame: rect)
    visualEftView.effect = nil
    UIView.animate(withDuration: 0.01) {
        visualEftView.effect = beffect
    }
    
    // 高斯模糊字
//        let labelss = UILabel.init(frame: CGRectSwInLine(100, 200, 200, 50))
//        labelss.text = "爱你一万年"
//        labelss.font = UIFont.boldSystemFont(ofSize: 22)
    let vibrancyEffect = UIVibrancyEffect(blurEffect: beffect)
    let vibrancyView = UIVisualEffectView(effect:vibrancyEffect)
    vibrancyView.frame = rect
//        vibrancyView.contentView.addSubview(labelss)
    visualEftView.contentView.addSubview(vibrancyView)
    return visualEftView
}
// 导航栏处理
func hideNavigationShadowImage(_ isHidden: Bool, _ view : UIView) {
    if let shadowImage = findShadowImageView(view) {
        shadowImage.isHidden = isHidden
    }
}
func findShadowImageView(_ view: UIView) -> UIImageView?{
    if view.isKind(of: UIImageView.self) && view.bounds.height <= 1.0 {
        return view as? UIImageView
    }
    for subview in view.subviews {
        if let imageView = findShadowImageView(subview) {
            return imageView
        }
    }
    return nil
}
func setNavigationbarColorClear(_ isClear: Bool, _ naviBar: UIView, _ backImg : UIImage?) {
    let navColor = isClear ? UIColor.clear : UIColor.black
    var navImg = UIImage.init(color: navColor)
    if let back = backImg {
        navImg = back
    }
    (naviBar as? UINavigationBar)?.setBackgroundImage(navImg, for: .default)
    hideNavigationShadowImage(isClear, naviBar)
}
// 判空字符串
func isSpaceNULLString(_ text: String?) -> Bool {
    guard let text = text else { return true }
    let tempName = text.replacingOccurrences(of: " ", with: "")
    return tempName == ""
}
// 字符串制表符处理
func replaceTabsString(_ text : String) -> String {
    var txt = text
    txt = txt.replacingOccurrences(of: " ", with: "")
    txt = txt.replacingOccurrences(of: "\r\n", with: "")
    txt = txt.replacingOccurrences(of: "\n", with: "")
    txt = txt.replacingOccurrences(of: "\t", with: "")
    return txt
}
/// 转换为正确的图url
func translateCharacterWithURLString(_ before : String) -> String {
    let newUrl = before.removingPercentEncoding
    let newUrlStr = newUrl?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    return newUrlStr
}
/// 判断是否正确url
func isEnableURL(_ urlString : String) -> Bool {
    guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
        return false
    }
    let results = detector.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
    return results.count > 0
}
/// 获取当前时间戳
func getNowTimeStamp() -> Int {
    let time = Date.init()
    let nowStamp = time.timeIntervalSince1970
    return Int(nowStamp)
}
// 13位
func getNowTimeStampMoreBit() -> String {
    let time = Date.init()
    let nowStamp = time.timeIntervalSince1970 * 1000
    return String(format: "%.lf", nowStamp)
}
//MARK: 获取本地当前时间---->年月日时分秒

func getCurrentTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    let locationString = dateFormatter.string(from: Date())
//    let timeSam = Int(Date().timeIntervalSince1970)
//    print("hhhhhh当前的时间戳--->\(timeSam)---->当前的时间---->\(locationString)")
    return locationString
    
}
// 格式化秒
func formatDuration(_ second : TimeInterval) -> String {
    let date = Date.init(timeIntervalSince1970: second)
    let dateFormatter = DateFormatter.init()
    dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
    if second / 3600 >= 1 {
        dateFormatter.dateFormat = "H:mm:ss"
    } else {
        dateFormatter.dateFormat = "mm:ss"
    }
    return dateFormatter.string(from: date)
}
/// 获取最新的一个时间与之前的一个时间的差值
///
/// - Parameters:
///   - from: 时间, 比compare晚的时间
///   - compare: 想要比较的时间
/// - Returns: 间隔秒钟
func getTimeDifferentFrom(from: String?, compare: String) -> Int {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current//TimeZone.init(identifier: "Asia/Beijing")//设置时区
//    print("hhhhhh当前时区--->\(TimeZone.current)---->\(NSTimeZone.system)")
    let dateModel = dateFormatter.date(from: compare)//按照格式设置传入的date时间
    let timeModel = NSString.init(format: "%ld", Int(dateModel!.timeIntervalSince1970))//计算传入时间的时间戳
    let currentTime = from ?? getCurrentTime()
    let dateNow = dateFormatter.date(from: currentTime)
    let timeNow = NSString.init(format: "%ld", Int(dateNow!.timeIntervalSince1970))
    //计算当前时间的时间戳
    let time = abs(timeNow.integerValue - timeModel.integerValue) //计算时差j绝对值
    return time
}
// 判断用户是否允许接收通知
func isUserNotificationEnable(_ completionHandler : @escaping ((_ enable : Bool)->Void)){
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            switch setting.authorizationStatus {
            case .authorized:
                completionHandler(true)
                break
            default:
                completionHandler(false)
                break
            }
        }
    } else {
        var isEnable = false
        if let setting = UIApplication.shared.currentUserNotificationSettings {
            isEnable = setting.types != UIUserNotificationType.init(rawValue: 0)
        }
        completionHandler(isEnable)
    }
}
// 去设置打开通知
func goToAppSystemSetNotification() {
    if let url = URL.init(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
// 通用上下拉刷新(动画)
func setupRefreshViewWith(_ images : [UIImage]?,_ refreshingImgs : [UIImage]?, _ pullingImgs : [UIImage]?, _ superVC: UIViewController, _ tbView : UIScrollView,newAction: Selector?, moreAction: Selector?) {
    
    if let newAct = newAction {
        let header = MJRefreshGifHeader(refreshingTarget: superVC, refreshingAction: newAct)
        header?.setTitle("下拉可以刷新", for: .idle)
        header?.setTitle("松开立即刷新", for: .pulling)
        header?.setTitle("没有更多数据了", for: .noMoreData)
        header?.setTitle("加载中", for: .refreshing)
        header?.setImages(images, for: MJRefreshState.idle)
        header?.setImages(pullingImgs, for: MJRefreshState.pulling)
        header?.setImages(refreshingImgs, for: MJRefreshState.refreshing)
        header?.labelLeftInset = 6.0
        header?.pullingPercent = 0.8
        header?.stateLabel.font = UIFont.systemFont(ofSize: 13)
        header?.stateLabel.textColor = UIColor.init("#333")
//        header?.stateLabel.isHidden = true
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.isAutomaticallyChangeAlpha = true
        tbView.mj_header = header
    }
    
    if let moreAct = moreAction {
        let footer = MJRefreshAutoNormalFooter.init(refreshingTarget: superVC, refreshingAction: moreAct)
        footer?.isRefreshingTitleHidden = true
        footer?.setTitle("", for: MJRefreshState.idle)
        footer?.setTitle("已经全部加载完毕", for: .noMoreData)
        footer?.isAutomaticallyHidden = true
        tbView.mj_footer = footer
    }
}
// 获取当前控制器
func getCurrentVC() -> UIViewController {
    let rootViewController = UIApplication.shared.keyWindow?.rootViewController
    let currentVC = getCurrentFrom(rootViewController!)
    return currentVC
}
func getCurrentFrom(_ rootVC : UIViewController) -> UIViewController {
    var rootVCC = rootVC
    var currentVC : UIViewController
    if rootVC.presentedViewController != nil {
        rootVCC = rootVC.presentedViewController!
    }
    if rootVCC.isKind(of: UITabBarController.self) {
        currentVC = getCurrentFrom((rootVCC as! UITabBarController).selectedViewController!)
    } else if rootVCC.isKind(of: UINavigationController.self){
        currentVC = getCurrentFrom((rootVCC as! UINavigationController).visibleViewController!)
    } else {
        currentVC = rootVCC;
    }
    return currentVC
}

/// 比较时间是否符合在某个时间段内
///
/// - Parameters:
///   - startTime: 开始时间 格式必须为时间戳
///   - endTime: 结束时间 格式同上
/// - Returns: 是否在时间段内
func validateTime(_ startTime : String, _ endTime : String) -> Bool {
    let now = Date.init().timeIntervalSince1970
    let start = TimeInterval(startTime)!
    let end = TimeInterval(endTime)!
    return (now > start && now < end)
    
}

/// 根据字符串/url获取二维码
func getQRCode(_ str : String) -> UIImage? {
    let filter = CIFilter.init(name: "CIQRCodeGenerator")
    filter?.setDefaults()
    let data = str.data(using: .utf8)
    filter?.setValue(data, forKey: "inputMessage")
    if let image = filter?.outputImage {
        return UIImage.init(ciImage: image)
    } else {
        return nil
    }
}

// MARK: 全屏
extension UIInterfaceOrientation {
    var orientationMask: UIInterfaceOrientationMask {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return .all
        }
    }
}

extension UIInterfaceOrientationMask {
    
    var isLandscape: Bool {
        switch self {
        case .landscapeLeft, .landscapeRight, .landscape: return true
        default: return false
        }
    }
    
    var isPortrait: Bool {
        switch self {
        case . portrait, . portraitUpsideDown: return true
        default: return false
        }
    }
    
}
func setupFullScreen(_ isFull : Bool) {
    _ = isFull ? UIRotateUtils.shared.rotateToLandscape() : UIRotateUtils.shared.rotateToPortrait()
}

// MARK: 负责处理全屏
class UIRotateUtils {
    
    static let shared = UIRotateUtils()
    
    private var currentDevice: UIDevice {
        return UIDevice.current
    }
    
    /// 方向枚举
    enum Orientation {
        
        case portrait
        case portraitUpsideDown
        case landscapeRight
        case landscapeLeft
        case unknown
        
        var mapRawValue: Int {
            switch self {
            case .portrait: return UIInterfaceOrientation.portrait.rawValue
            case .portraitUpsideDown: return UIInterfaceOrientation.portraitUpsideDown.rawValue
            case .landscapeRight: return UIInterfaceOrientation.landscapeRight.rawValue
            case .landscapeLeft: return UIInterfaceOrientation.landscapeLeft.rawValue
            case .unknown: return UIInterfaceOrientation.unknown.rawValue
            }
        }
        
    }
    
    private let unicodes: [UInt8] =
        [
            111,// o -> 0
            105,// i -> 1
            101,// e -> 2
            116,// t -> 3
            114,// r -> 4
            110,// n -> 5
            97  // a -> 6
    ]
    
    private lazy var key: String = {
        return [
            self.unicodes[0],// o
            self.unicodes[4],// r
            self.unicodes[1],// i
            self.unicodes[2],// e
            self.unicodes[5],// n
            self.unicodes[3],// t
            self.unicodes[6],// a
            self.unicodes[3],// t
            self.unicodes[1],// i
            self.unicodes[0],// o
            self.unicodes[5] // n
            ].map {
                return String(Character(Unicode.Scalar ($0)))
            }.joined(separator: "")
    }()
    
    /// 旋转到竖屏
    ///
    /// - Parameter orientation: 方向枚举
    func rotateToPortrait(_ orientation: Orientation = .portrait) {
        rotate(to: orientation)
    }
    
    /// 旋转到横屏
    ///
    /// - Parameter orientation: 方向枚举
    func rotateToLandscape(_ orientation: Orientation = .landscapeRight) {
        rotate(to: orientation)
    }
    
    /// 旋转到指定方向
    ///
    /// - Parameter orientation: 方向枚举
    func rotate(to orientation: Orientation) {
        currentDevice.setValue(Orientation.unknown.mapRawValue, forKey: key) // 👈 需要先设置成 unknown 哟
        currentDevice.setValue(orientation.mapRawValue, forKey: key)
    }
}
