//
//  STSettingViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/28/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STSettingViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    
    let ITEM_PER_PAGE_ROW = "item_per_page_row"
    let DASHBOARD_SALES_ROW = "dashboard_sales_row"
    let DASHBOARD_BESTSELLER_ROW = "dashboard_bestseller_row"
    let DASHBOARD_LATEST_ORDERS_ROW = "dashboard_latest_orders_row"
    let DASHBOARD_LATEST_CUSTOMERS_ROW = "dashboard_latest_customers_row"
    
    var userData:STUserData!
    
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<Any>!
    
    var itemPerPageButton:SimiButton!
    var itemPerPageActionSheet:UIActionSheet!
    var itemPerPage = 40
    
    var dashboardSalesSwitch:UISwitch!
    var showDashboardSales = true
    
    var bestsellersSwitch:UISwitch!
    var showDashboardBestsellers = true
    
    var latestOrdersSwitch:UISwitch!
    var showDashboardLatestOrders = true
    
    var latestCustomersSwitch:UISwitch!
    var showDashboardLatestCustomers = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMainTableViewCells()
        
        if (mainTableView == nil) {
            mainTableView = SimiTableView(frame:
                CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight) , style: UITableViewStyle.grouped)
            mainTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
            mainTableView.delegate = self
            mainTableView.dataSource = self
        }
        self.view.addSubview(mainTableView)
        self.title = STLocalizedString(inputString: "Settings").uppercased()
        getSettings()
    }
    
    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Get Settings Data
    func getSettings() {
        if (userData == nil) {
            userData = STUserData()
        }
        let emailSaved = SimiDataLocal.getLocalData(forKey: LAST_USER_EMAIL) as! String
        if (emailSaved != "") {
            userData.userEmail = emailSaved
            userData.loadFromLocal()
            itemPerPage = userData.itemPerPage
            showDashboardSales = userData.showDashboardSales
            showDashboardBestsellers = userData.showDashboardBestsellers
            showDashboardLatestOrders = userData.showDashboardLatestOrders
            showDashboardLatestCustomers = userData.showDashboardLatestCustomers
        }
        
        setMainTableViewCells()
        self.mainTableView .reloadData()
    }
    
    //MARK: - Set Data for TableView
    func setMainTableViewCells() {
        mainTableViewCells = []
        
        let pagingSection = SimiSection()
        pagingSection.data["title"] = STLocalizedString(inputString: "Paging").uppercased()
        let itemPerPageRow:SimiRow = SimiRow(withIdentifier: ITEM_PER_PAGE_ROW, andHeight: 50)
        pagingSection.childRows.append(itemPerPageRow)
        mainTableViewCells.append(pagingSection)
        
        let dashboardSection = SimiSection()
        dashboardSection.data["title"] = STLocalizedString(inputString: "Items Shown On Dashboard").uppercased()
        let salesRow:SimiRow = SimiRow(withIdentifier: DASHBOARD_SALES_ROW, andHeight: 50)
        dashboardSection.childRows.append(salesRow)
        let bestsellerRow:SimiRow = SimiRow(withIdentifier: DASHBOARD_BESTSELLER_ROW, andHeight: 50)
        dashboardSection.childRows.append(bestsellerRow)
        let latestCustomersRow:SimiRow = SimiRow(withIdentifier: DASHBOARD_LATEST_CUSTOMERS_ROW, andHeight: 50)
        dashboardSection.childRows.append(latestCustomersRow)
        let latestOrdersRow:SimiRow = SimiRow(withIdentifier: DASHBOARD_LATEST_ORDERS_ROW, andHeight: 50)
        dashboardSection.childRows.append(latestOrdersRow)
        mainTableViewCells.append(dashboardSection)
    }
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        return row.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: 20))
        let section = mainTableViewCells[section] as! SimiSection
        if section.data["title"] != nil {
            let tittleHeader = SimiLabel(frame: CGRect(x: 15, y: 0, width: SimiGlobalVar.screenWidth - 30, height: 20))
            tittleHeader.text = section.data["title"] as? String
            tittleHeader.font = UIFont.systemFont(ofSize: 11)
            tittleHeader.textColor = UIColor.lightGray
            headerView.addSubview(tittleHeader)
        }
        return headerView
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
            if row.identifier == ITEM_PER_PAGE_ROW {
                cellToReturn = createItemPerPageRow(row: row, identifier: identifier)
            } else if row.identifier == DASHBOARD_SALES_ROW {
                cellToReturn = createSalesRow(row: row, identifier: identifier)
            } else if row.identifier == DASHBOARD_BESTSELLER_ROW {
                cellToReturn = createBestSellersRow(row: row, identifier: identifier)
            } else if row.identifier == DASHBOARD_LATEST_ORDERS_ROW {
                cellToReturn = createLatestOrdersRow(row: row, identifier: identifier)
            } else if row.identifier == DASHBOARD_LATEST_CUSTOMERS_ROW {
                cellToReturn = createLatestCustomersRow(row: row, identifier: identifier)
            }
            else {
                cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            }
        }
        
        cellToReturn?.selectionStyle = UITableViewCellSelectionStyle.none
        return cellToReturn!
    }
    
    
    //MARK: - Paging Settings
    
    func createItemPerPageRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = STSettingCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        itemPerPageButton = SimiButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        itemPerPageButton.setTitle(String(itemPerPage), for: UIControlState.normal)
        itemPerPageButton.backgroundColor = UIColor.white
        itemPerPageButton.layer.borderWidth = 1.5
        itemPerPageButton.layer.borderColor = THEME_COLOR.cgColor
        itemPerPageButton.layer.cornerRadius = 15
        itemPerPageButton.setTitleColor(THEME_COLOR, for: UIControlState.normal)
        itemPerPageButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        itemPerPageButton.addTarget(self, action: #selector(showPageChoosing), for: UIControlEvents.touchUpInside)
        
        cellToReturn.addSettingWith(title: STLocalizedString(inputString: "Items Per Pages"), andView: itemPerPageButton, atHeight: heightCell)
        heightCell += 40
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    func showPageChoosing() {
        if (itemPerPageActionSheet == nil) {
            itemPerPageActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Items Per Page"), delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
            itemPerPageActionSheet.addButton(withTitle: "20")
            itemPerPageActionSheet.addButton(withTitle: "40")
            itemPerPageActionSheet.addButton(withTitle: "60")
            itemPerPageActionSheet.addButton(withTitle: "80")
            itemPerPageActionSheet.addButton(withTitle: "100")
        }
        itemPerPageActionSheet.show(in: self.view)
    }
    
    
    // MARK: - Action Sheet delegate
    func actionSheet(_ actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if (itemPerPageActionSheet != nil) && (actionSheet == itemPerPageActionSheet) {
            if buttonIndex == 0 {
                return
            }
            switch buttonIndex {
            case 1:
                itemPerPage = 20
                break
            case 2:
                itemPerPage = 40
                break
            case 3:
                itemPerPage = 60
                break
            case 4:
                itemPerPage = 80
                break
            case 5:
                itemPerPage = 100
                break
            default:
                break
            }
            itemPerPageButton.setTitle(String(itemPerPage), for: UIControlState.normal)
        }
    }
    
    // MARK: - Dashboard
    func createSalesRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = STSettingCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        dashboardSalesSwitch = UISwitch(frame: CGRect(x: 10, y: 0, width: 60, height: 30))
        dashboardSalesSwitch.onTintColor = THEME_COLOR
        dashboardSalesSwitch.isOn = showDashboardSales
        cellToReturn.addSettingWith(title: STLocalizedString(inputString: "Sales Reports"), andView: dashboardSalesSwitch, atHeight: heightCell)
        heightCell += 40
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    func createBestSellersRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = STSettingCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        bestsellersSwitch = UISwitch(frame: CGRect(x: 10, y: 0, width: 60, height: 30))
        bestsellersSwitch.onTintColor = THEME_COLOR
        bestsellersSwitch.isOn = showDashboardBestsellers
        cellToReturn.addSettingWith(title: STLocalizedString(inputString: "Best Sellers"), andView: bestsellersSwitch, atHeight: heightCell)
        heightCell += 40
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    func createLatestOrdersRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = STSettingCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        latestOrdersSwitch = UISwitch(frame: CGRect(x: 10, y: 0, width: 60, height: 30))
        latestOrdersSwitch.onTintColor = THEME_COLOR
        latestOrdersSwitch.isOn = showDashboardLatestOrders
        cellToReturn.addSettingWith(title: STLocalizedString(inputString: "Latest Orders"), andView: latestOrdersSwitch, atHeight: heightCell)
        heightCell += 40
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    func createLatestCustomersRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = STSettingCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        latestCustomersSwitch = UISwitch(frame: CGRect(x: 10, y: 0, width: 60, height: 30))
        latestCustomersSwitch.onTintColor = THEME_COLOR
        latestCustomersSwitch.isOn = showDashboardLatestCustomers
        cellToReturn.addSettingWith(title: STLocalizedString(inputString: "Latest Customers"), andView: latestCustomersSwitch, atHeight: heightCell)
        heightCell += 40
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    // MARK: - Saving handlers
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    func saveSettings() {
        if (userData == nil) {
            userData = STUserData()
        }
        let emailSaved = SimiDataLocal.getLocalData(forKey: LAST_USER_EMAIL) as! String
        if (emailSaved != "") {
            userData.userEmail = emailSaved
            userData.loadFromLocal()
            userData.itemPerPage = Int((itemPerPageButton.titleLabel?.text)!)!
            userData.showDashboardLatestCustomers = latestCustomersSwitch.isOn
            userData.showDashboardSales = dashboardSalesSwitch.isOn
            userData.showDashboardBestsellers = bestsellersSwitch.isOn
            userData.showDashboardLatestOrders = latestOrdersSwitch.isOn
            userData.saveToLocal()
            SimiGlobalVar.userData = userData
        }
    }
}
