//
//  CustomerDetailViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/20/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STCustomerDetailViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var isEdittingCustomer: Bool = false
    private var preffixTextField:SimiTextField = SimiTextField(), firstNameTextField:SimiTextField = SimiTextField(), middleNameTextField: SimiTextField = SimiTextField(), lastNameTextField:SimiTextField = SimiTextField(), suffixTextField:SimiTextField = SimiTextField(), dobTextField:SimiTextField = SimiTextField()
    
    let SUMMARY_INFO_ROW = "customer_summary_info_row"
    let PROFILE_CUSTOMER_ROW = "profile_customer_row"
    let CUSTOMER_ADDRESS_ROW = "customer_address_row"
    let CUSTOMER_BILLING_ADDRESS_ROW = "customer_billing_address_row"
    let CUSTOMER_SHIPPING_ADDRESS_ROW = "customer_shipping_address_row"
    let CUSTOMER_ORDER_ROW = "customer_orders_row"
    
    let CUSTOMER_SUMMARY_SECTION = "CUSTOMER_SUMMARY_SECTION"
    let CUSTOMER_INFO_SECTION = "CUSTOMER_INFO_SECTION"
    let CUSTOMER_ORDERS_SECTION = "CUSTOMER_ORDERS_SECTION"
    let CUSTOMER_ADDRESSES_SECTION = "CUSTOMER_ADDRESSES_SECTION"
    
    var gotFullInformation = false
    
    var customerModel:CustomerModel!
    var statusDict:Dictionary<String, String>!
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<Any>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackButton()
        self.setMainTableViewCells()
        
        let dobPickerView: UIDatePicker = UIDatePicker()
        dobPickerView.datePickerMode = UIDatePickerMode.date
        dobTextField.inputView = dobPickerView
        dobPickerView.addTarget(self, action: #selector(didSelectDatePicker(datePicker:)), for: UIControlEvents.valueChanged)
        
        if (mainTableView == nil) {
            mainTableView = SimiTableView(frame:
                CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight) , style: UITableViewStyle.grouped)
            mainTableView.contentInset = UIEdgeInsetsMake(20, 0, 60, 0)
            mainTableView.delegate = self
            mainTableView.dataSource = self
        }
        self.view.addSubview(mainTableView)
        self.title = STLocalizedString(inputString: "Customer Details").uppercased()
        getCustomerDetail()
    }
    
    func didSelectDatePicker(datePicker:UIDatePicker){
        dobTextField.text = dateToString(date: datePicker.date, format: "yyyy-MM-dd")
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
    
    //MARK: - Get Customer Detail
    func getCustomerDetail() {
        customerModel.getCustomerDetailWithId(id: (customerModel.data["entity_id"] as! String), params: [:])
        NotificationCenter.default.addObserver(self, selector: #selector(didGetCustomerDetail(notification:)), name: NSNotification.Name(rawValue: "DidGetCustomerDetail"), object: nil)
    }
    
    // Get Customer Detail handler
    func didGetCustomerDetail(notification: NSNotification) {
        self.hideLoadingView()
        gotFullInformation = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetCustomerDetail"), object: nil)
        if customerModel.isSucess == false {
            let alert = UIAlertController(title: "", message: customerModel.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.navigationController!.popViewController(animated: true)
        } else {
            setMainTableViewCells()
            self.mainTableView .reloadData()
        }
    }
    
    //MARK: - Set Data for TableView
    func setMainTableViewCells() {
        mainTableViewCells = []
        
        let summarySection = SimiSection(identifier: CUSTOMER_SUMMARY_SECTION)
        summarySection.data["title"] = STLocalizedString(inputString: "Customer Summary").uppercased()
        let customerSummaryRow:SimiRow = SimiRow(withIdentifier: SUMMARY_INFO_ROW, andHeight: 150)
        summarySection.childRows.append(customerSummaryRow)
        mainTableViewCells.append(summarySection)
        
        let profileSection = SimiSection(identifier: CUSTOMER_INFO_SECTION)
        profileSection.data["title"] = STLocalizedString(inputString: "Customer Information").uppercased()
        let customerOutlineRow:SimiRow = SimiRow(withIdentifier: PROFILE_CUSTOMER_ROW, andHeight: 150)
        profileSection.childRows.append(customerOutlineRow)
        mainTableViewCells.append(profileSection)
        
        if (SimiGlobalVar.permissionsAllowed[ORDER_LIST] == true) {
            let customerOrdersSection = SimiSection(identifier: CUSTOMER_ORDERS_SECTION)
            customerOrdersSection.data["title"] = STLocalizedString(inputString: "Customer Orders").uppercased()
            let customerOrdersRow:SimiRow = SimiRow(withIdentifier: CUSTOMER_ORDER_ROW, andHeight: 40)
            customerOrdersSection.childRows.append(customerOrdersRow)
            mainTableViewCells.append(customerOrdersSection)
        }
        
        if (SimiGlobalVar.permissionsAllowed[CUSTOMER_ADDRESS_LIST] == true) {
            let customerAddressSection = SimiSection(identifier: CUSTOMER_ADDRESSES_SECTION)
            customerAddressSection.data["title"] = STLocalizedString(inputString: "Customer Addresses").uppercased()
            let customerAddressRow:SimiRow = SimiRow(withIdentifier: CUSTOMER_ADDRESS_ROW, andHeight: 40)
            customerAddressSection.childRows.append(customerAddressRow)
            mainTableViewCells.append(customerAddressSection)
            
            if !(customerModel.data["billing_address_data"] is NSNull) && (customerModel.data["billing_address_data"] != nil) {
                let customerBillingAddressSection = SimiSection()
                customerBillingAddressSection.data["title"] = STLocalizedString(inputString: "Default Billing Address").uppercased()
                let customerBillingAddressRow:SimiRow = SimiRow(withIdentifier: CUSTOMER_BILLING_ADDRESS_ROW, andHeight: 150)
                customerBillingAddressSection.childRows.append(customerBillingAddressRow)
                mainTableViewCells.append(customerBillingAddressSection)
            }
            if !(customerModel.data["shipping_address_data"] is NSNull) && (customerModel.data["shipping_address_data"] != nil) {
                let customerShippingAddressSection = SimiSection()
                customerShippingAddressSection.data["title"] = STLocalizedString(inputString: "Default Shipping Address").uppercased()
                let customerShippingAddressRow:SimiRow = SimiRow(withIdentifier: CUSTOMER_SHIPPING_ADDRESS_ROW, andHeight: 150)
                customerShippingAddressSection.childRows.append(customerShippingAddressRow)
                mainTableViewCells.append(customerShippingAddressSection)
            }
        }
    }
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        return row.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: 40))
        let section = mainTableViewCells[section] as! SimiSection
        if section.data["title"] != nil {
            let tittleHeader = SimiLabel(frame: CGRect(x: 15, y: 10, width: SimiGlobalVar.screenWidth - 50, height: 20))
            tittleHeader.text = section.data["title"] as? String
            tittleHeader.font = THEME_FONT
            tittleHeader.textColor = UIColor.white
            headerView.addSubview(tittleHeader)
            let editButton = SimiButton(frame: CGRect(x:SimiGlobalVar.screenWidth - 40,y:0,width:40,height:40))
            editButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            if(section.identifier == CUSTOMER_SUMMARY_SECTION){
                if !isEdittingCustomer{
                    editButton.setImage(UIImage(named:"ic_edit"), for: UIControlState.normal)
                    editButton.addTarget(self, action: #selector(didClickEditSummary), for: UIControlEvents.touchUpInside)
                }else{
                    editButton.setImage(UIImage(named:"ic_tick"), for: UIControlState.normal)
                    editButton.addTarget(self, action: #selector(editCustomerSummary), for: UIControlEvents.touchUpInside)
                }
                headerView .addSubview(editButton)
            }
        }
        headerView.backgroundColor = THEME_COLOR
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
        if (gotFullInformation != true) {
            identifier += "_placeholder"
        }
        
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        if (row.identifier == SUMMARY_INFO_ROW){
            cellToReturn = createSummaryRow(row: row, identifier: identifier)
        }else{
            if (cellToReturn == nil) {
                if row.identifier == PROFILE_CUSTOMER_ROW {
                    cellToReturn = createCustomerProfileRow(row: row, identifier: identifier)
                } else if (row.identifier == CUSTOMER_ADDRESS_ROW) {
                    cellToReturn = createAddressRow(row: row, identifier: identifier)
                } else if (row.identifier == CUSTOMER_BILLING_ADDRESS_ROW) {
                    cellToReturn = createAddressDetailRow(row: row, identifier: identifier, addressData: customerModel.data["billing_address_data"] as! Dictionary<String, Any>)
                } else if (row.identifier == CUSTOMER_SHIPPING_ADDRESS_ROW) {
                    cellToReturn = createAddressDetailRow(row: row, identifier: identifier, addressData: customerModel.data["shipping_address_data"] as! Dictionary<String, Any>)
                }else if (row.identifier == CUSTOMER_ORDER_ROW) {
                    cellToReturn = createOrderRow(row: row, identifier: identifier)
                }
                else {
                    cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
                }
            }
        }
        
        cellToReturn?.selectionStyle = UITableViewCellSelectionStyle.none
        return cellToReturn!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        if (row.identifier == CUSTOMER_ORDER_ROW) {
            let newOrderVC = STOrderListViewController()
            newOrderVC.searchAttribute = "customer_email"
            newOrderVC.isSearchExactlyMatch = true
            newOrderVC.searchTerm = customerModel.data["email"]  as! String
            newOrderVC.createBackButton()
            self.navigationController?.pushViewController(newOrderVC, animated: true)
        } else if (row.identifier == CUSTOMER_ADDRESS_ROW) {
            let newAddressVC = STAddressListViewController()
            newAddressVC.customerId = customerModel.data["entity_id"] as! String
            newAddressVC.createBackButton()
            self.navigationController?.pushViewController(newAddressVC, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    //MARK: - Row creating functions
    func createSummaryRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        
        cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Customer Id"), andValue: (customerModel.data["entity_id"] as? String)!, atHeight: heightCell)
        heightCell += 22
        
        
        if !(customerModel.data["email"] is NSNull) && (customerModel.data["email"] != nil) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Customer Email"), andValue: (customerModel.data["email"] as? String)!, atHeight: heightCell, isCopiable: true)
            heightCell += 22
        }
        
        var preffix: String = ""
        if !(customerModel.data["prefix"] is NSNull) && (customerModel.data["prefix"] != nil){
            preffix = customerModel.data["prefix"] as! String
        }
        cellToReturn.addEditableTextField(textField:preffixTextField, withTitle: STLocalizedString(inputString: "Prefix"), andValue: preffix, atHeight: heightCell)
        cellToReturn.isEditable = isEdittingCustomer
        heightCell += 26
        
        var firstName: String = ""
        if !(customerModel.data["firstname"] is NSNull) && (customerModel.data["firstname"] != nil) {
            firstName = customerModel.data["firstname"] as! String
        }
        cellToReturn.addEditableTextField(textField:firstNameTextField,withTitle: STLocalizedString(inputString: "First Name"), andValue: firstName, atHeight: heightCell)
        cellToReturn.isEditable = isEdittingCustomer
        heightCell += 26
        
        var middleName: String = ""
        if !(customerModel.data["middlename"] is NSNull) && (customerModel.data["middlename"] != nil) {
            middleName = (customerModel.data["middlename"] as? String)!
        }
        cellToReturn.addEditableTextField(textField:middleNameTextField, withTitle: STLocalizedString(inputString: "Middle Name"), andValue: middleName, atHeight: heightCell)
        cellToReturn.isEditable = isEdittingCustomer
        heightCell += 26
        
        var lastName: String = ""
        if !(customerModel.data["lastname"] is NSNull) && (customerModel.data["lastname"] != nil){
            lastName = (customerModel.data["lastname"] as? String)!
        }
        cellToReturn.addEditableTextField(textField:lastNameTextField, withTitle: STLocalizedString(inputString: "Last Name"), andValue: lastName, atHeight: heightCell)
        cellToReturn.isEditable = isEdittingCustomer
        heightCell += 26
        
        var suffix: String = ""
        if !(customerModel.data["suffix"] is NSNull) && (customerModel.data["suffix"] != nil) {
            suffix = (customerModel.data["suffix"] as? String)!
        }
        cellToReturn.addEditableTextField(textField:suffixTextField, withTitle: STLocalizedString(inputString: "Suffix"), andValue: suffix, atHeight: heightCell)
        cellToReturn.isEditable = isEdittingCustomer
        heightCell += 26
        
        var dob: String = ""
        if !(customerModel.data["dob"] is NSNull) && (customerModel.data["dob"] != nil){
            dob = customerModel.data["dob"] as! String
        }
        cellToReturn.addEditableTextField(textField:dobTextField, withTitle: STLocalizedString(inputString: "Dob"), andValue: dob, atHeight: heightCell)
        cellToReturn.isEditable = isEdittingCustomer
        heightCell += 26
        
        heightCell += 8
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    func createCustomerProfileRow(row: SimiRow, identifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        
        if !(customerModel.data["created_at"] is NSNull) && (customerModel.data["created_at"] != nil){
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Created At"), andValue: (customerModel.data["created_at"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(customerModel.data["updated_at"] is NSNull) && (customerModel.data["updated_at"] != nil){
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Last Updated At"), andValue: (customerModel.data["updated_at"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(customerModel.data["updated_at"] is NSNull) && (customerModel.data["updated_at"] != nil){
            var activeString = STLocalizedString(inputString: "No")
            if (customerModel.data["updated_at"] as? String) == "1" {
                activeString = STLocalizedString(inputString: "Yes")
            }
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Is Actived"), andValue: activeString, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(customerModel.data["created_in"] is NSNull) && (customerModel.data["created_in"] != nil){
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Created In"), andValue: (customerModel.data["created_in"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(customerModel.data["gender"] is NSNull) && (customerModel.data["gender"] != nil) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Gender"), andValue: (customerModel.data["gender"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        
        heightCell += 8
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    func createAddressRow(row: SimiRow, identifier: String) -> UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        let customerAddressBookLabel = SimiLabel(frame: CGRect(x: 15, y: 12, width: 300, height: 16))
        customerAddressBookLabel.textColor = UIColor.darkGray
        customerAddressBookLabel.font = UIFont.systemFont(ofSize: 13)
        customerAddressBookLabel.text = STLocalizedString(inputString: "View Customer Address Book").uppercased()
        cellToReturn.addSubview(customerAddressBookLabel)
        
        cellToReturn.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cellToReturn
    }
    
    func createAddressDetailRow(row: SimiRow, identifier: String, addressData: Dictionary<String, Any>)->UITableViewCell{
        let cellToReturn = STAddressTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        cellToReturn.setCellWithInfo(addressData: addressData, row: row)
        return cellToReturn
    }
    
    func createOrderRow(row: SimiRow, identifier: String) -> UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        
        let customerOrderLabel = SimiLabel(frame: CGRect(x: 15, y: 12, width: 300, height: 16))
        customerOrderLabel.textColor = UIColor.darkGray
        customerOrderLabel.font = UIFont.systemFont(ofSize: 13)
        customerOrderLabel.text = STLocalizedString(inputString: "View Customer Orders").uppercased()
        cellToReturn.addSubview(customerOrderLabel)
        
        cellToReturn.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cellToReturn
    }
//MARK: -Handle edit actions
    func didClickEditSummary(){
        isEdittingCustomer = true
        mainTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
        firstNameTextField.becomeFirstResponder()
    }
    
    func editCustomerSummary(){
        var params: Dictionary<String, String> = [String:String]()
        params.updateValue(firstNameTextField.text!, forKey: "firstname")
        params.updateValue(middleNameTextField.text!, forKey: "middlename")
        params.updateValue(lastNameTextField.text!, forKey: "lastname")
        params.updateValue(suffixTextField.text!, forKey: "suffix")
        params.updateValue(preffixTextField.text!, forKey: "prefix")
        if !(dobTextField.text?.isEmpty)!{
            let dobElements = splitDate(date: stringToDate(dateString:dobTextField.text!, format:"yyyy-MM-dd"))
            params.updateValue(dobElements.0 , forKey: "day")
            params.updateValue(dobElements.1 , forKey: "month")
            params.updateValue(dobElements.2 , forKey: "year")
        }
        customerModel.editCustomerDetailWithId(id: (customerModel.data["entity_id"] as! String), params: params)
        NotificationCenter.default.addObserver(self, selector: #selector(didEditCustomerDetail(notification:)), name: NSNotification.Name(rawValue: DidEditCustomerDetail), object: nil)
        self.showLoadingView()
    }
    
    func didEditCustomerDetail(notification:NSNotification){
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
        isEdittingCustomer = false
        mainTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
    }
    
}
