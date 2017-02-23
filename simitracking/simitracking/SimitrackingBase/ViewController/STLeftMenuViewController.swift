//
//  STLeftMenuViewController.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/6/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STLeftMenuViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource{

    static let shareInstance = STLeftMenuViewController()
    
    // Left menu identifiers
    let DASHBOARD_MENU = "Dashboard_menu"
    let FORECAST_MENU = "FORECAST_MENU"
    let ORDER_MENU = "Order_menu"
    let BESTSELLERS_MENU = "Bestsellers_menu"
    let PRODUCT_MENU = "Product_menu"
    let CUSTOMER_MENU = "Customer_menu"
    let ABANDONED_CART_MENU = "Abandoned_cart_menu"
    let SETTING_MENU = "Setting_menu"
    let LOGOUT_MENU = "Logout_menu"
    
    let drawerWidth = 280
    
    var topView:UIImageView!
    var avatarButton:SimiButton!
    var nameLabel:SimiLabel!
    var roleLabel:SimiLabel!
    var emailLabel:SimiLabel!
    var imageAvatar:UIImageView!
    
    var mainTableViewCells:Array<Any>!
    var mainTableView:SimiTableView!
    var menuItems:Array<Any>!
    
    var selectedRow:Int = 0
    
    var mainNavigation:MainNavigationController!
    
    var orderListVC:STOrderListViewController!
    var customerListVC:STCustomerListViewController!
    var abandonedCartVC:STAbandonedCartListViewController!
    var bestsellersListVC:STBestsellersViewController!
    var productListVC:STProductListViewController!
    var settingVC:STSettingViewController!
    var forecastVC: STForecastViewController!
    
    private var needUpdateUserInfo:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#1a1a1a")
        setMainTableViewCells()
        addTopViews()
        addTableView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needUpdateUserInfo{
            if let profileImageString:String = self.staffModel.data["user_profile_image"] as? String {
                let urlAvatar = URL(string: profileImageString)
                imageAvatar.sd_setImage(with: urlAvatar)
            }
            nameLabel.text = self.staffModel.data["user_title"] as? String
            roleLabel.text = self.staffModel.data["role_title"] as? String
            emailLabel.text = self.staffModel.data["user_email"] as? String
            needUpdateUserInfo = false
        }
    }
    
    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 170, width: 280, height: SimiGlobalVar.screenHeight - 170)
            mainTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func addTopViews(){
        topView = UIImageView(frame: CGRect(x: 0, y: 0, width: 280, height: 170))
        topView.image = UIImage(named: "menu_top_background")
        
        avatarButton = SimiButton(frame: CGRect(x: 20, y: 45, width: 80, height: 80))
        avatarButton.backgroundColor = UIColor.white
        let backgroundImage = UIImage(named: "default_avt")
        avatarButton.setBackgroundImage(backgroundImage, for: UIControlState.normal)
        
        if let profileImageString:String = self.staffModel.data["user_profile_image"] as? String {
            imageAvatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            let urlAvatar = URL(string: profileImageString)
            imageAvatar.sd_setImage(with: urlAvatar)
            avatarButton.addSubview(imageAvatar)
        }
        
        nameLabel = SimiLabel(frame: CGRect(x: 110, y: 60, width: 170, height: 18))
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        nameLabel.text = self.staffModel.data["user_title"] as? String
        topView.addSubview(nameLabel)
        
        roleLabel = SimiLabel(frame: CGRect(x: 110, y: 80, width: 170, height: 16))
        roleLabel.textColor = UIColor.white
        roleLabel.font = UIFont.systemFont(ofSize: 12)
        roleLabel.text = self.staffModel.data["role_title"] as? String
        topView.addSubview(roleLabel)
        
        emailLabel = SimiLabel(frame: CGRect(x: 110, y: 96, width: 170, height: 16))
        emailLabel.urlType = .emailAddress
        emailLabel.textColor = UIColor.white
        emailLabel.font = UIFont.systemFont(ofSize: 12)
        emailLabel.text = self.staffModel.data["user_email"] as? String
        topView.addSubview(emailLabel)
        
        avatarButton.layer.cornerRadius = 40
        avatarButton.layer.masksToBounds = true
        topView.addSubview(avatarButton)
        
        self.view.addSubview(topView)
    }
    
    var staffModel:StaffModel!{
        didSet{
            needUpdateUserInfo = true
        }
    }
    
    func addTableView() {
        if mainTableView == nil {
            mainTableView = SimiTableView(frame: CGRect(x: 0, y: 170, width: 280, height: SimiGlobalVar.screenHeight - 170), style: UITableViewStyle.plain)
            mainTableView.backgroundColor = self.view.backgroundColor
            mainTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            mainTableView.delegate = self
            mainTableView.dataSource = self
            self.view.addSubview(mainTableView)
        }
    }
    
    func setMainTableViewCells() {
        mainTableViewCells = []
        let mainSection = SimiSection()
        if (SimiGlobalVar.permissionsAllowed == nil) {
            grandPermissions()
        }
        let items = getMenuItems()
        for item in items {
            let leftMenuItem:Array<Any> = item as! Array<Any>
            let permissionList:Array<String> = leftMenuItem[3] as! Array<String>
            var addToList = false
            if permissionList.count == 0 {
                addToList = true
            }
            else {
                for permission in permissionList {
                    if (SimiGlobalVar.permissionsAllowed[permission] == true) {
                        addToList = true
                    }
                }
            }
            if addToList == true {
                let newRow:SimiRow = SimiRow()
                newRow.data["left_menu_item"] = leftMenuItem
                mainSection.childRows.append(newRow)
            }
        }
        mainTableViewCells.append(mainSection)
    }
    
    func grandPermissions() {
        if self.staffModel.data["permissions"] != nil &&  self.staffModel.data["permissions"] is Array<Dictionary<String,Any>>{
            SimiGlobalVar.grandPermissions(data: (self.staffModel.data["permissions"] as? Array<Dictionary<String, Any>>)!)
        }
    }

    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainSection =  mainTableViewCells[section] as! SimiSection
        return mainSection.childRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        let rowData = row.data["left_menu_item"] as! Array<Any>
        
        var identifier = rowData[1] as! String
        
        identifier+=SimiGlobalVar.layoutDirection
        var cellToReturn = tableView.dequeueReusableCell(withIdentifier: identifier) as? STLeftMenuCell

        if (cellToReturn == nil) {
            cellToReturn = STLeftMenuCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            cellToReturn?.frame = CGRect(x: 0, y: 0, width: 280, height: 40)
            cellToReturn?.backgroundColor = tableView.backgroundColor
            
            let titleLabel = SimiLabel(frame: CGRect(x: 70, y: 11, width: 220, height: 20))
            titleLabel.textColor = UIColor.white
            titleLabel.text = rowData[0] as? String
            cellToReturn?.addSubview(titleLabel)
            
            let menuIcon = SimiImageView(frame: CGRect(x: 20, y: 5, width: 30, height: 30))
            menuIcon.image = UIImage(named: rowData[2] as! String)
            cellToReturn?.iconMenu = menuIcon
            cellToReturn?.addSubview(menuIcon)
            
            cellToReturn?.selectionStyle = UITableViewCellSelectionStyle.none
            
        }
        if (indexPath.row == selectedRow) {
            cellToReturn?.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#FD9900")
            ImageViewToColor(imageView: (cellToReturn?.iconMenu)!, color: UIColor.white)
        }
        else {
            cellToReturn?.backgroundColor = tableView.backgroundColor
            ImageViewToColor(imageView: (cellToReturn?.iconMenu)!, color: SimiGlobalVar.colorWithHexString(hexStringInput: "FD9900"))
        }
        return cellToReturn!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hideLeftMenu()
//        if (selectedRow == indexPath.row) {
//            return
//        }
        selectedRow = indexPath.row
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        let rowData = row.data["left_menu_item"] as! Array<Any>
        switch rowData[1] as! String {
        case DASHBOARD_MENU:
            showDashboard()
            break
        case FORECAST_MENU:
            showForecast()
            break
        case ORDER_MENU:
            showOrderList()
            break
        case BESTSELLERS_MENU:
            showBestsellersList()
            break
        case PRODUCT_MENU:
            showProductList()
            break
        case CUSTOMER_MENU:
            showCustomerList()
            break
        case ABANDONED_CART_MENU:
            showAbandonedCartList()
            break
        case SETTING_MENU:
            showSettingScreen()
            break
        case LOGOUT_MENU:
            selectedRow = 0
            logout()
            break
        default:
            print("do nothing")
            break
        }
        updateTableView()
    }
    
    func updateTableView() {
        setMainTableViewCells()
        self.mainTableView .reloadData()
    }
    
    //MARK: - Left Menu Items
    // 0 - Title, 1 - Identify String, 2 - icon, 3 - Permissions list, 4 - is Selected
    
    func getMenuItems()->Array<Any> {
        if (menuItems == nil) {
            var returnArray:Array<Any> = []
            returnArray.append([STLocalizedString(inputString: "Dashboard"),DASHBOARD_MENU,"dashboard_icon",
                                []])
            returnArray.append([STLocalizedString(inputString: "Forecast"),FORECAST_MENU,"ic_forecast",[]])
            returnArray.append([STLocalizedString(inputString: "Orders"),ORDER_MENU,"order_icon",
                                [ORDER_LIST,ORDER_DETAIL,INVOICE_ORDER,SHIP_ORDER,CANCEL_ORDER,HOLD_ORDER,UNHOLD_ORDER]])
            returnArray.append([STLocalizedString(inputString: "Best Sellers"),BESTSELLERS_MENU,"bestseller_icon",
                                [PRODUCT_LIST]])
            returnArray.append([STLocalizedString(inputString: "Products"),PRODUCT_MENU,"product_icon",
                                [PRODUCT_LIST]])
            returnArray.append([STLocalizedString(inputString: "Customers"),CUSTOMER_MENU,"customer_icon",
                                [CUSTOMER_LIST,CUSTOMER_DETAIL,CUSTOMER_EDIT,CUSTOMER_ADDRESS_LIST,CUSTOMER_ADDRESS_EDIT,CUSTOMER_ADDRESS_REMOVE]])
            returnArray.append([STLocalizedString(inputString: "Abandoned Cart"),ABANDONED_CART_MENU,"abandoned_cart_icon",
                                [ABANDONED_CARTS_LIST,ABANDONED_CARTS_DETAILS]])
            returnArray.append([STLocalizedString(inputString: "Settings"),SETTING_MENU,"setting_icon",
                                []])
            returnArray.append([STLocalizedString(inputString: "Logout"),LOGOUT_MENU,"logout_icon",
                                []])
            menuItems = returnArray
        }
        return menuItems
    }
    
    // MARK: - Hide Left Menu
    func hideLeftMenu() {
        mainNavigation.menuTapped()
    }
    
    // MARK: - Action
    
    func showDashboard() {
        mainNavigation.popToRootViewController(animated: false)
        
    }
    
    func showForecast(){
        mainNavigation.popToRootViewController(animated: false)
        if(forecastVC == nil){
            forecastVC = STForecastViewController()
        }
        mainNavigation.pushViewController(forecastVC, animated: false)
        mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
        forecastVC.navigationItem.leftBarButtonItem = mainNavigation.menuButton
    }
    
    func showOrderList() {
        mainNavigation.popToRootViewController(animated: false)
        orderListVC = STOrderListViewController()
        mainNavigation.pushViewController(orderListVC, animated: false)
        mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
        orderListVC.navigationItem.leftBarButtonItem = mainNavigation.menuButton
    }
    
    func showBestsellersList() {
        mainNavigation.popToRootViewController(animated: false)
        bestsellersListVC = STBestsellersViewController()
        mainNavigation.pushViewController(bestsellersListVC, animated: false)
        mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
        bestsellersListVC.navigationItem.leftBarButtonItem = mainNavigation.menuButton
    }
    
    func showProductList() {
        mainNavigation.popToRootViewController(animated: false)
        productListVC = STProductListViewController()
        mainNavigation.pushViewController(productListVC, animated: false)
        mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
        productListVC.navigationItem.leftBarButtonItem = mainNavigation.menuButton
    }

    func showCustomerList() {
        mainNavigation.popToRootViewController(animated: false)
        customerListVC = STCustomerListViewController()
        mainNavigation.pushViewController(customerListVC, animated: false)
        mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
        customerListVC.navigationItem.leftBarButtonItem = mainNavigation.menuButton
    }
    
    func showAbandonedCartList() {
        mainNavigation.popToRootViewController(animated: false)
        abandonedCartVC = STAbandonedCartListViewController()
        mainNavigation.pushViewController(abandonedCartVC, animated: false)
        mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
        abandonedCartVC.navigationItem.leftBarButtonItem = mainNavigation.menuButton
    }
    
    func showSettingScreen() {
        mainNavigation.popToRootViewController(animated: false)
        if settingVC == nil{
            settingVC = STSettingViewController()
        }
        mainNavigation.pushViewController(settingVC, animated: false)
        mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
        settingVC.navigationItem.leftBarButtonItem = mainNavigation.menuButton
    }
    
    func logout() {
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout(noti:)), name: NSNotification.Name(rawValue: DidLogout), object: nil)
        staffModel.logoutWithDeviceToken(STUserData.sharedInstance.deviceTokenId)
        mainNavigation.dismissDrawerController()
        STUserData.sharedInstance.clearUserData()
    }
    
    func didLogout(noti:Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DidLogout), object: nil)
        if staffModel.isSucess{
            STUserData.sharedInstance.isLoggedIn = false
        }else{
            showAlertWithTitle("", message: (staffModel.error[0]["message"] as! String?)!)
        }
    }
    
}
