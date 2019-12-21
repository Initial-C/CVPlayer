//
//  Nibloadable.swift
//  MSinger
//
//  Created by InitialC on 2017/12/1.
//  Copyright © 2017年 InitialC. All rights reserved.
//

import Foundation

protocol Nibloadable {
    
}

extension Nibloadable where Self : UIView {
    /*
     static func loadNib(_ nibNmae :String = "") -> Self{
     let nib = nibNmae == "" ? "\(self)" : nibNmae
     return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)?.first as! Self
     }
     */
    static func loadNib(_ nibNmae :String? = nil) -> Self{
        return Bundle.main.loadNibNamed(nibNmae ?? "\(self)", owner: nil, options: nil)?.first as! Self
    }
}
