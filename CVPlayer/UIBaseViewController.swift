//
//  UIBaseViewController.swift
//  CVPlayer
//
//  Created by YAHAHA on 2019/12/20.
//  Copyright © 2019 IMUST. All rights reserved.
//

import UIKit
import YYUtility

class UIBaseViewController: UIViewController {

    var isHiddenNavigationBar = false
    var interactivePopEnable = false {
        didSet {
            if interactivePopEnable {
                self.view.removeGestureRecognizer(tempPan)
            } else {
                self.view.addGestureRecognizer(tempPan)
            }
        }
    }
    var isHiddenStatusBar = false {
        didSet {
            if self.responds(to: #selector(setNeedsStatusBarAppearanceUpdate)) {
                _ = self.prefersStatusBarHidden
                self.perform(#selector(setNeedsStatusBarAppearanceUpdate))
            }
        }
    }
    var statusbarStyle : UIStatusBarStyle = .default {
        didSet {
            if self.responds(to: #selector(setNeedsStatusBarAppearanceUpdate)) {
                _ = self.preferredStatusBarStyle
                self.perform(#selector(setNeedsStatusBarAppearanceUpdate))
            }
        }
    }
    var statusbarAnim : UIStatusBarAnimation = .fade {
        didSet {
            if self.responds(to: #selector(setNeedsStatusBarAppearanceUpdate)) {
                _ = self.preferredStatusBarUpdateAnimation
                self.perform(#selector(setNeedsStatusBarAppearanceUpdate))
            }
        }
    }
    fileprivate lazy var tempPan : UIPanGestureRecognizer = {
        let target = self.navigationController?.interactivePopGestureRecognizer?.delegate
        let pan = UIPanGestureRecognizer.init(target: target, action: nil)
        return pan
    }()
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusbarStyle
    }
    override var prefersStatusBarHidden: Bool {
        return isHiddenStatusBar
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusbarAnim
    }
    override func viewDidLoad() {
        self.statusbarStyle = .default
        self.statusbarAnim = .fade
        self.interactivePopEnable = true
        self.isHiddenNavigationBar = false
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if self.navigationController?.isNavigationBarHidden != isHiddenNavigationBar {
            self.navigationController?.setNavigationBarHidden(isHiddenNavigationBar, animated: animated)
        }
        super.viewWillAppear(animated)
    }
    
    deinit {
        print("释放了控制器==\(self.className())")
    }

}
