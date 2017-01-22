//
//  STLoginViewController.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/5/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

import Mixpanel

class STLoginViewController: SimiViewController, MainNavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, STQRScannerViewControllerDelegate {
    let LOGIN_LOGO_ROW = "LOGIN_LOGO_ROW"
    let LOGIN_QRCODE_ROW = "LOGIN_QRCODE_ROW"
    let LOGIN_FIELDS_ROW = "LOGIN_FIELDS_ROW"
    let LOGIN_TRY_DEMO_ROW = "LOGIN_TRY_DEMO_ROW"
    let LOGIN_NEED_HELP_ROW = "LOGIN_NEED_HELP_ROW"
    
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<Any>!
    
    public var staffModel: StaffModel!
    
    var centerContainer: MMDrawerController?
    
    var loginImage: UIImageView!
    var loginURLField: UITextField!
    var loginEmailField: UITextField!
    var loginPasswordField: UITextField!
    
    var qrSessionId = ""
    
    var qrButton:SimiButton!
    var loginButton:SimiButton!
    var tryDemoButton:SimiButton!
    var needHelpButton:SimiButton!
    
    var loginLoadingView:SimiView!
    var logoLoadingImageView:SimiImageView!
    
    var dashboardViewController:STDashboardViewController!
    var navigationVC:MainNavigationController!
    var leftMenuViewController:STLeftMenuViewController = STLeftMenuViewController.shareInstance
    var leftNavigationVC:UINavigationController!
    
    var userData:STUserData = STUserData.sharedInstance
    
    var licenseModel:LicenseModel!
    
    //order id after receiving push notification
    var orderId: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        self.view.backgroundColor = THEME_COLOR
        staffModel = StaffModel()
        
        setMainTableViewCells()
        if (mainTableView == nil) {
            mainTableView = SimiTableView(frame:
                CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight) , style: UITableViewStyle.grouped)
            mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            mainTableView.delegate = self
            mainTableView.dataSource = self
            mainTableView.backgroundColor = UIColor.clear
            mainTableView.separatorColor = UIColor.clear
            mainTableView.bounces = false
            self.view.addSubview(mainTableView)
        }
        mainTableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Mixpanel.mainInstance().track(event: "Login Appeared")
    }
    
    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.reloadData()
        }
        if (loginLoadingView != nil) {
            loginLoadingView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            logoLoadingImageView.frame = CGRect(x: (SimiGlobalVar.screenWidth - 260)/2, y: (SimiGlobalVar.screenHeight - 260)/2 - 100, width: 260, height: 260)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func showLoadingView(){
        super.showLoadingView()
        if (loginLoadingView == nil){
            loginLoadingView = SimiView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight))
            loginLoadingView.backgroundColor = THEME_COLOR
            logoLoadingImageView = SimiImageView(image: UIImage(named: "login_logo"))
            logoLoadingImageView.frame = CGRect(x: (SimiGlobalVar.screenWidth - 260)/2, y: (SimiGlobalVar.screenHeight - 260)/2 - 100, width: 260, height: 260)
            loginLoadingView.addSubview(logoLoadingImageView)
            self.view.addSubview(loginLoadingView)
        }
        loadingFog.isHidden = true
        self.view.bringSubview(toFront: loginLoadingView)
        self.view.bringSubview(toFront: loadingImage)
        loginLoadingView.isHidden = false
        loadingImage.startRotating()
    }
    
    override func hideLoadingView() {
        super.hideLoadingView()
        loginLoadingView.isHidden = true
    }
    
    // MARK: - Tableview
    // MARK: - Set Data for TableView
    func setMainTableViewCells() {
        mainTableViewCells = []
        
        let mainSection = SimiSection()
        let logoRow:SimiRow = SimiRow(withIdentifier: LOGIN_LOGO_ROW, andHeight: 50)
        mainSection.childRows.append(logoRow)
        let fieldsRow:SimiRow = SimiRow(withIdentifier: LOGIN_FIELDS_ROW, andHeight: 50)
        mainSection.childRows.append(fieldsRow)
        let qrCodeRow:SimiRow = SimiRow(withIdentifier: LOGIN_QRCODE_ROW, andHeight: 50)
        mainSection.childRows.append(qrCodeRow)
        let tryDemoRow:SimiRow = SimiRow(withIdentifier: LOGIN_TRY_DEMO_ROW, andHeight: 50)
        mainSection.childRows.append(tryDemoRow)
        let needHelpRow:SimiRow = SimiRow(withIdentifier: LOGIN_NEED_HELP_ROW, andHeight: 50)
        mainSection.childRows.append(needHelpRow)
        
        mainTableViewCells.append(mainSection)
    }

    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        return row.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mainTableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainSection =  mainTableViewCells[section] as! SimiSection
        return mainSection.childRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        var identifier = row.identifier
        identifier += SimiGlobalVar.layoutDirection
        
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        if (cellToReturn == nil) {
            if row.identifier == LOGIN_LOGO_ROW {
                cellToReturn = createLogoRow(row: row, identifier: identifier)
            } else if row.identifier == LOGIN_QRCODE_ROW {
                cellToReturn = createQRRow(row: row, identifier: identifier)
            } else if row.identifier == LOGIN_FIELDS_ROW {
                cellToReturn = createLoginFieldsRow(row: row, identifier: identifier)
                getLocalData()
            } else if row.identifier == LOGIN_TRY_DEMO_ROW {
                cellToReturn = createTryDemoRow(row: row, identifier: identifier)
            } else if row.identifier == LOGIN_NEED_HELP_ROW {
                cellToReturn = createNeedHelpRow(row: row, identifier: identifier)
            }
            else {
                cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            }
        }
        
        cellToReturn?.backgroundColor = UIColor.clear
        cellToReturn?.selectionStyle = UITableViewCellSelectionStyle.none
        return cellToReturn!
    }
    
    // MARK: - Create Cell
    func createLogoRow(row: SimiRow, identifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        
        var yStart = CGFloat(-40)
        if (SimiGlobalVar.screenHeight>600) {
            yStart = 10
        }
        
        loginImage = UIImageView(image: UIImage(named: "login_logo"))
        loginImage.frame = CGRect(x: (SimiGlobalVar.screenWidth-200)/2, y: yStart, width: 200, height: 200)
        cellToReturn.addSubview(loginImage)
        yStart += 200
        
        row.height = yStart
        return cellToReturn
    }
    
    func createLoginFieldsRow(row: SimiRow, identifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        
        var yStart = CGFloat(0)
        
        let separatorColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#333333")
        
        let urlIconView:UIView = UIView(frame: CGRect(x: (SimiGlobalVar.screenWidth-320)/2, y: yStart, width: 40, height: 40))
        urlIconView.backgroundColor = separatorColor
        let urlIcon:UIImageView = UIImageView(image: UIImage(named: "login_url"))
        urlIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        ImageViewToColor(imageView: urlIcon, color: THEME_COLOR)
        urlIconView.addSubview(urlIcon)
        cellToReturn.addSubview(urlIconView)
        
        let loginURLFieldHolder:UIView = UIView(frame: CGRect(x: (SimiGlobalVar.screenWidth-320)/2+40, y: yStart, width: 280, height: 40))
        loginURLFieldHolder.backgroundColor = UIColor.white
        loginURLField = UITextField(frame: CGRect(x: 10, y: 5, width: 270, height: 30))
        loginURLField.placeholder = STLocalizedString(inputString: "Your URL")
        loginURLField.font = UIFont.systemFont(ofSize: 14)
        loginURLField.delegate = self
        loginURLField.autocapitalizationType = UITextAutocapitalizationType.none
        loginURLFieldHolder.addSubview(loginURLField)
        cellToReturn.addSubview(loginURLFieldHolder)
        
        let urlFieldSeparator:UIView = UIView(frame: CGRect(x: (SimiGlobalVar.screenWidth-320)/2, y: yStart+39, width: 320, height: 1))
        urlFieldSeparator.backgroundColor = separatorColor
        cellToReturn.addSubview(urlFieldSeparator)
        yStart+=40
        
        let emailIconView:UIView = UIView(frame: CGRect(x: (SimiGlobalVar.screenWidth-320)/2, y: yStart, width: 40, height: 40))
        emailIconView.backgroundColor = separatorColor
        let emailIcon:UIImageView = UIImageView(image: UIImage(named: "login_user"))
        emailIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        ImageViewToColor(imageView: emailIcon, color: THEME_COLOR)
        emailIconView.addSubview(emailIcon)
        cellToReturn.addSubview(emailIconView)
        
        let loginEmailFieldHolder:UIView = UIView(frame: CGRect(x: (SimiGlobalVar.screenWidth-320)/2+40, y: yStart, width: 280, height: 40))
        loginEmailFieldHolder.backgroundColor = UIColor.white
        loginEmailField = UITextField(frame: CGRect(x: 10, y: 5, width: 270, height: 30))
        loginEmailField.placeholder = STLocalizedString(inputString: "Your Email")
        loginEmailField.font = UIFont.systemFont(ofSize: 14)
        loginEmailField.keyboardType = UIKeyboardType.emailAddress
        loginEmailField.autocapitalizationType = UITextAutocapitalizationType.none
        loginEmailFieldHolder.addSubview(loginEmailField)
        cellToReturn.addSubview(loginEmailFieldHolder)
        
        let emailFieldSeparator:UIView = UIView(frame: CGRect(x: (SimiGlobalVar.screenWidth-320)/2, y: yStart+39, width: 320, height: 1))
        emailFieldSeparator.backgroundColor = separatorColor
        cellToReturn.addSubview(emailFieldSeparator)
        yStart+=40
        
        
        let passwordIconView:UIView = UIView(frame: CGRect(x: (SimiGlobalVar.screenWidth-320)/2, y: yStart, width: 40, height: 40))
        passwordIconView.backgroundColor = separatorColor
        let passwordIcon:UIImageView = UIImageView(image: UIImage(named: "login_password"))
        passwordIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        ImageViewToColor(imageView: passwordIcon, color: THEME_COLOR)
        passwordIconView.addSubview(passwordIcon)
        cellToReturn.addSubview(passwordIconView)
        
        let loginPasswordFieldHolder:UIView = UIView(frame: CGRect(x: (SimiGlobalVar.screenWidth-320)/2+40, y: yStart, width: 280, height: 40))
        loginPasswordFieldHolder.backgroundColor = UIColor.white
        loginPasswordField = UITextField(frame: CGRect(x: 10, y: 5, width: 270, height: 30))
        loginPasswordField.font = UIFont.systemFont(ofSize: 14)
        loginPasswordField.placeholder = STLocalizedString(inputString: "Your Password")
        loginPasswordField.isSecureTextEntry = true
        loginPasswordField.autocapitalizationType = UITextAutocapitalizationType.none
        loginPasswordFieldHolder.addSubview(loginPasswordField)
        cellToReturn.addSubview(loginPasswordFieldHolder)
        
        yStart += 50
        
        
        loginButton = SimiButton(frame: CGRect(x: (SimiGlobalVar.screenWidth - 260)/2, y: yStart, width: 260, height: 40))
        loginButton.addTarget(self, action: #selector(self.loginButtonPressed(sender:)), for: .touchUpInside)
        loginButton.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#f08002")
        loginButton .setTitle(STLocalizedString(inputString: "Login").uppercased(), for: UIControlState.normal)
        cellToReturn.addSubview(loginButton)
        
        yStart += 40
        row.height = yStart
        return cellToReturn
    }
    
    func createQRRow(row: SimiRow, identifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        
        var yStart = CGFloat(10)
        
        qrButton = SimiButton(frame: CGRect(x: (SimiGlobalVar.screenWidth - 260)/2, y: yStart, width: 260, height: 40))
        //qrButton.layer.cornerRadius = 5
        qrButton.addTarget(self, action: #selector(self.qrcodeButtonPressed(sender:)), for: .touchUpInside)
        qrButton.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#f08002")
        qrButton.setTitle("      " + STLocalizedString(inputString: "QRCode Login").uppercased(), for: UIControlState.normal)
        cellToReturn.addSubview(qrButton)
        
        let qrIconImageView = SimiImageView(image: UIImage(named: "qr_ic"))
        qrIconImageView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        qrButton.addSubview(qrIconImageView)
        yStart += 40
        
        row.height = yStart
        return cellToReturn
    }
    
    
    func createTryDemoRow(row: SimiRow, identifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        
        var yStart = CGFloat(10)
        
        tryDemoButton = SimiButton(frame: CGRect(x: (SimiGlobalVar.screenWidth - 260)/2, y: yStart, width: 260, height: 40))
        tryDemoButton.addTarget(self, action: #selector(self.tryDemoButtonPressed(sender:)), for: .touchUpInside)
        tryDemoButton.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#f08002")
        tryDemoButton .setTitle(STLocalizedString(inputString: "Try Demo").uppercased(), for: UIControlState.normal)
        cellToReturn.addSubview(tryDemoButton)
        
        yStart += 50
        row.height = yStart
        return cellToReturn
    }
    
    
    func createNeedHelpRow(row: SimiRow, identifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        
        var yStart = CGFloat(20)
        
        needHelpButton = SimiButton(frame: CGRect(x: (SimiGlobalVar.screenWidth - 260)/2, y: yStart, width: 260, height: 16))
        needHelpButton.addTarget(self, action: #selector(self.needHelpButtonPressed(sender:)), for: .touchUpInside)
        needHelpButton .setTitle(STLocalizedString(inputString: "Need Help?"), for: UIControlState.normal)
        needHelpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cellToReturn.addSubview(needHelpButton)
        yStart += 20
        
        row.height = yStart
        return cellToReturn
    }
    
    //MARK: - Button Pressed Functions
    func qrcodeButtonPressed(sender: UIButton) {
        let newQRVC = STQRScannerViewController()
        newQRVC.delegate = self
        self.present(newQRVC, animated: true, completion: nil)
    }
    
    func loginButtonPressed(sender: UIButton) {
        loginWithFilledValues()
    }
    
    func loginWithFilledValues() {
        if (loginEmailField.text == "") || (loginURLField.text == "") || (loginPasswordField.text == "") {
            let alert = UIAlertController(title: "", message: STLocalizedString(inputString: "Please Fill the Fields"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var urltyped = loginURLField.text!
        if (urltyped.characters.last != "/") {
            urltyped += "/"
        }
        SimiGlobalVar.baseURL = urltyped
        userData.userEmail = loginEmailField.text!
        userData.userPassword = loginPasswordField.text!
        userData.userURL = loginURLField.text!
        
        staffModel.loginWithUserMail(userEmail: loginEmailField.text!, password: loginPasswordField.text!)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: NSNotification.Name(rawValue: "DidLogin"), object: nil)
        
        self.showLoadingView()
    }
    
    func loginWithQRCode() {
        var urltyped = loginURLField.text!
        if (urltyped.characters.last != "/") {
            urltyped += "/"
        }
        SimiGlobalVar.baseURL = urltyped

        userData.userEmail = loginEmailField.text!
        userData.userURL = loginURLField.text!
        userData.qrSessionId = qrSessionId
        
        staffModel.loginWithEmailAndQrSession(userEmail: loginEmailField.text!, qrsession: qrSessionId)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: NSNotification.Name(rawValue: "DidLogin"), object: nil)
        
        self.showLoadingView()
    }
    
    func tryDemoButtonPressed(sender: UIButton){
        SimiGlobalVar.baseURL = "http://dev.magento19.jajahub.com/index.php/default/"
        staffModel.loginWithUserMail(userEmail: "cody@simicart.com", password: "123456")
        loginEmailField.text = "cody@simicart.com"
        loginURLField.text = SimiGlobalVar.baseURL
        loginPasswordField.text = "123456"
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: NSNotification.Name(rawValue: "DidLogin"), object: nil)
        self.showLoadingView()
    }
    
    func needHelpButtonPressed(sender: UIButton){
        UIApplication.shared.openURL(NSURL(string: "https://www.simicart.com/contacts") as! URL)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    
    //MARK: - Logged in
    func didLogin(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidLogin"), object: nil)
        
        if self.staffModel.isSucess == false {
            hideLoadingView()
            let alert = UIAlertController(title: "", message: self.staffModel.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            SimiDataLocal.setLocalData(data: loginEmailField.text!, forKey: LAST_USER_EMAIL)
            checkLicense()
            if orderId == ""{
                openDashboard()
            }else{
                openOrderDetail()
            }
        }
    }
    
    //MARK: - Delegate Functions
 
    func onMenuButtonTapped()
    {
        centerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    
    func dismissDrawerController() {
        centerContainer?.dismiss(animated: true, completion: nil)
    }
    
    func didScannedWithCode(code: String) {
        if let base64Decoded = NSData(base64Encoded: code, options:   NSData.Base64DecodingOptions(rawValue: 0))
            .map({ NSString(data: $0 as Data, encoding: String.Encoding.utf8.rawValue) })
        {
            let data = base64Decoded?.data(using: 0)
            let json = try? JSONSerialization.jsonObject(with: data!)
            if (json is Dictionary<String, String>) {
                let result = json as! Dictionary<String, String>
                if (result["user_email"] != "") && (result["url"] != "") && (result["session_id"] != "") {
                    loginURLField.text = result["url"]
                    loginEmailField.text = result["user_email"]
                    qrSessionId = result["session_id"]!
                    loginWithQRCode()
                }
            }
        } else {
            let alert = UIAlertController(title: "", message: STLocalizedString(inputString: "Your QRCode is not Valid"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - KeyboardActions
    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        mainTableView.contentInset = UIEdgeInsetsMake(65, 0, keyboardHeight+65, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    //MARK: - Open Dashboard
    
    func openOrderDetail(){
        updateGlobalVar()
        let orderDetailVC = STOrderDetailViewController()
        orderDetailVC.orderId = orderId
        leftMenuViewController.mainNavigation.popToRootViewController(animated: false)
        leftMenuViewController.mainNavigation.pushViewController(orderDetailVC, animated: false)
        leftMenuViewController.mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
        orderDetailVC.navigationItem.leftBarButtonItem = leftMenuViewController.mainNavigation.menuButton
    }
    
    func openDashboard() {
        updateGlobalVar()
        
        dashboardViewController = STDashboardViewController()
        navigationVC = MainNavigationController(rootViewController: dashboardViewController)
        navigationVC.rootDelegate = self
        dashboardViewController.navigationItem.leftBarButtonItem = navigationVC.menuButton
        
        leftMenuViewController.staffModel = staffModel
        leftMenuViewController.mainNavigation = navigationVC
        leftNavigationVC = UINavigationController(rootViewController: leftMenuViewController)
        leftNavigationVC.navigationBar.isHidden = true
        
        centerContainer = MMDrawerController(center: navigationVC, leftDrawerViewController: leftNavigationVC)
        centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView
        centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.panningCenterView
        
        self.present(centerContainer!, animated: true, completion:
            {self.hideLoadingView()})
        
    }
    
    func updateGlobalVar() {
        if (staffModel.data["device_data"] != nil) && !(staffModel.data["device_data"] is NSNull) {
            let staffData = staffModel.data["device_data"] as! Dictionary<String, Any>
            SimiGlobalVar.sessionId = staffData["session_id"] as! String
        }
        
        if (staffModel.data["base_currency"] != nil) && !(staffModel.data["base_currency"] is NSNull) {
            SimiGlobalVar.baseCurrency = staffModel.data["base_currency"] as! String
        }
    }
    
    //MARK: - UITextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == loginURLField) && (loginURLField.text == "") {
            loginURLField.text = "https://"
        }
        return true
    }
    
    //MARK: - Get Saved Data
    func getLocalData() {
        let emailSaved = SimiDataLocal.getLocalData(forKey: LAST_USER_EMAIL) as! String
        if (emailSaved != "") {
            userData.userEmail = emailSaved
            loginEmailField.text = emailSaved
            loginPasswordField.text = userData.userPassword
            loginURLField.text = userData.userURL
            qrSessionId = userData.qrSessionId
            if (qrSessionId != "") {
                loginWithQRCode()
            } else if (loginPasswordField.text != "") {
                loginWithFilledValues()
            }
        }
    }
    
    //MARK: - License Checking
    func checkLicense() {
        if (licenseModel == nil) {
            licenseModel = LicenseModel()
        }
        licenseModel.getLicenseInfo(params: [:])
        NotificationCenter.default.addObserver(self, selector: #selector(didGetLicense(notification:)), name: NSNotification.Name(rawValue: "DidGetLicenseInfo"), object: nil)
        self.showLoadingView()
    }
    
    
    //MARK: - Logged in
    func didGetLicense(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetLicenseInfo"), object: nil)
        if self.licenseModel.isSucess != false {
            if (centerContainer != nil) {
                if !(licenseModel.data["status"] is NSNull) {
                    if (licenseModel.data["status"] as! String)  == "0" {
                        centerContainer?.dismiss(animated: true, completion: nil)
                        let alert = UIAlertController(title: "", message: (licenseModel.data["message"] as! String), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            if (dashboardViewController != nil) {
                if !(licenseModel.data["version"] is NSNull) {
                    if (licenseModel.data["version"] as! String)  != CURENT_SIMTRACKING_VERSION {
                        let alert = UIAlertController(title: "", message: STLocalizedString(inputString: "Your Version is Outdated. Please install the latest one"), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
                        dashboardViewController.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

