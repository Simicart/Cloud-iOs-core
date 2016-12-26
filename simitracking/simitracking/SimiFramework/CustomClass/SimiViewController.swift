//
//  SimiViewController.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/5/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiViewController: UIViewController {
    
    //loading
    var loadingFog:UIView!
    var loadingImage:SimiView!
    var isLoading = false
    
    //navigation
    var backButton:UIBarButtonItem!
    
    //float button
    var floatView:SimiButton!
    
    //rotating flag
    var rotatedOnce = false
    
    
    //paging
    var pageActionSheet:UIActionSheet!
    var maxPage = 1
    var currentPage = 1
    
    var pagingView:UIView!
    var previousPageBtn:SimiButton!
    var nextPageBtn:SimiButton!
    var switchPageBtn:SimiButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Loading Functions
    func addLoadingItems(){
        loadingFog = UIView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight))
        loadingFog.layer.opacity = 0.5
        loadingFog.backgroundColor = UIColor.white
        loadingFog.isHidden = true
        self.view.addSubview(loadingFog)
        
        loadingImage = SimiView(frame: CGRect(x: (SimiGlobalVar.screenWidth-30)/2, y: (SimiGlobalVar.screenHeight-30)/2, width: 30, height: 30))
        let loadingIcon:UIImageView = UIImageView(image: UIImage(named:"loading_icon"))
        loadingIcon.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        loadingImage.addSubview(loadingIcon)
        loadingImage.isHidden = true
        self.view.addSubview(loadingImage)
    }
    
    func showLoadingView(){
        isLoading = true
        if (loadingFog == nil) {
            addLoadingItems()
        }
        self.view.bringSubview(toFront: loadingFog)
        self.view.bringSubview(toFront: loadingImage)
        loadingFog.isHidden = false
        loadingImage.isHidden = false
        loadingImage.startRotating()
    }
    
    func hideLoadingView(){
        isLoading = false
        if (loadingFog == nil) {
            addLoadingItems()
        }
        loadingFog.isHidden = true
        loadingImage.isHidden = true
        loadingImage.stopRotating()
    }
    // MARK: - Keyboard Handler
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Back Button
    public func createBackButton() {
        if (backButton == nil) {
            let button: SimiButton = SimiButton(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
            button.contentEdgeInsets = UIEdgeInsetsMake(15, 0, 15, 30)
            button.setImage(UIImage(named: "back_btn_icon"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            backButton = UIBarButtonItem(customView: button)
        }
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    public func backButtonTapped() {
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - Float Button
    func addFloatView(withView: UIView) {
        if (floatView == nil) {
            floatView = SimiButton(frame: CGRect(x: SimiGlobalVar.screenWidth - 65, y: SimiGlobalVar.screenHeight - 65, width: 50, height: 50))

            floatView.layer.shadowOpacity = 0.7
            floatView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            floatView.layer.shadowRadius = 2.0
            floatView.layer.shadowColor = UIColor.black.cgColor
        }
        for subview in (floatView?.subviews)! {
            subview.removeFromSuperview()
        }
        floatView.addSubview(withView)
        self.view.addSubview(floatView!)
        floatView.superview?.bringSubview(toFront: floatView!)
    }
    
    // MARK: - Paging View
    func addPagingView() {
        if (pagingView == nil) {
            let spaceBetweenButtons = 60
            let buttonHeight = 40
            let buttonWidth = 40
            //let pagingViewX = SimiGlobalVar.screenWidth/2 - spaceBetweenButtons/2 - 50
            
            pagingView = UIView(frame: CGRect(x: 0, y: SimiGlobalVar.screenHeight - 40, width: SimiGlobalVar.screenWidth, height: 40))
            pagingView.backgroundColor = THEME_COLOR
            
            switchPageBtn = SimiButton(frame: CGRect(x: Int(SimiGlobalVar.screenWidth/2) - spaceBetweenButtons/2, y: 10, width: spaceBetweenButtons, height: 20))
            switchPageBtn.tintColor = UIColor.white
            switchPageBtn.addTarget(self, action: #selector(showPageActionSheet), for: UIControlEvents.touchUpInside)
            switchPageBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            switchPageBtn.titleLabel?.textAlignment = NSTextAlignment.center
            pagingView.addSubview(switchPageBtn)
            
            
            previousPageBtn = SimiButton(frame: CGRect(x: (Int(SimiGlobalVar.screenWidth/2) - buttonWidth - spaceBetweenButtons/2), y: 0, width: buttonWidth, height: buttonHeight))
            previousPageBtn.setImage(UIImage(named: "ic_previous_page"), for: UIControlState.normal)
            previousPageBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            previousPageBtn.addTarget(self, action: #selector(openPreviousPage), for: UIControlEvents.touchUpInside)
            pagingView.addSubview(previousPageBtn)
            
            
            nextPageBtn = SimiButton(frame: CGRect(x: (Int(SimiGlobalVar.screenWidth/2) + spaceBetweenButtons/2), y: 0, width: buttonWidth, height: buttonHeight))
            nextPageBtn.setImage(UIImage(named: "ic_next_page"), for: UIControlState.normal)
            nextPageBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            nextPageBtn.addTarget(self, action: #selector(openNextPage), for: UIControlEvents.touchUpInside)
            pagingView.addSubview(nextPageBtn)
            
            self.view.addSubview(pagingView!)
            pagingView.superview?.bringSubview(toFront: pagingView!)
        }
        updatePagingView()
        hidePageNavi()
    }
    
    // MARK: - Page Navigation
    func openNextPage() {
        if (currentPage < maxPage) {
            setCurrentPage(pageNumber: (currentPage + 1))
        }
    }
    func openPreviousPage() {
        if (currentPage > 1) {
            setCurrentPage(pageNumber: (currentPage - 1))
        }
    }
    func updatePagingView(){
        switchPageBtn.setTitle(String(currentPage) + "/" + String(maxPage), for: UIControlState.normal)
        if (currentPage == 1) {
            previousPageBtn.isEnabled = false
        } else {
            previousPageBtn.isEnabled = true
        }
        
        if (currentPage == maxPage) {
            nextPageBtn.isEnabled = false
        } else {
            nextPageBtn.isEnabled = true
        }
    }
    
    func showPageNavi(){
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            var updateFrame = self.pagingView.frame
            updateFrame.origin.y = SimiGlobalVar.screenHeight - 40
            self.pagingView.frame = updateFrame
        }, completion: { finished in
            
        })
    }
    
    func hidePageNavi(){
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            var updateFrame = self.pagingView.frame
            updateFrame.origin.y = SimiGlobalVar.screenHeight
            self.pagingView.frame = updateFrame
        }, completion: { finished in
            
        })
    }
    
    func setCurrentPage(pageNumber: Int) {
        currentPage = pageNumber
    }
    
    // MARK: - Change Page
    func showPageActionSheet() {
        //defined on childrens
    }
    
    // MARK: - Screen rotated Changing
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        rotatedOnce = true
        if (self.isViewLoaded && (self.view.window != nil)) {
            /* so it only run one time */
            SimiGlobalVar.updateScreenSize(size: size)
            updateViews()
        }
    }
    
    func updateViews(){
        /* things to do while screen rotated */
        if (floatView != nil) {
            floatView.frame = CGRect(x: SimiGlobalVar.screenWidth - 65, y: SimiGlobalVar.screenHeight - 65, width: 50, height: 50)
        }
        if (loadingImage != nil) {
            loadingImage.frame = CGRect(x: (SimiGlobalVar.screenWidth-30)/2, y: (SimiGlobalVar.screenHeight-30)/2, width: 30, height: 30)
            loadingFog.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
        }
        // paging
        if (pagingView != nil) {
            let spaceBetweenButtons = 60
            let buttonHeight = 40
            let buttonWidth = 40
            pagingView.frame = CGRect(x: 0, y: SimiGlobalVar.screenHeight - 40, width: SimiGlobalVar.screenWidth, height: 40)
            switchPageBtn.frame = CGRect(x: Int(SimiGlobalVar.screenWidth/2) - spaceBetweenButtons/2, y: 10, width: spaceBetweenButtons, height: 20)
            previousPageBtn.frame = CGRect(x: (Int(SimiGlobalVar.screenWidth/2) - buttonWidth - spaceBetweenButtons/2), y: 0, width: buttonWidth, height: buttonHeight)
            nextPageBtn.frame = CGRect(x: (Int(SimiGlobalVar.screenWidth/2) + spaceBetweenButtons/2), y: 0, width: buttonWidth, height: buttonHeight)
        }
    }
    func removeAllSubviews() {
        let subviews = self.view.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}
