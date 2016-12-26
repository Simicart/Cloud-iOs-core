//
//  STProductDetailViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/25/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STProductDetailViewController: StoreviewFilterViewController, UITableViewDelegate, UITableViewDataSource {
    
    let PRODUCT_NAME_ROW = "product_name_row"
    let PRODUCT_SUMMARY_INFO_ROW = "product_summary_info_row"
    let PRODUCT_IMAGE_ROW = "product_image_row"
    let PRODUCT_SHORT_DESCRIPTION_ROW = "product_short_descrption_row"
    let PRODUCT_SHORT_DESCRIPTION_VIEW_DETAIL_ROW = "product_short_descrption_view_detail_row"
    let PRODUCT_DESCRIPTION_ROW = "product_descrption_row"
    let PRODUCT_DESCRIPTION_VIEW_DETAIL_ROW = "product_descrption_view_detail_row"
    let PRODUCT_ATTRIBUTE_ROW = "product_attribute_row"
    
    var productModel:ProductModel!
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<Any>!
    
    var gotFullInformation = false
    
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
        self.hideKeyboardWhenTappedAround()
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
            let alert = UIAlertController(title: "", message: productModel.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
        
        let summarySection = SimiSection()
        summarySection.data["title"] = STLocalizedString(inputString: "Product Information").uppercased()
        let productNameRow:SimiRow = SimiRow(withIdentifier: PRODUCT_NAME_ROW, andHeight: 50)
        summarySection.childRows.append(productNameRow)
        let productInfoRow:SimiRow = SimiRow(withIdentifier: PRODUCT_SUMMARY_INFO_ROW, andHeight: 170)
        summarySection.childRows.append(productInfoRow)
        mainTableViewCells.append(summarySection)
        
        if (productModel.data["images"] != nil) &&  !(productModel.data["images"] is NSNull) {
            let itemArray = productModel.data["images"] as! Array<Dictionary<String, Any>>
            if (itemArray.count > 0) {
                let itemsSection = SimiSection()
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
                let shortDescription = SimiSection()
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
                let descriptionSection = SimiSection()
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
                let additionalSection = SimiSection()
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
        if (gotFullInformation != true) {
            identifier += "_placeholder"
        }
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        if (cellToReturn == nil) {
            if row.identifier == PRODUCT_NAME_ROW {
                cellToReturn = createNameRow(row: row, identifier: identifier)
            }else if row.identifier == PRODUCT_SUMMARY_INFO_ROW {
                cellToReturn = createSummaryRow(row: row, identifier: identifier)
            }
            else if row.identifier.range(of:PRODUCT_IMAGE_ROW) != nil {
                cellToReturn = createImageRow(row: row, reuseIdentifier: identifier)
            }
            else if row.identifier.range(of:PRODUCT_SHORT_DESCRIPTION_ROW) != nil {
                cellToReturn = createShortDescriptionRow(row: row, reuseIdentifier: identifier)
            }
            else if row.identifier.range(of:PRODUCT_DESCRIPTION_ROW) != nil {
                cellToReturn = createDescriptionRow(row: row, reuseIdentifier: identifier)
            }
            else if row.identifier.range(of:PRODUCT_ATTRIBUTE_ROW) != nil {
                cellToReturn = createAttributeRow(row: row, reuseIdentifier: identifier)
            }
            else if (row.identifier == PRODUCT_DESCRIPTION_VIEW_DETAIL_ROW) || (row.identifier == PRODUCT_SHORT_DESCRIPTION_VIEW_DETAIL_ROW) {
                cellToReturn = createViewDetailRow(row: row, reuseIdentifier: identifier)
            }
            else {
                cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            }
        }
        
        cellToReturn?.selectionStyle = UITableViewCellSelectionStyle.none
        return cellToReturn!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        if (row.identifier == PRODUCT_DESCRIPTION_VIEW_DETAIL_ROW) {
            let newDescriptionVC = SimiWebViewController()
            newDescriptionVC.content = productModel.data["description"] as? String
            newDescriptionVC.webTitle = STLocalizedString(inputString: "Description")
            self.navigationController?.pushViewController(newDescriptionVC, animated: true)
        } else if (row.identifier == PRODUCT_SHORT_DESCRIPTION_VIEW_DETAIL_ROW) {
            let newDescriptionVC = SimiWebViewController()
            newDescriptionVC.content = productModel.data["short_description"] as? String
            newDescriptionVC.webTitle = STLocalizedString(inputString: "Short Description")
            self.navigationController?.pushViewController(newDescriptionVC, animated: true)

        }
    }
    
    
    //MARK: - Row creating functions
    
    func createNameRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        
        if !(productModel.data["name"] is NSNull) && (productModel.data["name"] != nil) {
            let nameValueLabel = SimiLabel(frame: CGRect(x: 15, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 30), height: 41))
            nameValueLabel.textColor = UIColor.darkGray
            nameValueLabel.numberOfLines = 0
            nameValueLabel.font = UIFont.boldSystemFont(ofSize: 15)
            nameValueLabel.text = (productModel.data["name"] as? String)
            nameValueLabel.lineBreakMode = .byWordWrapping
            cellToReturn.addSubview(nameValueLabel)
            
            heightCell += 40
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
            cellToReturn.addCopiableValueLabel(withTitle: STLocalizedString(inputString: "URL"), andValue: (SimiGlobalVar.baseURL + (productModel.data["url_path"] as? String)!), atHeight: heightCell)
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
            if (stockData["is_in_stock"] as! String) == "1" {
               stockString = STLocalizedString(inputString: "Out of Stock")
            }
                
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Stock Status"), andValue:stockString, atHeight: heightCell)
            heightCell += 22
            }
        }
        
        heightCell += 8
        row.height = CGFloat(heightCell)
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
            let productImageUrl = UITextView(frame: CGRect(x: 105, y: 10, width: Int(SimiGlobalVar.screenWidth - 120), height: 80))
            productImageUrl.textColor = UIColor.lightGray
            productImageUrl.font = UIFont.systemFont(ofSize: 12)
            productImageUrl.text = itemData["url"] as? String
            cellToReturn.addSubview(productImageUrl)
        }
        else {
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
        let viewDetailLabel = SimiLabel(frame: CGRect(x: 20, y: 10, width: Int(SimiGlobalVar.screenWidth - 30), height: 20))
        viewDetailLabel.textColor = UIColor.gray
        viewDetailLabel.font = UIFont.systemFont(ofSize: 13)
        viewDetailLabel.text = STLocalizedString(inputString: "View Detail")
        cellToReturn.addSubview(viewDetailLabel)

        cellToReturn.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cellToReturn
    }
    
    // MARK: - Switch Store
    override func switchStore() {
        super.switchStore()
        getProductDetail()
        showLoadingView()
    }

}
