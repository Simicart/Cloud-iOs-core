//
//  STOrderDetailViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/17/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STOrderDetailViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    
    let CUSTOMER_INFO_ROW = "customer_info_row"
    let ORDER_OUTLINE_ROW = "order_outline_row"
    let ORDER_ITEMS_ROW = "order_items_row"
    let ORDER_SHIPPING_ADDRESS = "order_shipping_address"
    let ORDER_BILLING_ADDRESS = "order_payment_address"
    let PAYMENT_METHOD_ROW = "payment_method_row"
    let SHIPPING_METHOD_ROW = "shipping_method_row"
    let TOTAL_FEE_ROW = "total_fee_row"
    
    var orderModel:OrderModel!
    var statusDict:Dictionary<String, String>!
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<Any>!
    var reloadedTime = 0
    
    var parentOrderListVC:STOrderListViewController!
    
    var gotFullInformation = false
    
    //edit order
    var editButton:SimiButton!
    var actionArray:Array<Dictionary<String, String>>!
    var editOrderActionSheet:UIActionSheet!
    var selectedActionValue = ""
    var selectedActionKey = ""
    var orderUpdated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackButton()
        self.setMainTableViewCells()
        
        if (mainTableView == nil) {
            mainTableView = SimiTableView(frame:
                CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight) , style: UITableViewStyle.grouped)
            mainTableView.contentInset = UIEdgeInsetsMake(20, 0, 40, 0)
        }
        mainTableView.delegate = self
        mainTableView.dataSource = self
        self.view.addSubview(mainTableView)
        getOrderDetail()
        addEditButton()
        
        self.title = STLocalizedString(inputString: "Order Details").uppercased()
    }
    
    func addEditButton() {
        let editImageView = SimiImageView()
        editImageView.image = UIImage(named: "edit_ic")
        ImageViewToColor(imageView: editImageView, color: UIColor.white)
        editButton = SimiButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        editButton.addTarget(self, action: #selector(editOrderTapped), for: UIControlEvents.touchUpInside)
        editButton.layer.cornerRadius = 25
        editButton.layer.masksToBounds = true
        editButton.backgroundColor = THEME_COLOR
        
        editImageView.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        editButton.addSubview(editImageView)
        addFloatView(withView: editButton)
        floatView.isHidden = true
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
    //MARK: - Get Order Detail
    func getOrderDetail() {
        //showLoadingView()
        NotificationCenter.default.addObserver(self, selector: #selector(didGetOrderDetail(notification:)), name: NSNotification.Name(rawValue: "DidGetOrderDetail"), object: nil)
        orderModel.getOrderDetailWithId(id: (orderModel.data["entity_id"] as! String), params: [:])
    }
    
    // Get Order Detail handler
    func didGetOrderDetail(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetOrderDetail"), object: nil)
        if orderModel.isSucess == false {
            let alert = UIAlertController(title: "", message: orderModel.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.navigationController!.popViewController(animated: true)
        } else {
            gotFullInformation = true
            if (orderModel.data["action"] != nil) && !(orderModel.data["action"] is NSNull) && (orderModel.data["action"] is Array<Dictionary<String, String>>) {
                actionArray = orderModel.data["action"] as! Array<Dictionary<String, String>>
                floatView.isHidden = false
            } else {
                floatView.isHidden = true
            }
            setMainTableViewCells()
            self.mainTableView .reloadData()
        }
    }
    
    //MARK: - Set Data for TableView
    func setMainTableViewCells() {
        reloadedTime += 1
        mainTableViewCells = []
        let outlineSection = SimiSection()
        outlineSection.data["title"] = STLocalizedString(inputString: "Order Summary").uppercased()
        let orderOutlineRow:SimiRow = SimiRow(withIdentifier: (ORDER_OUTLINE_ROW + String(reloadedTime)), andHeight: 150)
        outlineSection.childRows.append(orderOutlineRow)
        mainTableViewCells.append(outlineSection)
        
        
        let customerSection = SimiSection()
        customerSection.data["title"] = STLocalizedString(inputString: "Customer").uppercased()
        let customerRow:SimiRow = SimiRow(withIdentifier: (CUSTOMER_INFO_ROW + String(reloadedTime)), andHeight: 80)
        customerSection.childRows.append(customerRow)
        mainTableViewCells.append(customerSection)
        
        if (orderModel.data["order_items"] != nil) && !(orderModel.data["order_items"] is NSNull) {
            let itemsSection = SimiSection()
            itemsSection.data["title"] = STLocalizedString(inputString: "Items").uppercased()
            let itemArray = orderModel.data["order_items"] as! Array<Dictionary<String, Any>>
            var count = 1
            for item in itemArray {
                count += 1
                let newRow:SimiRow = SimiRow(withIdentifier: (ORDER_ITEMS_ROW + String(count) + String(reloadedTime)), andHeight: 110)
                newRow.data["item_data"] = item
                itemsSection.childRows.append(newRow)
            }
            mainTableViewCells.append(itemsSection)
        }
        
        
        
        if (orderModel.data["shipping_address"] != nil) && (orderModel.data["shipping_address"] is Dictionary<String , Any>) {
            let shippingAddressSection = SimiSection()
            shippingAddressSection.data["title"] = STLocalizedString(inputString: "Shipping Address").uppercased()
            let newRow:SimiRow = SimiRow(withIdentifier: (ORDER_SHIPPING_ADDRESS + String(reloadedTime)), andHeight: 150)
            shippingAddressSection.childRows.append(newRow)
            mainTableViewCells.append(shippingAddressSection)
        }
        
        if (orderModel.data["billing_address"] != nil) && !(orderModel.data["billing_address"] is NSNull) {
            let billingAddressSection = SimiSection()
            billingAddressSection.data["title"] = STLocalizedString(inputString: "Billing Address").uppercased()
            let newRow:SimiRow = SimiRow(withIdentifier: (ORDER_BILLING_ADDRESS + String(reloadedTime)))
            billingAddressSection.childRows.append(newRow)
            mainTableViewCells.append(billingAddressSection)
        }
        
        if (orderModel.data["payment_method"] != nil) && !(orderModel.data["payment_method"] is NSNull) {
            let paymentMethodSection = SimiSection()
            paymentMethodSection.data["title"] = STLocalizedString(inputString: "Payment Method").uppercased()
            let newRow:SimiRow = SimiRow(withIdentifier: (PAYMENT_METHOD_ROW + String(reloadedTime)), andHeight: 60)
            paymentMethodSection.childRows.append(newRow)
            mainTableViewCells.append(paymentMethodSection)
        }
        
        if (orderModel.data["shipping_method"] != nil) && !(orderModel.data["shipping_method"] is NSNull) {
            let paymentMethodSection = SimiSection()
            paymentMethodSection.data["title"] = STLocalizedString(inputString: "Shipping Method").uppercased()
            let newRow:SimiRow = SimiRow(withIdentifier: (SHIPPING_METHOD_ROW + String(reloadedTime)), andHeight: 60)
            paymentMethodSection.childRows.append(newRow)
            mainTableViewCells.append(paymentMethodSection)
        }
        
        let totalFeeSection = SimiSection()
        totalFeeSection.data["title"] = STLocalizedString(inputString: "Total Fee").uppercased()
        let feeRow:SimiRow = SimiRow(withIdentifier: (TOTAL_FEE_ROW + String(reloadedTime)), andHeight: 120)
        totalFeeSection.childRows.append(feeRow)
        mainTableViewCells.append(totalFeeSection)
    }
    
    //MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
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
        
        if (orderUpdated == true) {
            cellToReturn = nil
        }
        
        if (cellToReturn == nil) {
            if row.identifier.range(of:ORDER_OUTLINE_ROW) != nil {
                cellToReturn = createOrderOutlineRow(reuseIdentifier: identifier)
            }
            else if row.identifier.range(of:CUSTOMER_INFO_ROW) != nil {
                cellToReturn = createCustomerInfoRow(reuseIdentifier: identifier)
            }
            else if row.identifier.range(of:ORDER_ITEMS_ROW) != nil {
                cellToReturn = createOrderItemRow(row: row, reuseIdentifier: identifier)
            }
            else if row.identifier.range(of:ORDER_SHIPPING_ADDRESS) != nil {
                cellToReturn = createAddressCell(data: orderModel.data["shipping_address"] as! Dictionary<String , Any>, reuseIdentifier: identifier, row: row)
            }
            else if row.identifier.range(of:ORDER_BILLING_ADDRESS) != nil {
                cellToReturn = createAddressCell(data: orderModel.data["billing_address"] as! Dictionary<String , Any>, reuseIdentifier: identifier, row: row)
            }
            else if row.identifier.range(of:PAYMENT_METHOD_ROW) != nil {
                cellToReturn = createMethodCell(reuseIdentifier: identifier, method: "payment")
            }
            else if row.identifier.range(of:SHIPPING_METHOD_ROW) != nil {
                cellToReturn = createMethodCell(reuseIdentifier: identifier, method: "shipping")
            }
            else if row.identifier.range(of:TOTAL_FEE_ROW) != nil {
                cellToReturn = createTotalFeeCell(reuseIdentifier: identifier, row: row)
            }
            else {
                cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            }
        }
        //cellToReturn?.selectionStyle = UITableViewCellSelectionStyle.none
        return cellToReturn!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        let identifier = row.identifier
        if identifier.range(of:CUSTOMER_INFO_ROW) != nil {
            if (orderModel.data["customer_id"] !=  nil) && !(orderModel.data["customer_id"] is NSNull) {
                let customerVC = STCustomerDetailViewController()
                customerVC.customerModel = CustomerModel()
                customerVC.customerModel.addData(data: ["entity_id":orderModel.data["customer_id"] as! String])
                self.navigationController?.pushViewController(customerVC, animated: true)
            }
        } else if identifier.range(of:ORDER_ITEMS_ROW) != nil {
            let itemData = row.data["item_data"] as! Dictionary<String, Any>
            if (itemData["product_id"] !=  nil) && !(itemData["product_id"] is NSNull) {
                let productVC = STProductDetailViewController()
                productVC.productModel = ProductModel()
                productVC.productModel.addData(data: ["entity_id":itemData["product_id"] as! String])
                self.navigationController?.pushViewController(productVC, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    //MARK: - Cell creating functions
    
    func createOrderOutlineRow(reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        var heightCell = 10
        
        if (orderModel.data["increment_id"] !=  nil) && !(orderModel.data["increment_id"] is NSNull) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Order Increment Id"), andValue: ("#" + (orderModel.data["increment_id"] as? String)!), atHeight: heightCell)
            heightCell += 22
        }
        
        if (orderModel.data["created_at"] !=  nil) && !(orderModel.data["created_at"] is NSNull) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Created At"), andValue: (orderModel.data["created_at"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if (orderModel.data["updated_at"] !=  nil) && !(orderModel.data["updated_at"] is NSNull) {
            cellToReturn.addCopiableValueLabel(withTitle: STLocalizedString(inputString: "Last Updated At"), andValue: (orderModel.data["updated_at"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        if (orderModel.data["grand_total"] !=  nil) && !(orderModel.data["grand_total"] is NSNull) {
            var grandTotalText = SimiGlobalVar.getPrice(currency: (orderModel.data["base_currency_code"] as? String)!, value: (orderModel.data["base_grand_total"] as? String)!)
            if (orderModel.data["base_grand_total"] as! String !=  orderModel.data["grand_total"] as! String) {
                grandTotalText += " [" + SimiGlobalVar.getPrice(currency: (orderModel.data["order_currency_code"] as? String)!, value: (orderModel.data["grand_total"] as? String)!) + "]"
            }
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Grand Total"), andValue: grandTotalText, atHeight: heightCell)
            heightCell += 22
        }
        
        if (orderModel.data["store_name"] !=  nil) && !(orderModel.data["store_name"] is NSNull) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Store View"), andValue: (orderModel.data["store_name"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if (orderModel.data["status"] !=  nil) && !(orderModel.data["status"] is NSNull) {
            cellToReturn.addCopiableValueLabel(withTitle: STLocalizedString(inputString: "Status"), andValue: (orderModel.data["status"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        return cellToReturn
    }
    
    func createCustomerInfoRow(reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        var heightCell = 10
        
        
        if (orderModel.data["customer_id"] !=  nil) && !(orderModel.data["customer_id"] is NSNull) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Customer Id"), andValue: ("#" + (orderModel.data["customer_id"] as? String)!), atHeight: heightCell)
            heightCell += 22
        }
        
        if (orderModel.data["customer_firstname"] !=  nil) && !(orderModel.data["customer_firstname"] is NSNull) {
            var customerFullName = ""
            if !(orderModel.data["customer_firstname"] is NSNull) {
                customerFullName += orderModel.data["customer_firstname"] as! String
            }
            if !(orderModel.data["customer_middlename"] is NSNull) {
                customerFullName += " " + (orderModel.data["customer_middlename"] as! String)
            }
            if !(orderModel.data["customer_lastname"] is NSNull) {
                customerFullName += " " + (orderModel.data["customer_firstname"] as! String)
            }
            
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Customer Name"), andValue: customerFullName, atHeight: heightCell)
            heightCell += 22
        }
        
        if (orderModel.data["customer_email"] !=  nil) && !(orderModel.data["customer_email"] is NSNull) {
            cellToReturn.addCopiableValueLabel(withTitle: STLocalizedString(inputString: "Customer Email"), andValue: (orderModel.data["customer_email"] as? String)!, atHeight: heightCell)
            heightCell += 22
        }
        
        if (SimiGlobalVar.permissionsAllowed[CUSTOMER_DETAIL] == true) {
            cellToReturn.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return cellToReturn
    }
    
    func createOrderItemRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        let itemData = row.data["item_data"] as! Dictionary<String, Any>
        
        let productImage = SimiImageView(frame: CGRect(x: 15, y: 10, width: 80, height: 80))
        productImage.layer.masksToBounds = true
        productImage.contentMode = UIViewContentMode.scaleAspectFill
        productImage.layer.borderColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#EFEFEF").cgColor
        productImage.layer.borderWidth = 0.5
        if (itemData["image"] == nil) || !(itemData["image"] is NSNull) {
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
        var priceText = SimiGlobalVar.getPrice(currency: (orderModel.data["base_currency_code"] as? String)!, value: (itemData["base_price"] as? String)!)
        if (itemData["base_price"] as! String !=  itemData["price"] as! String) {
            priceText += " [" + SimiGlobalVar.getPrice(currency: (orderModel.data["order_currency_code"] as? String)!, value: (itemData["price"] as? String)!) + "]"
        }
        priceLabel.text = priceText
        cellToReturn.addSubview(priceLabel)
        
        heightCell += 20
        
        let qtyLabel = SimiLabel(frame: CGRect(x: 105, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 120), height: 16))
        qtyLabel.textColor = UIColor.darkGray
        qtyLabel.font = UIFont.systemFont(ofSize: 12)
        //use this Or Not ??? itemData["is_qty_decimal"]
        qtyLabel.text = STLocalizedString(inputString: "Quantity Ordered") + ": " + (Double(itemData["qty_ordered"] as! String!)?.description)!
        cellToReturn.addSubview(qtyLabel)
        heightCell += 10
        if (itemData["option"] != nil) && !(itemData["option"] is NSNull) {
            let optionArray = itemData["option"] as! Array<Dictionary<String, Any>>
            if (optionArray.count != 0) {
                for option in optionArray {
                    heightCell += 15
                    let optionLabel = SimiLabel(frame: CGRect(x: 105, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 120), height: 15))
                    optionLabel.textColor = UIColor.gray
                    optionLabel.font = UIFont.systemFont(ofSize: 11)
                    let optionString = (option["option_title"] as! String) + " : " + (option["option_value"] as! String)
                    optionLabel.text = optionString
                    cellToReturn.addSubview(optionLabel)
                }
            }
        }
        heightCell += 30
        row.height = CGFloat(heightCell)
        if (SimiGlobalVar.permissionsAllowed[PRODUCT_DETAIL] == true) {
            cellToReturn.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return cellToReturn
    }
    
    func createAddressCell(data: Dictionary<String, Any>, reuseIdentifier:String, row: SimiRow) ->UITableViewCell {
        let cellToReturn = STAddressTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        var addressData = data
        for (index,item) in addressData {
            if (item is NSNull)
            {
                addressData[index] = ""
            }
        }
        cellToReturn.setCellWithInfo(addressData: addressData, row: row)
        return cellToReturn
    }
    
    
    
    func createMethodCell(reuseIdentifier:String, method:String) ->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        var heightCell = 10
        
        cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Method Code"), andValue: (orderModel.data[method+"_method"] as! String), atHeight: heightCell)
        
        if (orderModel.data[method+"_description"] != nil) && !(orderModel.data[method+"_description"] is NSNull)  {
            heightCell += 22
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Description"), andValue: (orderModel.data[method+"_description"] as! String), atHeight: heightCell)
        }
        return cellToReturn
    }
    
    func createTotalFeeCell(reuseIdentifier:String, row:SimiRow) ->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        var heightCell = 10
        
        if (orderModel.data["base_subtotal"] !=  nil) && !(orderModel.data["base_subtotal"] is NSNull) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Subtotal (Excl. Tax)"), andValue: SimiGlobalVar.getPrice(currency: (orderModel.data["base_currency_code"] as? String)!, value: (orderModel.data["base_subtotal"] as! String)), atHeight: heightCell)
            heightCell += 22
        }
        
        if (orderModel.data["base_subtotal_incl_tax"] !=  nil) && !(orderModel.data["base_subtotal_incl_tax"] is NSNull) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Subtotal (Incl. Tax)"), andValue: SimiGlobalVar.getPrice(currency: (orderModel.data["base_currency_code"] as? String)!, value: (orderModel.data["base_subtotal_incl_tax"] as! String)), atHeight: heightCell)
            heightCell += 22
        }

        if (orderModel.data["base_tax_amount"] !=  nil) && !(orderModel.data["base_tax_amount"] is NSNull) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Tax"), andValue: SimiGlobalVar.getPrice(currency: (orderModel.data["base_currency_code"] as? String)!, value: (orderModel.data["base_tax_amount"] as! String)), atHeight: heightCell)
            heightCell += 22
        }
        
        if (orderModel.data["base_shipping_amount"] !=  nil) && !(orderModel.data["base_shipping_amount"] is NSNull) {
            cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Shipping (Excl. Tax)"), andValue: SimiGlobalVar.getPrice(currency: (orderModel.data["base_currency_code"] as? String)!, value: (orderModel.data["base_shipping_amount"] as! String)), atHeight: heightCell)
            heightCell += 22
        }
        if (orderModel.data["base_shipping_tax_amount"] !=  nil) && !(orderModel.data["base_shipping_tax_amount"] is NSNull) {
            if (orderModel.data["base_shipping_tax_amount"] as! String) != "0.0000" {
                let shippingString:String = (orderModel.data["base_shipping_amount"] as! String)
                let taxString:String = (orderModel.data["base_shipping_tax_amount"] as! String)
                let totalValue = Double(taxString)! + Double(shippingString)!
                
                cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Shipping (Incl. Tax)"), andValue: totalValue.description, atHeight: heightCell)
                heightCell += 22
            }
        }
        if (orderModel.data["base_grand_total"] !=  nil) && !(orderModel.data["base_grand_total"] is NSNull) {
                    cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "GrandTotal"), andValue: SimiGlobalVar.getPrice(currency: (orderModel.data["base_currency_code"] as? String)!, value: (orderModel.data["base_grand_total"] as! String)), atHeight: heightCell)
                    heightCell += 22
        }
        
        heightCell += 8
        row.height = CGFloat(heightCell)
        return cellToReturn
    }
    
    //MARK: - Edit Order
    func editOrderTapped() {
        editOrderActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Update Order"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Do Nothing"), destructiveButtonTitle: nil)
        var itemCount = 0
        for _ in actionArray {
            let action = actionArray[itemCount]
            editOrderActionSheet.addButton(withTitle: (action["value"]! + " " + STLocalizedString(inputString: "Order")))
            itemCount+=1
        }
        editOrderActionSheet.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            return
        }
        let selectedIndex = buttonIndex - 1
        selectedActionValue = actionArray[selectedIndex]["value"]!
        selectedActionKey = actionArray[selectedIndex]["key"]!
        
        let alert = UIAlertController(title: "", message: (STLocalizedString(inputString: "Are you sure want to ") +  selectedActionValue + " this Order?"), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "Yes"), style: UIAlertActionStyle.default, handler: { alert -> Void in
            self.updateOrder()
        }))
        alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "No"), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.navigationController!.popViewController(animated: true)
    }
    
    func updateOrder() {
        showLoadingView()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdatedOrder(notification:)), name: NSNotification.Name(rawValue: "DidUpdateOrder"), object: nil)
        orderModel.updateOrderDetailWithId(id: (orderModel.data["entity_id"] as! String), params: ["status":selectedActionKey])
    }
    
    func didUpdatedOrder(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidUpdateOrder"), object: nil)
        if orderModel.isSucess == false {
            let alert = UIAlertController(title: "", message: orderModel.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            getOrderDetail()
            if (parentOrderListVC != nil) {
                parentOrderListVC.getOrders()
            }
            let alert = UIAlertController(title: "", message: STLocalizedString(inputString: "Order is Updated"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
