//
//  STProductDetailViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/25/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit


protocol STProductShortDescriptionDelegate {
    func editProductShortDescription(content:String)
    func editProductDescription(content:String)
}

class STProductDetailViewController: StoreviewFilterViewController, UITableViewDelegate, UITableViewDataSource, STProductShortDescriptionDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let PRODUCT_NAME_ROW = "product_name_row"
    let PRODUCT_SUMMARY_INFO_ROW = "product_summary_info_row"
    let PRODUCT_IMAGE_ROW = "product_image_row"
    let PRODUCT_SHORT_DESCRIPTION_ROW = "product_short_descrption_row"
    let PRODUCT_SHORT_DESCRIPTION_VIEW_DETAIL_ROW = "product_short_descrption_view_detail_row"
    let PRODUCT_DESCRIPTION_ROW = "product_descrption_row"
    let PRODUCT_DESCRIPTION_VIEW_DETAIL_ROW = "product_descrption_view_detail_row"
    let PRODUCT_ATTRIBUTE_ROW = "product_attribute_row"
    
    let PRODUCT_INFORMATION_SECTION = "PRODUCT_INFORMATION_SECTION"
    let PRODUCT_IMAGES_SECTION = "PRODUCT_IMAGES_SECTION"
    let PRODUCT_SHORT_DESCRIPTION_SECTION = "PRODUCT_SHORT_DESCRIPTION"
    let PRODUCT_DESCRIPTION_SECTION = "PRODUCT_DESCRIPTION_SECTION"
    let PRODUCT_ADDITIONAL_SECTION = "PRODUCT_ADDITIONAL"

    public var productModel:ProductModel!
    private var mainTableView:SimiTableView!
    var mainTableViewCells:Array<Any>!
    
    var gotFullInformation = false
    private var isInfoEditting = false
    
    private var stockTextField: SimiTextField = SimiTextField()
    private var nameTextField: SimiTextField = SimiTextField()
    private var qtyTextField: SimiTextField = SimiTextField()
    private var infoEditButton: SimiButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackButton()
        self.setMainTableViewCells()
        
        if (mainTableView == nil) {
            mainTableView = SimiTableView(frame:
                CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight) , style: UITableViewStyle.grouped)
            mainTableView.contentInset = UIEdgeInsetsMake(20, 0, 60, 0)
            mainTableView.delegate = self
            mainTableView.dataSource = self
        }
        self.view.addSubview(mainTableView)
        self.title = STLocalizedString(inputString: "Product Details").uppercased()
        getProductDetail()
        
        //config ediable textfields
        let stockPicker: UIPickerView = UIPickerView()
        stockPicker.delegate = self
        stockTextField.inputView = stockPicker
        qtyTextField.keyboardType = .decimalPad
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
    
    //MARK: - Get Product Detail
    func getProductDetail() {
        var parameters:Dictionary<String, String> = [:]
        if (SimiGlobalVar.selectedStoreId != "") {
            parameters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        else {
            parameters["store_id"] = "0"
        }
        productModel.getProductDetailWithId(id: (productModel.data["entity_id"] as! String), params: parameters)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetProductDetail(notification:)), name: NSNotification.Name(rawValue: "DidGetProductDetail"), object: nil)
    }
    
    //Get Abandoned Cart Detail handler
    func didGetProductDetail(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetProductDetail"), object: nil)
        if productModel.isSucess == false {
            showAlertWithTitle("", message: (productModel.error[0]["message"] as! String?)!)
            self.navigationController!.popViewController(animated: true)
        } else {
            gotFullInformation = true
            setMainTableViewCells()
            self.mainTableView .reloadData()
        }
    }
    
    //MARK: - Set Data for TableView
    func setMainTableViewCells() {
        mainTableViewCells = []
        let summarySection = SimiSection(identifier:PRODUCT_INFORMATION_SECTION)
        summarySection.data["title"] = STLocalizedString(inputString: "Product Information").uppercased()
        let productNameRow:SimiRow = SimiRow(withIdentifier: PRODUCT_NAME_ROW, andHeight: 50)
        summarySection.childRows.append(productNameRow)
        let productInfoRow:SimiRow = SimiRow(withIdentifier: PRODUCT_SUMMARY_INFO_ROW, andHeight: 170)
        summarySection.childRows.append(productInfoRow)
        mainTableViewCells.append(summarySection)
        
        if (productModel.data["images"] != nil) &&  !(productModel.data["images"] is NSNull) {
            let itemArray = productModel.data["images"] as! Array<Dictionary<String, Any>>
            if (itemArray.count > 0) {
                let itemsSection = SimiSection(identifier:PRODUCT_IMAGES_SECTION)
                itemsSection.data["title"] = STLocalizedString(inputString: "Product Images").uppercased()
                var itemCount = 0
                for item in itemArray {
                    itemCount += 1
                    let customerImageRow:SimiRow = SimiRow(withIdentifier: (PRODUCT_IMAGE_ROW + String(itemCount)), andHeight: 100)
                    customerImageRow.data = item
                    itemsSection.childRows.append(customerImageRow)
                }
                mainTableViewCells.append(itemsSection)
            }
        }
        
        if (productModel.data["short_description"] != nil) &&  !(productModel.data["short_description"] is NSNull) {
            if (productModel.data["short_description"] as! String) != "" {
                let shortDescription = SimiSection(identifier:PRODUCT_SHORT_DESCRIPTION_SECTION)
                shortDescription.data["title"] = STLocalizedString(inputString: "Short Description").uppercased()
                let shortDescriptionRow:SimiRow = SimiRow(withIdentifier: PRODUCT_SHORT_DESCRIPTION_ROW, andHeight: 100)
                shortDescription.childRows.append(shortDescriptionRow)
                let shortDescriptionViewDetailRow:SimiRow = SimiRow(withIdentifier: PRODUCT_SHORT_DESCRIPTION_VIEW_DETAIL_ROW, andHeight: 40)
                shortDescription.childRows.append(shortDescriptionViewDetailRow)
                mainTableViewCells.append(shortDescription)
            }
        }
        
        if (productModel.data["description"] != nil) &&  !(productModel.data["description"] is NSNull) {
            if (productModel.data["description"] as! String) != "" {
                let descriptionSection = SimiSection(identifier: PRODUCT_DESCRIPTION_SECTION)
                descriptionSection.data["title"] = STLocalizedString(inputString: "Description").uppercased()
                let descriptionRow:SimiRow = SimiRow(withIdentifier: PRODUCT_DESCRIPTION_ROW, andHeight: 100)
                descriptionSection.childRows.append(descriptionRow)
                let descriptionViewDetailRow:SimiRow = SimiRow(withIdentifier: PRODUCT_DESCRIPTION_VIEW_DETAIL_ROW, andHeight: 40)
                descriptionSection.childRows.append(descriptionViewDetailRow)
                mainTableViewCells.append(descriptionSection)
            }
        }
        
        if (productModel.data["additional"] != nil) &&  !(productModel.data["additional"] is NSNull) &&  !(productModel.data["additional"] is Array<Any>) {
            let attributeArray = productModel.data["additional"] as! Dictionary<String, Dictionary<String, Any>>
            if (attributeArray.count > 0) {
                let additionalSection = SimiSection(identifier:PRODUCT_ADDITIONAL_SECTION)
                additionalSection.data["title"] = STLocalizedString(inputString: "Additional").uppercased()
                var itemCount = 0
                for (_, item) in attributeArray {
                    itemCount += 1
                    let productAttributeRow:SimiRow = SimiRow(withIdentifier: (PRODUCT_ATTRIBUTE_ROW + String(itemCount)), andHeight: 40)
                    productAttributeRow.data = item
                    additionalSection.childRows.append(productAttributeRow)
                }
                mainTableViewCells.append(additionalSection)
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
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: 30))
        headerView.backgroundColor = THEME_COLOR
        let section = mainTableViewCells[section] as! SimiSection
        if section.data["title"] != nil {
            let tittleHeader = SimiLabel(frame: CGRect(x: 15, y: 10, width: SimiGlobalVar.screenWidth - 50, height: 20))
            tittleHeader.text = section.data["title"] as? String
            tittleHeader.font = THEME_BOLD_FONT
            tittleHeader.textColor = UIColor.white
            headerView.addSubview(tittleHeader)
            let editButton = SimiButton(frame: CGRect(x:SimiGlobalVar.screenWidth - 40,y:0,width:40,height:40))
            editButton.setImage(UIImage(named:"ic_edit"), for: UIControlState.normal)
            editButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            if(section.identifier == PRODUCT_INFORMATION_SECTION){
                editButton.addTarget(self, action: #selector(didClickEditInformation), for: UIControlEvents.touchUpInside)
                headerView .addSubview(editButton)
                infoEditButton = editButton
                if(isInfoEditting){
                    infoEditButton.setImage(UIImage(named:"ic_tick"), for: .normal)
                    editButton.addTarget(self, action: #selector(editInformation), for: .touchUpInside)
                }
            }else if(section.identifier == PRODUCT_SHORT_DESCRIPTION_SECTION){
                editButton.addTarget(self, action: #selector(editShortDescription), for: UIControlEvents.touchUpInside)
                headerView.addSubview(editButton)
            }else if(section.identifier == PRODUCT_DESCRIPTION_SECTION){
                editButton.addTarget(self, action: #selector(editDescription), for: UIControlEvents.touchUpInside)
                headerView.addSubview(editButton)
            }
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
        if (gotFullInformation != true) {
            identifier += "_placeholder"
        }
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        if(row.identifier == PRODUCT_SHORT_DESCRIPTION_ROW){
            cellToReturn = createShortDescriptionRow(row: row, reuseIdentifier: identifier)
        }else if(row.identifier == PRODUCT_DESCRIPTION_ROW){
            cellToReturn = createDescriptionRow(row: row, reuseIdentifier: identifier)
        }else if(row.identifier == PRODUCT_SUMMARY_INFO_ROW){
            cellToReturn = createSummaryRow(row: row, identifier: identifier)
        }else if(row.identifier == PRODUCT_NAME_ROW){
            cellToReturn = createNameRow(row: row, identifier: identifier)
        }else{
            if (cellToReturn == nil) {
                if row.identifier.range(of:PRODUCT_IMAGE_ROW) != nil {
                    cellToReturn = createImageRow(row: row, reuseIdentifier: identifier)
                }                else if row.identifier.range(of:PRODUCT_ATTRIBUTE_ROW) != nil {
                    cellToReturn = createAttributeRow(row: row, reuseIdentifier: identifier)
                }
                else if (row.identifier == PRODUCT_DESCRIPTION_VIEW_DETAIL_ROW) || (row.identifier == PRODUCT_SHORT_DESCRIPTION_VIEW_DETAIL_ROW) {
                    cellToReturn = createViewDetailRow(row: row, reuseIdentifier: identifier)
                }
            }
        }
        if(cellToReturn == nil){
            cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        cellToReturn?.selectionStyle = UITableViewCellSelectionStyle.none
        return cellToReturn!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        if (row.identifier.range(of:PRODUCT_SHORT_DESCRIPTION_VIEW_DETAIL_ROW) != nil) {
            let shortDescriptionVC = STProductDescriptionViewController()
            shortDescriptionVC.isAbleEditting = false
            shortDescriptionVC.content = (productModel.data["short_description"] as? String)!
            shortDescriptionVC.title = STLocalizedString(inputString: "Short Description")
            trackEvent("product_detail_action", params: ["action":"view_short_description"])
            self.navigationController?.pushViewController(shortDescriptionVC, animated: true)
        }else if(row.identifier.range(of: PRODUCT_DESCRIPTION_VIEW_DETAIL_ROW) != nil){
            let descriptionVC = STProductDescriptionViewController()
            descriptionVC.isAbleEditting = false
            descriptionVC.content = (productModel.data["description"] as? String)!
            descriptionVC.title = STLocalizedString(inputString: "Description")
            trackEvent("product_detail_action", params: ["action":"view_description"])
            self.navigationController?.pushViewController(descriptionVC, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    //MARK: - Row creating functions
    
    func createNameRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        
        if !(productModel.data["name"] is NSNull) && (productModel.data["name"] != nil) {
            nameTextField = SimiTextField(frame: CGRect(x: 15, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 30), height: 41))
            nameTextField.textColor = UIColor.darkGray
            nameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
            nameTextField.font = UIFont.boldSystemFont(ofSize: 15)
            nameTextField.text = (productModel.data["name"] as? String)
            cellToReturn.addSubview(nameTextField)
            heightCell += 40
        }
        if isInfoEditting{
            nameTextField.layer.borderWidth = 0.5
            nameTextField.layer.borderColor = UIColor.lightGray.cgColor
            nameTextField.isEditable = true
            nameTextField.becomeFirstResponder()
        }else{
            nameTextField.layer.borderWidth = 0
            nameTextField.isEditable = false
        }
        heightCell += 8
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
        
    func createSummaryRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        
        if !(productModel.data["entity_id"] is NSNull) && (productModel.data["entity_id"] != nil) {
            
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "ID"), andValue: (productModel.data["entity_id"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(productModel.data["sku"] is NSNull) && (productModel.data["sku"] != nil) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "SKU"), andValue: (productModel.data["sku"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(productModel.data["url_path"] is NSNull) && (productModel.data["url_path"] != nil) {
            cellToReturn.addURLLabel(withTitle: STLocalizedString(inputString: "URL"), value: (SimiGlobalVar.baseURL + (productModel.data["url_path"] as? String)!), atHeight: heightCell, urlType: .webURL)
            heightCell += 22
        }
        
        if !(productModel.data["type_id"] is NSNull) && (productModel.data["type_id"] != nil) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Product Type"), andValue: (productModel.data["type_id"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(productModel.data["price"] is NSNull) && (productModel.data["price"] != nil) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Price"), andValue: SimiGlobalVar.getPrice(currency: SimiGlobalVar.baseCurrency, value: (productModel.data["price"] as? String)!), atHeight: heightCell)
            heightCell += 22
        }
        
        if !(productModel.data["visibility"] is NSNull) && (productModel.data["visibility"] != nil) {
            var visibilityString = productModel.data["visibility"] as! String
            let visibilityGlobal = SimiGlobalVar.productVisibility[productModel.data["visibility"] as! String]
            if visibilityGlobal != nil {
                visibilityString = visibilityGlobal!
            }
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Visibility"), andValue:visibilityString, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(productModel.data["stock_item"] is NSNull) && (productModel.data["stock_item"] != nil) {
            let stockData = productModel.data["stock_item"] as! Dictionary<String, Any>
            if !(stockData["is_in_stock"] is NSNull) && (stockData["is_in_stock"] != nil)  {
                var stockString = STLocalizedString(inputString: "In Stock")
                if((String(describing: stockData["is_in_stock"]!)) == "0"){
                    stockString = STLocalizedString(inputString: "Out of Stock")
                }
                cellToReturn.addEditableTextField(textField: stockTextField, withTitle: STLocalizedString(inputString: "Stock Status"), andValue: stockString, atHeight: heightCell)
                heightCell += 26
            }
            
            if(!(stockData["qty"] is NSNull) && stockData["qty"] != nil){
//                let qtyInt: Int = Int(Float( as! NSNumber))
                cellToReturn.addEditableTextField(textField: qtyTextField, withTitle: STLocalizedString(inputString: "Quantity"), andValue: "\(stockData["qty"]!)", atHeight: heightCell)
                heightCell += 26
            }
        }
        
        heightCell += 8
        row.height = CGFloat(heightCell)
        cellToReturn.isEditable = isInfoEditting
        return cellToReturn
    }
    
    func createImageRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        let itemData = row.data
        
        let productImage = SimiImageView(frame: CGRect(x: 15, y: 10, width: 80, height: 80))
        productImage.layer.masksToBounds = true
        productImage.contentMode = UIViewContentMode.scaleAspectFill
        productImage.layer.borderColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#EFEFEF").cgColor
        productImage.layer.borderWidth = 0.5
        if (itemData["url"] == nil) || !(itemData["url"] is NSNull) {
            let urlAvatar = URL(string: (itemData["url"] as! String))
            productImage.sd_setImage(with: urlAvatar, placeholderImage: UIImage(named: "default_avt"))
            let productImageUrl = SimiLabel(frame: CGRect(x: 105, y: 10, width: Int(SimiGlobalVar.screenWidth - 120), height: 80))
            productImageUrl.textColor = UIColor.lightGray
            productImageUrl.font = UIFont.systemFont(ofSize: 12)
            productImageUrl.text = itemData["url"] as? String
            productImageUrl.isURL = true
            productImageUrl.numberOfLines = 0
            cellToReturn.addSubview(productImageUrl)
        }else {
            productImage.image = UIImage(named: "default_avt")
        }
        cellToReturn.addSubview(productImage)
        return cellToReturn
    }
    
    func createDescriptionRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        let itemData = productModel.data
        let descriptionString = itemData["description"] as? String
        
        let productDescription = UITextView(frame: CGRect(x: 15, y: 10, width: Int(SimiGlobalVar.screenWidth - 30), height: 80))
        productDescription.textColor = UIColor.gray
        productDescription.font = UIFont.systemFont(ofSize: 12)
        productDescription.text = descriptionString
        productDescription.isEditable = false
        cellToReturn.addSubview(productDescription)
        return cellToReturn
    }
    
    func createShortDescriptionRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        let itemData = productModel.data
        
        let productShortDescription = UITextView(frame: CGRect(x: 15, y: 10, width: Int(SimiGlobalVar.screenWidth - 30), height: 80))
        productShortDescription.textColor = UIColor.gray
        productShortDescription.font = UIFont.systemFont(ofSize: 12)
        productShortDescription.text = itemData["short_description"] as? String
        productShortDescription.isEditable = false
        cellToReturn.addSubview(productShortDescription)
        return cellToReturn
    }
    
    func createAttributeRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        let itemData = row.data
        let titleString = (itemData["label"] as! String) + " (" + (itemData["code"] as! String) + ")"
        cellToReturn.addValueLabel(withTitle: titleString, andValue: (itemData["value"] as! String), atHeight: 13)
        
        return cellToReturn
    }
    
    func createViewDetailRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        cellToReturn.textLabel?.text = STLocalizedString(inputString: "View Detail")
        cellToReturn.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cellToReturn
    }
    
    // MARK: - Switch Store
    override func switchStore() {
        super.switchStore()
        getProductDetail()
        showLoadingView()
    }
    
    //MARK: - edit actions
    func didClickEditInformation() {
        isInfoEditting = true
        mainTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
        infoEditButton.setImage(UIImage(named:"ic_tick"), for: UIControlState.normal)
        infoEditButton.removeTarget(self, action: #selector(didClickEditInformation), for: .touchUpInside)
        infoEditButton.addTarget(self, action: #selector(editInformation), for: UIControlEvents.touchUpInside)
    }
    func editInformation(){
        var parameters:Dictionary<String, String> = [:]
        if (SimiGlobalVar.selectedStoreId != "") {
            parameters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        else {
            parameters["store_id"] = "0"
        }
        parameters["qty"] = qtyTextField.text
        if(stockTextField.text == "Out of Stock"){
            parameters["is_in_stock"] = "0"
        }else{
            parameters["is_in_stock"] = "1"
        }
        parameters["name"] = nameTextField.text
        productModel.editProductDetailWithId(id: productModel.data["entity_id"] as! String, params: parameters)
        trackEvent("product_detail_action", params: ["edit_action":"product_information"])
        NotificationCenter.default.addObserver(self, selector: #selector(didEditProductDetail(notification:)), name: Notification.Name(rawValue: DidEditProductDetail), object: nil)
        self.view .endEditing(true)
        self.showLoadingView()
    }
    func editShortDescription(){
        let shortDescriptionVC = STProductDescriptionViewController()
        shortDescriptionVC.isAbleEditting = true
        shortDescriptionVC.isShortDescription = true
        shortDescriptionVC.delegate = self
        shortDescriptionVC.content = (productModel.data["short_description"] as? String)!
        shortDescriptionVC.title = STLocalizedString(inputString: "Short Description")
        self.navigationController?.pushViewController(shortDescriptionVC, animated: true)
    }
    func editDescription(){
        let descriptionVC = STProductDescriptionViewController()
        descriptionVC.isAbleEditting = true
        descriptionVC.isShortDescription = false
        descriptionVC.delegate = self
        descriptionVC.content = (productModel.data["description"] as? String)!
        descriptionVC.title = STLocalizedString(inputString: "Description")
        self.navigationController?.pushViewController(descriptionVC, animated: true)
    }
    //MARK: -STProductShortDescriptionDelegate
    func editProductShortDescription(content: String) {
        var parameters:Dictionary<String, String> = [:]
        if (SimiGlobalVar.selectedStoreId != "") {
            parameters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        else {
            parameters["store_id"] = "0"
        }
        parameters["short_description"] = content
        productModel.editProductDetailWithId(id: productModel.data["entity_id"] as! String, params: parameters)
        trackEvent("product_detail_action", params: ["edit_action":"short_description"])
        NotificationCenter.default.addObserver(self, selector: #selector(didEditProductDetail(notification:)), name: Notification.Name(rawValue: DidEditProductDetail), object: nil)
        self.showLoadingView()
    }
    
    func editProductDescription(content: String) {
        var parameters:Dictionary<String, String> = [:]
        if (SimiGlobalVar.selectedStoreId != "") {
            parameters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        else {
            parameters["store_id"] = "0"
        }
        parameters["description"] = content
        productModel.editProductDetailWithId(id: productModel.data["entity_id"] as! String, params: parameters)
        trackEvent("product_detail_action", params: ["edit_action":"description"])
        NotificationCenter.default.addObserver(self, selector: #selector(didEditProductDetail(notification:)), name: Notification.Name(rawValue: DidEditProductDetail), object: nil)
        self.showLoadingView()
    }
    
    func didEditProductDetail(notification:Notification){
        NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
        self.hideLoadingView()
        isInfoEditting = false
        infoEditButton.removeTarget(self, action: #selector(editInformation), for: .touchUpInside)
        infoEditButton.addTarget(self, action: #selector(didClickEditInformation), for: .touchUpInside)
        self.mainTableView .reloadData()
    }
    //MARK: -UIPickerViewDelegate & UIPickerViewDataSource
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return STLocalizedString(inputString: "In Stock")
        case 1:
            return STLocalizedString(inputString: "Out of Stock")
        default:
            return STLocalizedString(inputString: "")
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            stockTextField.text = STLocalizedString(inputString: "In Stock")
            break
        case 1:
            stockTextField.text = STLocalizedString(inputString: "Out of Stock")
            break
        default:
            break
        }
    }
}

class STProductDescriptionViewController: SimiViewController {
    private var isShowingKeyboard:Bool = false
    public var content: String = ""
    public var isAbleEditting: Bool = false
    public var isShortDescription = false
    public var delegate: STProductShortDescriptionDelegate! = nil
    var mainTextView: SimiTextView = SimiTextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(noti:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(noti:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        createBackButton()
        if(isAbleEditting){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: STLocalizedString(inputString: "Save"), style: UIBarButtonItemStyle.done, target: self, action: #selector(doneEditting))
        }
        mainTextView.frame = CGRect.init(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
        mainTextView.font = THEME_FONT
        mainTextView.text = self.content
        mainTextView.isEditable = isAbleEditting
        if isAbleEditting{
            mainTextView.becomeFirstResponder()
        }
        self.view .addSubview(mainTextView)
    }
    func doneEditting(){
        self.navigationController!.popViewController(animated: true)
        if(isShortDescription){
            self.delegate .editProductShortDescription(content: mainTextView.text)
        }else{
            self.delegate.editProductDescription(content: mainTextView.text)
        }
    }
    func keyboardDidShow(noti:Notification){
        if !isShowingKeyboard {
            let value = noti.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject
            let rawFrame = value.cgRectValue!
            var textViewFrame = mainTextView.frame
            textViewFrame.size.height -= rawFrame.size.height
            mainTextView.frame = textViewFrame
            isShowingKeyboard = true
        }
    }
    func keyboardDidHide(noti:Notification){
        if isShowingKeyboard{
            let value = noti.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject
            let rawFrame = value.cgRectValue!
            var textViewFrame = mainTextView.frame
            textViewFrame.size.height += rawFrame.size.height
            mainTextView.frame = textViewFrame
            isShowingKeyboard = false
        }
    }
}
