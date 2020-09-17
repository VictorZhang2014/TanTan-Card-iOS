//
//  SPMainCardViewController.swift
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/6.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

import UIKit
import SnapKit

@objc(SPMainCardViewController)
class SPMainCardViewController: SPBaseViewController {

    private let customNavigationBarView = UIView()
    private let searchBar = UITextField()
    private var navBarHeight: CGFloat = 0

    private var dataList: [SPImageCardDataModel] = []
    private var currentDataIndex: Int = 0

    private var currentPageIndex: Int = 0
    private var isLoadingNewData: Bool = false
    
    private var photoViewer: SPSlidePhotoViewer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.mainGrayColor

        self.createNavBar()
        self.requestDefaultData()


        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didCloseKeyboard)))
    }

    @objc func didCloseKeyboard() {
        self.searchBar.resignFirstResponder()
    }

    func createNavBar() {
        let navigationBarHeight: CGFloat = 54
        let statusFrame = UIApplication.shared.statusBarFrame
        let navHeight = statusFrame.size.height + navigationBarHeight
        let statusBarHeight = statusFrame.size.height

        self.navBarHeight = navHeight

        self.customNavigationBarView.backgroundColor = UIColor.Gray1Color
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(navHeight)
        }

        let searchIconView = UIView()
        searchIconView.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        let searchIcon = UIImageView()
        searchIcon.image = UIImage(named: "search-icon")
        searchIcon.frame = CGRect(x: 10, y: 0, width: 25, height: 25)
        searchIcon.layer.masksToBounds = true
        searchIconView.addSubview(searchIcon)
        self.searchBar.leftView = searchIconView
        self.searchBar.leftViewMode = .always
        self.searchBar.returnKeyType = .search
        self.searchBar.placeholder = "iPhone X"
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.layer.cornerRadius = 3
        self.searchBar.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.customNavigationBarView.addSubview(self.searchBar)
        self.searchBar.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight + 6)
            $0.left.equalTo(25)
            $0.right.equalTo(-25)
            $0.height.equalTo(40)
        }

        let btmLine = UIView()
        btmLine.backgroundColor = UIColor.Gray2Color
        self.customNavigationBarView.addSubview(btmLine)
        btmLine.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if text.count > 0 {
                self.requestData(with: true)
            }
        }
    }

    func requestData(with isNeedToRedraw: Bool, completion: (()->(Void))?=nil) {
        if self.isLoadingNewData {
            return
        }

        guard let searchKeyword = self.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else { return }
        if searchKeyword.count <= 0 {
            return
        }

        self.currentPageIndex += 1
        self.isLoadingNewData = true

        let httpManager = SPHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.searchItemsByKeyword, suffixParam: "?q=\(searchKeyword.urlencode())&sn=\(self.currentPageIndex)&pn=10")
        httpManager.request(withUrl: apiurl, parameters: nil, method: .get) { (isSuccess, respDict, error) in
            self.isLoadingNewData = false
            if !isSuccess {
                if let errMsg = error?.localizedDescription {
                    self.alert(with: errMsg)
                }
                return
            }
            if let dataList = respDict?["list"] as? [[String:Any]] {
                var _dataList: [SPImageCardDataModel] = []
                for dataDict in dataList {
                    let model = SPImageCardDataModel()
                    model.convert(with: dataDict)
                    _dataList.append(model)
                }
                if self.dataList.count == 0 || isNeedToRedraw {
                    self.dataList = _dataList
                    self.currentDataIndex = 0
                } else {
                    self.dataList.append(contentsOf: _dataList)
                }

                if isNeedToRedraw {
                    if let _ = self.photoViewer {
                        self.photoViewer?.removeFromSuperview()
                        self.photoViewer = nil
                    }
                    // 绘制UI
                    if self.dataList.count > 0 {
                        self.createPhotoCardView(with: self.dataList)
                    }
                }

                if let _completion = completion {
                    _completion()
                }
            }
        }
    }

    func alert(with message: String) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "好的", style: .default) { (alertAction) in
        })
        self.present(alertVC, animated: true, completion: nil)
    }


    // 进入时默认请求一次
    func requestDefaultData() {
        // 每次启动随机选择一个关键字
        let keywordPairs = [ "鸡腿", "汉堡", "薯条", "可乐", "奶茶", "咖啡"]
        let randomNumber = Int.random(in: 0..<keywordPairs.count)
        
        self.searchBar.text = keywordPairs[randomNumber]
        self.requestData(with: true)
    }

    func createPhotoCardView(with dataList: [SPImageCardDataModel]) {
        let photoViewer = SPSlidePhotoViewer(frame: self.view.bounds, dataList: dataList)
        photoViewer.photoViewerDelegate = self
        self.view.insertSubview(photoViewer, belowSubview: self.customNavigationBarView)
        self.photoViewer = photoViewer
    }

}


extension SPMainCardViewController: SPSlidePhotoViewerDelegate {
    
    func slidePhotoViewer(_ photoViewer: SPSlidePhotoViewer, requestNextPage nextPage: Bool) {
        self.requestData(with: false) { [weak self] () -> (Void) in
            if let _datalist = self?.dataList {
                self?.photoViewer?.updateDataModelList(_datalist)
            }
        }
    }
    
}
