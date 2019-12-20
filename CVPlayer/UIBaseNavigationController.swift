//
//  UIBaseNavigationController.swift
//  CVPlayer
//
//  Created by YAHAHA on 2019/12/20.
//  Copyright © 2019 IMUST. All rights reserved.
//

import UIKit

class UIBaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.children.count > 1
    }
    
    override var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.portrait
    }
    
    
    
    

}
