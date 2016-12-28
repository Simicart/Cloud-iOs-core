//
//  STAbandonedCartDetailViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/24/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STAbandonedCartDetailViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource {

    let CART_SUMMARY_INFO_ROW = "cart_summary_info_row"
    let CART_ITEM_INFO_ROW = "cart_item_info_row"
    
    var abandonedCartModel:AbandonedCartModel!
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
        self.title = STLocalizedString(inputString: "Cart Details").uppercased()
        getAbandonedCartDetail()
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
    
    //MARK: - Get Abandoned Cart Detail
    func getAbandonedCartDetail() {
        self.showLoadingView()
        abandonedCartModel.getAbandonedCartDetailWithId(id: (abandonedCartModel.data["entity_id"] as! String), params: [:])
        NotificationCenter.default.addObserver(self, selector: #selector(didGetAbandonedCartDetail(notification:)), name: NSNotification.Name(rawValue: "DidGetAbandonedCartDetail"), object: nil)
    }
    
    //Get Abandoned Cart Detail handler
    func didGetAbandonedCartDetail(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetAbandonedCartDetail"), object: nil)
        if abandonedCartModel.isSucess == false {
            let alert = UIAlertController(title: "", message: abandonedCartModel.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
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
        summarySection.data["title"] = STLocalizedString(inputString: "Cart Summary").uppercased()
        let customerSummaryRow:SimiRow = SimiRow(withIdentifier: CART_SUMMARY_INFO_ROW, andHeight: 150)
        summarySection.childRows.append(customerSummaryRow)
        mainTableViewCells.append(summarySection)
        
        if (abandonedCartModel.data["products"] != nil) &&  !(abandonedCartModel.data["products"] is NSNull) {
            let itemArray = abandonedCartModel.data["products"] as! Array<Dictionary<String, Any>>
            if (itemArray.count > 0) {
                let itemsSection = SimiSection()
                itemsSection.data["title"] = STLocalizedString(inputString: "Cart Items").uppercased()
                var itemCount = 0
                for item in itemArray {
                    itemCount += 1
                    let cartItemRow:SimiRow = SimiRow(withIdentifier: (CART_ITEM_INFO_ROW + String(itemCount)), andHeight: 150)
                    cartItemRow.data = item
                    itemsSection.childRows.append(cartItemRow)
                }
                mainTableViewCells.append(itemsSection)
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
            if row.identifier == CART_SUMMARY_INFO_ROW {
                cellToReturn = createSummaryRow(row: row, identifier: identifier)
            }
            else if row.identifier.range(of:CART_ITEM_INFO_ROW) != nil {
                cellToReturn = createCartItemRow(row: row, reuseIdentifier: identifier)
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
        if row.identifier.range(of:CART_ITEM_INFO_ROW) != nil {
            let newProductDetailVC = STProductDetailViewController()
            newProductDetailVC.productModel = ProductModel()
            newProductDetailVC.productModel.data["entity_id"] = row.data["product_id"]
            self.navigationController?.pushViewController(newProductDetailVC, animated: true)
        }
    }
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    //MARK: - Row creating functions
    func createSummaryRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var heightCell = 10
        
        if !(abandonedCartModel.data["customer_email"] is NSNull) && (abandonedCartModel.data["customer_email"] != nil) {
            cellToReturn.addCopiableValueLabel(withTitle: STLocalizedString(inputString: "Customer Email"), andValue: (abandonedCartModel.data["customer_email"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if !(abandonedCartModel.data["remote_ip"] is NSNull) && (abandonedCartModel.data["remote_ip"] != nil) {
            cellToReturn.addCopiableValueLabel(withTitle: STLocalizedString(inputString: "Customer IP"), andValue: (abandonedCartModel.data["remote_ip"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        var grandTotalText = SimiGlobalVar.getPrice(currency: (abandonedCartModel.data["base_currency_code"] as? String)!, value: (abandonedCartModel.data["base_grand_total"] as? String)!)
        if (abandonedCartModel.data["base_grand_total"] as! String !=  abandonedCartModel.data["grand_total"] as! String) {
            grandTotalText += " [" + SimiGlobalVar.getPrice(currency: (abandonedCartModel.data["quote_currency_code"] as? String)!, value: (abandonedCartModel.data["grand_total"] as? String)!) + "]"
        }
        cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Grandtotal"), andValue: grandTotalText, atHeight: heightCell)
        heightCell += 22
        
        var subTotalText = SimiGlobalVar.getPrice(currency: (abandonedCartModel.data["base_currency_code"] as? String)!, value: (abandonedCartModel.data["base_subtotal"] as? String)!)
        if (abandonedCartModel.data["base_subtotal"] as! String !=  abandonedCartModel.data["subtotal"] as! String) {
            subTotalText += " [" + SimiGlobalVar.getPrice(currency: (abandonedCartModel.data["quote_currency_code"] as? String)!, value: (abandonedCartModel.data["subtotal"] as? String)!) + "]"
        }
        cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Subtotal"), andValue: grandTotalText, atHeight: heightCell)
        heightCell += 22
        
        if !(abandonedCartModel.data["created_at"] is NSNull) && (abandonedCartModel.data["created_at"] != nil) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Created at"), andValue: (abandonedCartModel.data["created_at"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        
        if !(abandonedCartModel.data["updated_at"] is NSNull) && (abandonedCartModel.data["updated_at"] != nil) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Updated at"), andValue: (abandonedCartModel.data["updated_at"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        heightCell += 8
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    
    func createCartItemRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        let itemData = row.data
        
        let productImage = SimiImageView(frame: CGRect(x: 15, y: 10, width: 80, height: 80))
        productImage.layer.masksToBounds = true
        productImage.contentMode = UIViewContentMode.scaleAspectFill
        productImage.layer.borderColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#EFEFEF").cgColor
        productImage.layer.borderWidth = 0.5
        if (itemData["image"] == nil) || !(itemData["image  "] is NSNull) {
            let urlAvatar = URL(string: (itemData["image"] as! String))
            productImage.sd_setImage(with: urlAvatar, placeholderImage: UIImage(named: "default_avt"))
        }
        else {
            productImage.image = UIImage(named: "default_avt")
        }
        cellToReturn.addSubview(productImage)
        
        var heightCell = 10
        
        let productNameLabel = SimiLabel(frame: CGRect(x: 105, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 120), height: 16))
        productNameLabel.textColor = UIColor.darkGray
        productNameLabel.font = UIFont.boldSystemFont(ofSize: 13)
        productNameLabel.text = itemData["name"] as? String
        cellToReturn.addSubview(productNameLabel)
        
        heightCell += 20
        
        let productSKULabel = SimiLabel(frame: CGRect(x: 105, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 120), height: 16))
        productSKULabel.textColor = UIColor.darkGray
        productSKULabel.font = UIFont.systemFont(ofSize: 12)
        productSKULabel.text = STLocalizedString(inputString: "SKU") + ": " + (itemData["sku"] as? String)!
        cellToReturn.addSubview(productSKULabel)
        
        heightCell += 20
        
        let priceLabel = SimiLabel(frame: CGRect(x: 105, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 120), height: 16))
        priceLabel.textColor = UIColor.red
        priceLabel.font = UIFont.systemFont(ofSize: 12)
        var priceText = SimiGlobalVar.getPrice(currency: (abandonedCartModel.data["base_currency_code"] as? String)!, value: (itemData["base_price"] as? String)!)
        if (itemData["base_price"] as! String !=  itemData["price"] as! String) {
            priceText += " [" + SimiGlobalVar.getPrice(currency: (abandonedCartModel.data["order_currency_code"] as? String)!, value: (itemData["price"] as? String)!) + "]"
        }
        priceLabel.text = priceText
        cellToReturn.addSubview(priceLabel)
        
        heightCell += 20
        
        let qtyLabel = SimiLabel(frame: CGRect(x: 105, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 120), height: 16))
        qtyLabel.textColor = UIColor.darkGray
        qtyLabel.font = UIFont.systemFont(ofSize: 12)
        qtyLabel.text = STLocalizedString(inputString: "Quantity") + ": " + String(itemData["qty"] as! Int!)
        cellToReturn.addSubview(qtyLabel)
        
        heightCell += 30
        row.height = CGFloat(heightCell)
        if (SimiGlobalVar.permissionsAllowed[PRODUCT_DETAIL] == true) {
            cellToReturn.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return cellToReturn
    }

}
