//
//  ViewController.swift
//  DateSegmentViewDemo
//
//  Created by kjlink on 2016/12/14.
//  Copyright © 2016年 kjlink. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate lazy var dateSegmentView = DateSegment(type: .day, selectSegmentIndex: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.addSubview(dateSegmentView)
        dateSegmentView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom);
            make.left.right.equalTo(self.view)
            make.height.equalTo(130)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

