//
//  ViewController.swift
//  CVPlayer
//
//  Created by YAHAHA on 2019/8/13.
//  Copyright © 2019 IMUST. All rights reserved.
//

import UIKit

private let studioStr = "$http://cn7.7639616.com/hls/20191126/eebb68accf60bff8adffe64c7ac68219/1574769804/index.m3u8$http://cn6.7639616.com/hls/20191126/5732e6c5fd2ba9580797bbac42bc3afa/1574769508/index.m3u8$http://cn6.7639616.com/hls/20191126/4a8f0703560fbf62737a5412e621106c/1574769796/index.m3u8$http://cn6.7639616.com/hls/20191126/92cd1cc6dc8b17f5af5e9ef4e4646f31/1574770052/index.m3u8$http://cn6.7639616.com/hls/20191127/dda0147253cc5614c1ee9dc07db53d4d/1574855943/index.m3u8$http://cn6.7639616.com/hls/20191127/cf70a07ea78d7a49bcb8c8ad143509cb/1574856214/index.m3u8$http://cn7.7639616.com/hls/20191202/6130d5894de49730b8efd518726af6d0/1575289774/index.m3u8$http://cn7.7639616.com/hls/20191202/5764ab97bf8d77657045a9cce212602c/1575290626/index.m3u8$http://cn7.7639616.com/hls/20191202/32bbb815423d075d4fa7dc5709543d70/1575290909/index.m3u8$http://cn7.7639616.com/hls/20191202/d1ba87034a6c2cafc04c426c2d36fa9c/1575290072/index.m3u8$http://cn7.7639616.com/hls/20191202/7e13c54c25302df4b91ac796630970e0/1575290345/index.m3u8$http://cn6.7639616.com/hls/20191203/53260ec7a4b66e59819a294b479f7431/1575374276/index.m3u8$http://cn6.7639616.com/hls/20191203/bcf2643ea292d4c6dc4d4a97a307bcfe/1575374517/index.m3u8$http://cn6.7639616.com/hls/20191204/b6de5e37911e398ced3222ac05bac6cd/1575461531/index.m3u8$http://cn6.7639616.com/hls/20191204/5e664c13bb769d14505ac7bde3ee4c5f/1575461816/index.m3u8$http://cn6.7639616.com/hls/20191205/22cd2b1ea49a2e23c5bced92209dbbd1/1575552029/index.m3u8$http://cn7.7639616.com/hls/20191205/916a0b5ae4898cf8d8711efae0a4c3fe/1575552019/index.m3u8$http://cn7.7639616.com/hls/20191210/b740ab52eddddd94362c6f115295147c/1575981959/index.m3u8$http://cn7.7639616.com/hls/20191210/705ead2f03fb42b5486e02ce37b60f3c/1575982216/index.m3u8$http://cn6.7639616.com/hls/20191210/7207e4d9b553eaf7dc28a6b48c4a9650/1575983199/index.m3u8$http://cn6.7639616.com/hls/20191210/4aad8f826a12afd1344ebcbea7fe5e16/1575983939/index.m3u8$http://cn7.7639616.com/hls/20191211/dc5da261da7723f499e096ba560f6b1a/1576072148/index.m3u8$http://cn7.7639616.com/hls/20191211/13717fa114b4d5acd5dcef6b80680c63/1576071284/index.m3u8$http://cn6.7639616.com/hls/20191211/18f9775f5c6a908a2e4f572326a29edf/1576071251/index.m3u8$http://cn7.7639616.com/hls/20191211/61e986ad5fad7b64958388200fae21e8/1576071659/index.m3u8$http://cn6.7639616.com/hls/20191211/60b8547d81f49a38b9b15a628cc2401d/1576072150/index.m3u8$http://cn6.7639616.com/hls/20191211/c5becb0622315154011b5eb6a8a50068/1576071720/index.m3u8$http://cn7.kankia.com/hls/20191216/1502d3f4cab18c1b420df1eb832460c8/1576499388/index.m3u8$http://cn7.kankia.com/hls/20191216/b25ca0acefce9290b34ff6039bff53da/1576499044/index.m3u8$http://cn7.kankia.com/hls/20191216/54f4d7c9b2c0ff2ad2fa16f47d47787b/1576509615/index.m3u8$http://cn7.kankia.com/hls/20191216/ce7c7408bf80ac15d23360d1be7f7673/1576509006/index.m3u8$http://cn6.kankia.com/hls/20191217/9172fdc56e0f7c5808a5971cdf037d54/1576547595/index.m3u8$http://cn6.kankia.com/hls/20191217/d6408120a4317155193aca5b3b5578ce/1576546261/index.m3u8"
private let studios : [String] = {
    let arr = studioStr.components(separatedBy: "$")
    return arr
}()
class ViewController: UIBaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Eromanga"
        tableView.tableFooterView = UIView()
        tableView.sectionFooterHeight = 0.0
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "maincell")
        setupAutomatilly(tableView, self)
        if #available(iOS 11, *) {
            tableView.estimatedRowHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studios.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "maincell", for: indexPath)
        cell.textLabel?.text = "第\(indexPath.row + 1)集"
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let vc = MTVideoRoomController.shared
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}

