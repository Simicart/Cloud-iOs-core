//
//  STSettingViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/28/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STSettingViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    let ITEM_PER_PAGE_ROW = "item_per_page_row"
    let DASHBOARD_SALES_ROW = "dashboard_sales_row"
    let DASHBOARD_BESTSELLER_ROW = "dashboard_bestseller_row"
    let DASHBOARD_LATEST_ORDERS_ROW = "dashboard_latest_orders_row"
    let DASHBOARD_LATEST_CUSTOMERS_ROW = "dashboard_latest_customers_row"
    
    let CURRENCY_POSITION_ROW = "CURRENCY_POSITION_ROW"
    let DECIMAL_NUMBER_ROW = "DECIMAL_NUMBER_ROW"
    let SEPARATOR_ROW = "SEPARATOR_ROW"
    
    private var isShowingKeyboard: Bool = false
    
    private var userData:STUserData = STUserData.sharedInstance
    
    private var mainTableView:SimiTableView!
    private var tableCells: SimiTable!
    
    private var itemPerPageButton:SimiButton!
    private var itemPerPageActionSheet:UIActionSheet!
    private var itemPerPage = 40
    private var currencyPositions = [currencyLeft, currencyRight, currencyLeftSpace, currencyRightSpace]
    private var separatorTypes = [separatorType1, separatorType2]
    private var currencyPos = ""
    private var decimalNumber = ""
    private var separatorType = "1"
    
    private var dashboardSalesSwitch:UISwitch!
    private var showDashboardSales = true
    
    private var bestsellersSwitch:UISwitch!
    private var showDashboardBestsellers = true
    
    private var latestOrdersSwitch:UISwitch!
    private var showDashboardLatestOrders = true
    
    private var latestCustomersSwitch:UISwitch!
    private var showDashboardLatestCustomers = true
    
    private var currencyPosTextField: SimiTextField = SimiTextField()
    private var decimalNumberTextField: SimiTextField = SimiTextField()
    private var separatorTextField:SimiTextField = SimiTextField()
    
    private var currencyPosPicker: UIPickerView = UIPickerView()
    private var separatorPicker:UIPickerView = UIPickerView()
    private var decimalNumberPicker: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMainTableViewCells()
        if (mainTableView == nil) {
            mainTableView = SimiTableView(frame:
                CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight) , style: UITableViewStyle.grouped)
            mainTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
            mainTableView.delegate = self
            mainTableView.dataSource = self
            mainTableView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(tableViewTapped(sender:))))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.view.addSubview(mainTableView)
        self.title = STLocalizedString(inputString: "Settings").uppercased()
        getSettings()
    }
    
    
    func tableViewTapped(sender:Any){
        view.endEditing(true)
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
        let emailSaved = SimiDataLocal.getLocalData(forKey: LAST_USER_EMAIL) as! String
        if (emailSaved != "") {
            userData.userEmail = emailSaved
            itemPerPage = userData.itemPerPage
            showDashboardSales = userData.showDashboardSales
            showDashboardBestsellers = userData.showDashboardBestsellers
            showDashboardLatestOrders = userData.showDashboardLatestOrders
            showDashboardLatestCustomers = userData.showDashboardLatestCustomers
            
            currencyPos = userData.currencyPosition
            decimalNumber = userData.decimalNumber
            separatorType = userData.separatorType
        }
        
        setMainTableViewCells()
        self.mainTableView .reloadData()
    }
    
    //MARK: - Set Data for TableView
    func setMainTableViewCells() {
        tableCells = SimiTable()
        
        let pagingSection = SimiSection()
        pagingSection.data["title"] = STLocalizedString(inputString: "Paging").uppercased()
        let itemPerPageRow:SimiRow = SimiRow(withIdentifier: ITEM_PER_PAGE_ROW, andHeight: 50)
        pagingSection.childRows.append(itemPerPageRow)
        tableCells.addSection(pagingSection)
        
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
        tableCells.addSection(dashboardSection)
        
        let priceSettingSection = SimiSection()
        priceSettingSection.data["title"] = STLocalizedString(inputString: "Currency Setting").uppercased()
        let currencyPositionRow:SimiRow = SimiRow(withIdentifier: CURRENCY_POSITION_ROW, andHeight:50)
        priceSettingSection.childRows.append(currencyPositionRow)
        let decimalNumberRow: SimiRow = SimiRow(withIdentifier: DECIMAL_NUMBER_ROW, andHeight:50)
        priceSettingSection.childRows.append(decimalNumberRow)
//        let separatorRow: SimiRow = SimiRow(withIdentifier: SEPARATOR_ROW, andHeight:50)
//        priceSettingSection.childRows.append(separatorRow)
        tableCells.addSection(priceSettingSection)
    }
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = tableCells.sectionAtIndex(index: indexPath.section)
        let row = section.childRows[indexPath.row]
        return row.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: 20))
        let section = tableCells.sectionAtIndex(index: section)
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
        return tableCells.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainSection =  tableCells.sectionAtIndex(index: section)
        return mainSection.childRows.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = tableCells.sectionAtIndex(index: indexPath.section)
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
            }else if row.identifier == CURRENCY_POSITION_ROW{
                cellToReturn = createCurrencyPositionRow(row: row, identifier: identifier)
            }else if row.identifier == DECIMAL_NUMBER_ROW{
                cellToReturn = createDecimalNumberRow(row: row, identifier: identifier)
            }else if row.identifier == SEPARATOR_ROW{
                cellToReturn = createSeparatorRow(row:row, identifier:identifier)
            }
        }
        if !(cellToReturn != nil){
            cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
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
            if userData.itemPerPage != Int((itemPerPageButton.titleLabel?.text)!)!{
                userData.itemPerPage = Int((itemPerPageButton.titleLabel?.text)!)!
                trackEvent("setting", params: ["paging":(itemPerPageButton.titleLabel?.text)!])
            }
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
    
    func createCurrencyPositionRow(row: SimiRow, identifier:String) -> UITableViewCell{
        let cellToReturn = STSettingCell(style:UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        currencyPosTextField = SimiTextField(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        currencyPosTextField.textAlignment = .center
        currencyPosTextField.text = currencyPos
        currencyPosTextField.backgroundColor = UIColor.white
        currencyPosTextField.layer.borderWidth = 1.5
        currencyPosTextField.layer.borderColor = THEME_COLOR.cgColor
        currencyPosTextField.layer.cornerRadius = 5
        currencyPosTextField.textColor = THEME_COLOR
        currencyPosTextField.font = THEME_FONT
        currencyPosPicker = UIPickerView()
        currencyPosPicker.delegate = self
        currencyPosPicker.dataSource = self
        currencyPosTextField.inputView = currencyPosPicker
        
        cellToReturn.addSettingWith(title: STLocalizedString(inputString: "Currency Position"), andView: currencyPosTextField, atHeight: heightCell)
        heightCell += 40
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    func createDecimalNumberRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = STSettingCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        decimalNumberTextField = SimiTextField(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        decimalNumberTextField.textAlignment = .center
        decimalNumberTextField.text = decimalNumber
        decimalNumberTextField.backgroundColor = UIColor.white
        decimalNumberTextField.layer.borderWidth = 1.5
        decimalNumberTextField.layer.borderColor = THEME_COLOR.cgColor
        decimalNumberTextField.layer.cornerRadius = 5
        decimalNumberTextField.textColor = THEME_COLOR
        decimalNumberTextField.font = THEME_FONT
        decimalNumberPicker = UIPickerView()
        decimalNumberPicker.delegate = self
        decimalNumberPicker.dataSource = self
        decimalNumberTextField.inputView = decimalNumberPicker
        
        cellToReturn.addSettingWith(title: STLocalizedString(inputString: "Decimal Number"), andView: decimalNumberTextField, atHeight: heightCell)
        heightCell += 40
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    func createSeparatorRow(row:SimiRow, identifier:String) -> UITableViewCell{
        let cellToReturn = STSettingCell(style:UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        separatorTextField = SimiTextField(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        separatorTextField.textAlignment = .center
        separatorTextField.text = separatorType
        separatorTextField.backgroundColor = UIColor.white
        separatorTextField.layer.borderWidth = 1.5
        separatorTextField.layer.borderColor = THEME_COLOR.cgColor
        separatorTextField.layer.cornerRadius = 5
        separatorTextField.textColor = THEME_COLOR
        separatorTextField.font = THEME_FONT
        separatorPicker = UIPickerView()
        separatorPicker.delegate = self
        separatorPicker.dataSource = self
        separatorTextField.inputView = separatorPicker
        
        cellToReturn.addSettingWith(title: STLocalizedString(inputString: "Separator"), andView: separatorTextField, atHeight: heightCell)
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
        let emailSaved = SimiDataLocal.getLocalData(forKey: LAST_USER_EMAIL) as! String
        if (emailSaved != "") {
            if userData.userEmail != emailSaved{
                userData.userEmail = emailSaved
            }
            if userData.showDashboardLatestCustomers != latestCustomersSwitch.isOn{
                userData.showDashboardLatestCustomers = latestCustomersSwitch.isOn
                if latestCustomersSwitch.isOn{
                    trackEvent("setting", params: ["show_reports_on_dashboard":"enable"])
                }else{
                    trackEvent("setting", params: ["show_reports_on_dashboard":"disable"])
                }
                didChangeShowingItemOnDashboard = true
            }
            if userData.showDashboardSales != dashboardSalesSwitch.isOn{
                userData.showDashboardSales = dashboardSalesSwitch.isOn
                if dashboardSalesSwitch.isOn{
                    trackEvent("setting", params: ["show_bestsellers_on_dashboard":"enable"])
                }else{
                    trackEvent("setting", params: ["show_bestsellers_on_dashboard":"disable"])
                }
                didChangeShowingItemOnDashboard = true
            }
            
            if userData.showDashboardBestsellers != bestsellersSwitch.isOn{
                userData.showDashboardBestsellers = bestsellersSwitch.isOn
                if bestsellersSwitch.isOn{
                    trackEvent("setting", params: ["show_latest_customers_on_dashboard":"enable"])
                }else{
                    trackEvent("setting", params: ["show_latest_customers_on_dashboard":"disable"])
                }
                didChangeShowingItemOnDashboard = true
            }
            if userData.showDashboardLatestOrders != latestOrdersSwitch.isOn{
                userData.showDashboardLatestOrders = latestOrdersSwitch.isOn
                if latestOrdersSwitch.isOn{
                    trackEvent("setting", params: ["show_lastest_orders_on_dashboard":"enable"])
                }else{
                    trackEvent("setting", params: ["show_lastest_orders_on_dashboard":"disable"])
                }
                didChangeShowingItemOnDashboard = true
            }
        }
    }

    //MARK: -UIPickerViewDelegate && UIPickerViewDataSource
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == currencyPosPicker{
            return currencyPositions.count
        }else if pickerView == separatorPicker{
            return separatorTypes.count
        }else{
            return 10
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == currencyPosPicker{
            return currencyPositions[row]
        }else if pickerView == separatorPicker{
            return separatorTypes[row]
        }else{
            return String(row)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == currencyPosPicker{
            currencyPosTextField.text = currencyPositions[row]
            if userData.currencyPosition != currencyPosTextField.text!{
                userData.currencyPosition = currencyPosTextField.text!
                if currencyPosTextField.text == currencyLeft{
                    trackEvent("setting", params: ["currency_position":"left"])
                }else if currencyPosTextField.text == currencyRight{
                    trackEvent("setting", params: ["currency_position":"right"])
                }else if currencyPosTextField.text == currencyLeftSpace{
                    trackEvent("setting", params: ["currency_position":"left_space"])
                }else if currencyPosTextField.text == currencyRightSpace{
                    trackEvent("setting", params: ["currency_position":"right_space"])
                }
            }
        } else if pickerView == decimalNumberPicker{
            decimalNumberTextField.text = String(row)
            if userData.decimalNumber != decimalNumberTextField.text{
                userData.decimalNumber = decimalNumberTextField.text!
            }
        }else{
            separatorTextField.text = separatorTypes[row]
            if userData.separatorType != separatorTextField.text!{
                userData.separatorType = separatorTextField.text!
                if separatorType == separatorType1{
                    trackEvent("setting", params: ["currency_separator":"type_1"])
                }else{
                    trackEvent("setting", params: ["currency_separator":"type_2"])
                }
            }
        }
    }
    
    
    func keyboardWillShow(noti: Notification){
        if !isShowingKeyboard {
            print("keyboardWillShow")
            if let keyboardSize = (noti.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                //let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                var frame = mainTableView.frame
                frame.origin.y = frame.origin.y - keyboardSize.height
                mainTableView.frame = frame
            }
        }
        isShowingKeyboard = true
    }
    
    func keyboardWillHide(noti: Notification){
        if isShowingKeyboard {
            print("keyboardWillHide")
            if let keyboardSize = (noti.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                //let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                var frame = mainTableView.frame
                frame.origin.y = frame.origin.y + keyboardSize.height
                mainTableView.frame = frame
            }
        }
        isShowingKeyboard = false
    }
    
}
