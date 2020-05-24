//
//  DateSegment.swift
//  iSolarCloudDBO
//
//  Created by sungrow on 2016/12/12.
//  Copyright © 2016年 kjlink. All rights reserved.
//

import UIKit
import SnapKit

public enum DateSegmentType : Int {
    case day = 0
    case month
    case year
    case total
}

class DateSegment: UIView {
    
    public var selectSegmentIndex: Int = 0
    public var type: DateSegmentType = .day
    public var maximumDate: Date? {
        didSet {
            datePickerView.maximumDate = maximumDate
        }
    }
    public var minimumDate: Date? {
        didSet {
            datePickerView.minimumDate = minimumDate
        }
    }
    public var selectDate: Date? {
        didSet {
            changeShowBtnTitle(selectDate: selectDate)
        }
    }
    
    public var confirmAction: ((_ selectDateStr: String, _ selectSegmentIndex: Int) -> ())?
    
    fileprivate lazy var items: [String] = {
        return [NSLocalizedString("日", comment: ""), NSLocalizedString("月", comment: ""), NSLocalizedString("年", comment: ""), NSLocalizedString("总", comment: "")]
    }()
    fileprivate var segmentControl: UISegmentedControl?
    fileprivate lazy var showDateBtn: UIButton = UIButton()
    fileprivate lazy var previousBtn: UIButton = UIButton()
    fileprivate lazy var nextBtn: UIButton = UIButton()
    fileprivate lazy var shadeView: UIControl = UIControl()
    fileprivate lazy var datePickerView: UIDatePicker = UIDatePicker()
    fileprivate lazy var toolBar: UIView = UIView()
    
    convenience init(type: DateSegmentType, selectSegmentIndex: Int) {
        self.init()
        self.type = type
        self.selectSegmentIndex = selectSegmentIndex
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard datePickerView.subviews.first?.subviews.first?.subviews.count == 3 else {
            return
        }
        datePickerView.subviews.first?.subviews.first?.subviews[1].frame.origin.x = 0
        datePickerView.subviews.first?.subviews.first?.subviews[0].frame.origin.x = 0
        if type == .month {
            datePickerView.subviews.first?.subviews.first?.subviews[0].isHidden = false
            datePickerView.subviews.first?.subviews.first?.subviews[1].isHidden = false
            datePickerView.subviews.first?.subviews.first?.subviews[2].isHidden = true
            datePickerView.subviews.first?.subviews.first?.subviews[1].frame.origin.x += 100
        } else if type == .year {
            datePickerView.subviews.first?.subviews.first?.subviews[0].isHidden = false
            datePickerView.subviews.first?.subviews.first?.subviews[1].isHidden = true
            datePickerView.subviews.first?.subviews.first?.subviews[2].isHidden = true
            datePickerView.subviews.first?.subviews.first?.subviews[0].frame.origin.x += 70
        } else {
           datePickerView.subviews.first?.subviews.first?.subviews[0].isHidden = false
           datePickerView.subviews.first?.subviews.first?.subviews[1].isHidden = false
           datePickerView.subviews.first?.subviews.first?.subviews[2].isHidden = false
        }
    }
}

// MARK:- 初始化控件
extension DateSegment {
    fileprivate func setupUI() {
        backgroundColor = UIColor.blue
        if type == .month {
            items.removeFirst()
        } else if type == .year {
            items.removeFirst()
            items.removeFirst()
        } else if type == .total {
            items.removeFirst()
            items.removeFirst()
            items.removeFirst()
        }
        /// 分段控件
        segmentControl = UISegmentedControl(items: items)
        segmentControl?.tintColor = UIColor.white
        segmentControl?.selectedSegmentIndex = selectSegmentIndex
        segmentControl?.addTarget(self, action: #selector(segmentValueChanged(sender:)), for: .valueChanged)
        addSubview(segmentControl!)
        segmentControl?.snp.makeConstraints({ (make) in
            make.top.equalTo(16)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(28)
        })
        // 按钮 显示当前日期
        addSubview(showDateBtn)
        showDateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        showDateBtn.layer.cornerRadius = 5.0
        showDateBtn.layer.borderColor = UIColor.white.cgColor
        showDateBtn.layer.borderWidth = 1.0
        showDateBtn.addTarget(self, action: #selector(showDateBtnAction(sender:)), for: .touchUpInside)
        showDateBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.segmentControl!.snp.bottom).offset(32)
            make.centerX.equalTo(self.segmentControl!)
            make.width.equalTo(120)
            make.height.equalTo(28)
        }
        /// 前一天按钮
        addSubview(previousBtn)
        previousBtn.setImage(#imageLiteral(resourceName: "calc-left"), for: .normal)
        previousBtn.addTarget(self, action: #selector(previousBtnAction(sender:)), for: .touchUpInside)
        previousBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(showDateBtn)
            make.right.equalTo(showDateBtn.snp.left).offset(-8)
            make.width.equalTo(64)
        }
        /// 后一天按钮
        addSubview(nextBtn)
        nextBtn.setImage(#imageLiteral(resourceName: "calc-right"), for: .normal)
        nextBtn.addTarget(self, action: #selector(nextBtnAction(sender:)), for: .touchUpInside)
        nextBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(showDateBtn)
            make.left.equalTo(showDateBtn.snp.right).offset(8)
            make.width.equalTo(64)
        }
        /// 遮罩层
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.addSubview(shadeView)
        shadeView.isHidden = true
        shadeView.addTarget(self, action: #selector(shadeViewAction(sender:)), for: .touchUpInside)
        shadeView.backgroundColor = UIColor(white: 0.6, alpha: 0.4)
        shadeView.snp.makeConstraints { (make) in
            make.edges.equalTo(keyWindow!)
        }
        
        datePickerView.backgroundColor = UIColor.white
        datePickerView.datePickerMode = .date
        shadeView.addSubview(datePickerView)
        datePickerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(keyWindow!)
            make.bottom.equalTo(keyWindow!).offset(284)
            make.height.equalTo(240)
        }
        
        shadeView.addSubview(toolBar)
        toolBar.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
        toolBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(datePickerView)
            make.bottom.equalTo(datePickerView.snp.top)
            make.height.equalTo(44)
        }
        let cancelBtn = UIButton(type: .custom)
        toolBar.addSubview(cancelBtn)
        cancelBtn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
        cancelBtn.addTarget(self, action: #selector(shadeViewAction(sender:)), for: .touchUpInside)
        cancelBtn.setTitleColor(UIColor.blue, for: .normal)
        cancelBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(toolBar)
            make.left.equalTo(toolBar).offset(16)
            make.width.equalTo(120)
        }
        
        let confirmBtn = UIButton(type: .custom)
        toolBar.addSubview(confirmBtn)
        confirmBtn.setTitle(NSLocalizedString("确认", comment: ""), for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction(sender:)), for: .touchUpInside)
        confirmBtn.setTitleColor(UIColor.blue, for: .normal)
        confirmBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(toolBar)
            make.right.equalTo(toolBar).offset(-16)
            make.width.equalTo(120)
        }
        
        /// 初始化数据
        type = DateSegmentType(rawValue: selectSegmentIndex)!
        datePickerView.maximumDate = Date()
        selectDate = Date()
        segmentValueChanged(sender: segmentControl!)
    }
}

// MARK:- 事件监听
extension DateSegment {
    @objc fileprivate func segmentValueChanged(sender: UISegmentedControl) {
        selectSegmentIndex = sender.selectedSegmentIndex
        showDateBtn.isHidden = false
        previousBtn.isHidden = false
        nextBtn.isHidden = false
        switch sender.selectedSegmentIndex {
        case 0:
            type = .day
            break
        case 1:
            type = .month
            break
        case 2:
            type = .year
            break
        case 3:
            showDateBtn.isHidden = true
            previousBtn.isHidden = true
            nextBtn.isHidden = true
            break
        default:
            break
        }
        changeShowBtnTitle(selectDate: selectDate)
        clouserAction()
    }
    
    @objc fileprivate func previousBtnAction(sender: UIButton) {
        print(#function)
        guard selectDate != nil else {
            return
        }
        neighborDate(toDate: selectDate, direction: false, type: selectSegmentIndex)
        clouserAction()
    }
    
    @objc fileprivate func nextBtnAction(sender: UIButton) {
        print(#function)
        guard selectDate != nil else {
            return
        }
        neighborDate(toDate: selectDate, direction: true, type: selectSegmentIndex)
        clouserAction()
    }
    
    fileprivate func neighborDate(toDate: Date?, direction: Bool, type: Int) {
        guard toDate != nil else {
            return
        }
        let diff = direction == true ? 1 : -1
        var comps = DateComponents()
        switch type {
        case 0:
            comps.day = diff
            break
        case 1:
            comps.month = diff
            break
        case 2:
            comps.year = diff
            break
        default:
            break
        }
        let calendar = Calendar(identifier: .gregorian)
        selectDate = calendar.date(byAdding: comps, to: toDate!)
    }
    
    @objc fileprivate func showDateBtnAction(sender: UIButton) {
        print(#function)
        shadeView.isHidden = false
        self.setNeedsLayout()
        UIView.animate(withDuration: 0.25) {
            () -> () in
            self.datePickerView.transform = CGAffineTransform(translationX: 0, y: -284)
            self.toolBar.transform = CGAffineTransform(translationX: 0, y: -284)
        }
    }
    
    @objc fileprivate func shadeViewAction(sender: UIButton) {
        print(#function)
        UIView.animate(withDuration: 0.25, animations: {
            () -> Void in
            self.datePickerView.transform = CGAffineTransform.identity
            self.toolBar.transform = CGAffineTransform.identity
        }, completion: {
           (_) -> () in
            self.shadeView.isHidden = true
        });
    }
    
    fileprivate func changeShowBtnTitle(selectDate: Date?) {
        guard selectDate != nil else {
            return
        }
        datePickerView.setDate(selectDate!, animated: true)
        let dateFormatter = DateFormatter()
        if type == .day {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        } else if type == .month {
            dateFormatter.dateFormat = "yyyy-MM"
        } else if type == .year {
            dateFormatter.dateFormat = "yyyy"
        }
        let selectDateStr = dateFormatter.string(from: selectDate!)
        showDateBtn.setTitle(selectDateStr, for: .normal)
        changeDateBtnEnable()
    }
    
    fileprivate func changeDateBtnEnable() {
        guard selectDate != nil else {
            return
        }
        if maximumDate == nil {
            maximumDate = Date()
        }
        if minimumDate == nil {
            minimumDate = Date(timeIntervalSince1970: 0)
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "dd"
        let selectDay = fmt.string(from: selectDate!)
        let maxDay = fmt.string(from: maximumDate!)
        let minDay = fmt.string(from: minimumDate!)
        
        fmt.dateFormat = "MM"
        let selectMonth = fmt.string(from: selectDate!)
        let maxMonth = fmt.string(from: maximumDate!)
        let minMonth = fmt.string(from: minimumDate!)
        
        fmt.dateFormat = "yyyy"
        let selectYear = fmt.string(from: selectDate!)
        let maxYear = fmt.string(from: maximumDate!)
        let minYear = fmt.string(from: minimumDate!)
        
        switch selectSegmentIndex {
        case 0:
            nextBtn.isEnabled = (Double(maxYear)! > Double(selectYear)!) || (Double(maxYear)! >= Double(selectYear)! && Double(maxMonth)! > Double(selectMonth)!) || (Double(maxYear)! >= Double(selectYear)! && Double(maxMonth)! >= Double(selectMonth)! && Double(maxDay)! > Double(selectDay)!)
            previousBtn.isEnabled = (Double(selectYear)! > Double(minYear)!) || (Double(selectYear)! >= Double(minYear)! && Double(selectMonth)! > Double(minMonth)!) || (Double(selectYear)! >= Double(minYear)! && Double(selectMonth)! >= Double(minMonth)! && Double(selectDay)! > Double(minDay)!)
            break
        case 1:
            nextBtn.isEnabled = (Double(maxYear)! > Double(selectYear)!) || (Double(maxYear)! >= Double(selectYear)! && Double(maxMonth)! > Double(selectMonth)!)
            previousBtn.isEnabled = (Double(selectYear)! > Double(minYear)!) || (Double(selectYear)! >= Double(minYear)! && Double(selectMonth)! > Double(minMonth)!)
            break
        case 2:
            nextBtn.isEnabled = (Double(maxYear)! > Double(selectYear)!)
            previousBtn.isEnabled = (Double(selectYear)! > Double(minYear)!)
            break
        default:
            break
        }
        
    }
    
    @objc fileprivate func confirmBtnAction(sender: UIButton) {
        print(#function)
        selectDate = datePickerView.date
        shadeViewAction(sender: sender)
        clouserAction()
    }
    
    @objc fileprivate func clouserAction() {
        guard selectDate != nil else {
            return
        }
        let dateFormatter = DateFormatter()
        if type == .day {
            dateFormatter.dateFormat = "yyyyMMdd"
        } else if type == .month {
            dateFormatter.dateFormat = "yyyyMM"
        } else if type == .year {
            dateFormatter.dateFormat = "yyyy"
        }
        let selectDateStr = dateFormatter.string(from: selectDate!)
        if let confirmAction = confirmAction {
            confirmAction(selectDateStr, selectSegmentIndex)
        }
    }
}
