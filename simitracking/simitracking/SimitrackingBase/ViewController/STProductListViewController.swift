//
//  STProductListViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/19/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STProductListViewController: StoreviewFilterViewController, UITableViewDelegate, UITableViewDataSource, STSearchViewControllerDelegate {
    
    let ITEMS_PER_PAGE = STUserData.sharedInstance.itemPerPage
    
    private var emptyLabel: UILabel!
    
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<SimiSection> = []
    var lastContentOffset:CGPoint?
    var productModelCollection:ProductModelCollection!
    var totalProducts = 0
    var refreshControl:UIRefreshControl!
    var searchVC:STSearchViewController!
    var searchTerm = ""
    var searchAttribute = ""
    var searchButton:SimiButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = STLocalizedString(inputString: "Products").uppercased()
        if (mainTableView == nil) {
            mainTableView = SimiTableView()
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.delegate = self
            mainTableView.dataSource = self
            mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
            self.view.addSubview(mainTableView)
            
            refreshControl = UIRefreshControl()
            refreshControl.backgroundColor = UIColor.white
            refreshControl.tintColor = UIColor.lightGray
            refreshControl.addTarget(self, action: #selector(getProducts), for: UIControlEvents.valueChanged)
            mainTableView.addSubview(refreshControl)
        }
        
        addPagingView()
        
        
        let searchImageView = SimiImageView()
        searchImageView.image = UIImage(named: "ic_search")
        ImageViewToColor(imageView: searchImageView, color: UIColor.gray)
        searchButton = SimiButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        searchButton.addTarget(self, action: #selector(floatButtonTapped), for: UIControlEvents.touchUpInside)
        searchButton.layer.cornerRadius = 25
        searchButton.layer.masksToBounds = true
        searchButton.backgroundColor = UIColor.white
        
        searchImageView.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        searchButton.addSubview(searchImageView)
        
        addFloatView(withView: searchButton)
        getProducts()
        
        if (emptyLabel == nil) {
            emptyLabel = SimiLabel(frame: CGRect(x: 0, y: 150, width: SimiGlobalVar.screenWidth, height: 30))
            emptyLabel.text = STLocalizedString(inputString: "No Products Found")
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.textColor = UIColor.gray
            emptyLabel.isHidden = true
            self.view.addSubview(emptyLabel)
        }
    }
    
    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.reloadData()
        }
    }
    
    func getProducts() {
        if (refreshControl != nil) {
            refreshControl.endRefreshing()
        }
        
        if (productModelCollection == nil) {
            productModelCollection = ProductModelCollection()
        }
        self.showLoadingView()
        var paramMeters:Dictionary<String, String> =  ["dir":"desc","order":"entity_id","limit":String(ITEMS_PER_PAGE),"offset":String((currentPage-1) * ITEMS_PER_PAGE)]
        
        if (searchAttribute != "") && (searchTerm != "") {
            let attributeToSearch = "filter[" + searchAttribute + "][like]"
            paramMeters[attributeToSearch] = "%" + searchTerm + "%"
            trackEvent("list_products_action", params: ["search_action":searchAttribute])
        }
        
        if (SimiGlobalVar.selectedStoreId != "") {
            paramMeters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        else {
            paramMeters["store_id"] = "0"
        }
        
        productModelCollection.getProductListWithParam(params: paramMeters)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetProductList(notification:)), name: NSNotification.Name(rawValue: "DidGetProductList"), object: nil)
    }
    
    // Get Product List handler
    func didGetProductList(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetProductList"), object: nil)
        
        if productModelCollection.isSucess == false {
            let alert = UIAlertController(title: "", message: productModelCollection.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if productModelCollection.total == 0{
                emptyLabel.isHidden = true
            }else{
                emptyLabel.isHidden = false
                totalProducts = productModelCollection.total!
                maxPage = totalProducts/ITEMS_PER_PAGE + 1
                setMainTableViewCells()
                mainTableView.reloadData()
                setCurrentPage(pageNumber: currentPage)
                updatePagingView()
            }
        }
    }
    
    // Display Functions
    func setMainTableViewCells() {
        mainTableViewCells = []
        let items = productModelCollection.data
        let newSection:SimiSection = SimiSection()
        for item in items {
            let newRow:SimiRow = SimiRow(withIdentifier: (item["entity_id"] as! String))
            newRow.data = item
            newRow.height = 120
            newSection.childRows.append(newRow)
        }
        if newSection.childRows.count != 0 {
            mainTableViewCells.append(newSection)
        }
    }
    
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = mainTableViewCells[indexPath.section]
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
        if (mainTableViewCells.count == 0) {
            return 0
        }
        let mainSection =  mainTableViewCells[section]
        return mainSection.childRows.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if (SimiGlobalVar.permissionsAllowed[PRODUCT_DETAIL] == false) {
            return
         }
        
         let section = mainTableViewCells[indexPath.section]
         let row = section.childRows[indexPath.row]
         let rowData = row.data
         
         let newProductDetailVC = STProductDetailViewController()
         newProductDetailVC.productModel = ProductModel()
         newProductDetailVC.productModel.data = rowData
        trackEvent("list_products_action", params: ["action":"view_product_detail"])
         self.navigationController?.pushViewController(newProductDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        
        var identifier = row.identifier
        if (rotatedOnce == true) {
            identifier = "_noreuse"
        }
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        if (cellToReturn == nil) {
            cellToReturn = createProductRow(row: row, reuseIdentifier: row.identifier)
        }
        return cellToReturn!
    }
    
    // for paging show
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainTableView {
            let currentOffset = scrollView.contentOffset;
            if (currentOffset.y > 0) && (currentOffset.y + mainTableView.frame.size.height) < mainTableView.contentSize.height{
                if (self.lastContentOffset != nil) {
                    if (currentOffset.y > (self.lastContentOffset?.y)!) {
                        showPageNavi()
                    }
                    else {
                        hidePageNavi()
                    }
                }
            }
            self.lastContentOffset = currentOffset;
        }
    }
    
    // MARK: - Search
    func floatButtonTapped() {
        if (searchVC == nil) {
            searchVC = STSearchViewController()
        }
        searchVC.attributeList = ["entity_id":"Product ID","sku":"SKU","name":"Name","description":"Description","short_description":"Short Description"]
        searchVC.delegate = self
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func searchButtonTappedWith(attribute: String, andValue: String) {
        self.navigationController!.popViewController(animated: true)
        searchTerm = andValue
        searchAttribute = attribute
        productModelCollection = nil
        currentPage = 1
        getProducts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - Change Page
    override func showPageActionSheet() {
        super.showPageActionSheet()
        pageActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Select Page"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
        if totalProducts <= ITEMS_PER_PAGE {
            return
        }
        pageActionSheet.addButton(withTitle: String(1))
        for index in 1...(totalProducts/ITEMS_PER_PAGE) {
            pageActionSheet.addButton(withTitle: String(index + 1))
        }
        pageActionSheet.delegate = self
        pageActionSheet.show(in: self.view)
    }
    
    override func openNextPage() {
        super.openNextPage()
        trackEvent("list_products_action", params: ["action":"next_page"])
        getProducts()
    }
    override func openPreviousPage() {
        super.openPreviousPage()
        trackEvent("list_products_action", params: ["action":"previous_page"])
        getProducts()
    }
    
    // MARK: -Create Row
    func createProductRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        let itemData = row.data
        
        let productImage = SimiImageView(frame: CGRect(x: 15, y: 10, width: 103, height: 103))
        productImage.layer.masksToBounds = true
        productImage.contentMode = UIViewContentMode.scaleAspectFill
        productImage.layer.borderColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#EFEFEF").cgColor
        productImage.layer.borderWidth = 0.5
        if (itemData["images"] != nil) && !(itemData["images"] is NSNull) {
            let imageProduct = itemData["images"] as! Array<Dictionary<String, Any>>
            if (imageProduct.count > 0) {
                let firstImage = imageProduct[0]["url"] as! String
                let urlImageProduct = URL(string: firstImage)
                productImage.sd_setImage(with: urlImageProduct, placeholderImage: UIImage(named: "default_avt"))
            }
        }
        else {
            productImage.image = UIImage(named: "default_avt")
        }
        cellToReturn.addSubview(productImage)
        
        var heightCell = 10
        
        
        if !(itemData["name"] is NSNull) && (itemData["name"] != nil) {
            let productNameLabel = UITextField(frame: CGRect(x: 130, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 160), height: 16))
            productNameLabel.textColor = UIColor.blue
            productNameLabel.font = UIFont.boldSystemFont(ofSize: 13)
            productNameLabel.text = itemData["name"] as? String
            productNameLabel.delegate = cellToReturn
            cellToReturn.addSubview(productNameLabel)
            
            heightCell += 18
        }
        
        
        if !(itemData["entity_id"] is NSNull) && (itemData["entity_id"] != nil) {
            let productIdLabel = SimiLabel(frame: CGRect(x: 130, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 140), height: 16))
            productIdLabel.textColor = UIColor.darkGray
            productIdLabel.font = UIFont.systemFont(ofSize: 12)
            productIdLabel.text = STLocalizedString(inputString: "ID") + ": " + (itemData["entity_id"] as? String)!
            cellToReturn.addSubview(productIdLabel)
            heightCell += 18
        }
        
        if !(itemData["sku"] is NSNull) && (itemData["sku"] != nil) {
            let productSKULabel = SimiLabel(frame: CGRect(x: 130, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 140), height: 16))
            productSKULabel.textColor = UIColor.darkGray
            productSKULabel.font = UIFont.systemFont(ofSize: 12)
            productSKULabel.text = STLocalizedString(inputString: "SKU") + ": " + (itemData["sku"] as? String)!
            cellToReturn.addSubview(productSKULabel)
            
            heightCell += 18
        }
        
        
        if !(itemData["price"] is NSNull) && (itemData["price"] != nil) {
            let priceLabel = SimiLabel(frame: CGRect(x: 130, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 140), height: 16))
            priceLabel.textColor = UIColor.darkGray
            priceLabel.font = UIFont.systemFont(ofSize: 12)
            priceLabel.text = SimiGlobalVar.getPrice(currency: SimiGlobalVar.baseCurrency, value: (itemData["price"] as? String)!)
            cellToReturn.addSubview(priceLabel)
            heightCell += 18
        }
        
        
        if !(itemData["type_id"] is NSNull) && (itemData["type_id"] != nil) {
            let typeLabel = SimiLabel(frame: CGRect(x: 130, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 140), height: 16))
            typeLabel.textColor = UIColor.darkGray
            typeLabel.font = UIFont.systemFont(ofSize: 12)
            typeLabel.text = STLocalizedString(inputString: "Type") + ": " + (itemData["type_id"] as! String)
            cellToReturn.addSubview(typeLabel)
            
            heightCell += 18
        }
        
        
        if !(itemData["visibility"] is NSNull) && (itemData["visibility"] != nil) {
            let visibilityLabel = SimiLabel(frame: CGRect(x: 130, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 140), height: 16))
            visibilityLabel.textColor = UIColor.darkGray
            visibilityLabel.font = UIFont.systemFont(ofSize: 12)
            var visibilityString = itemData["visibility"] as! String
            let visibilityGlobal = SimiGlobalVar.productVisibility[itemData["visibility"] as! String]
            if visibilityGlobal != nil {
                visibilityString = visibilityGlobal!
            }
            visibilityLabel.text = STLocalizedString(inputString: "Visibility") + ": " + visibilityString
            cellToReturn.addSubview(visibilityLabel)
            
            heightCell += 18
        }
        
        heightCell += 8
        row.height = CGFloat(heightCell)
        if SimiGlobalVar.permissionsAllowed[PRODUCT_DETAIL] == true {
            cellToReturn.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else {
            cellToReturn.accessoryType = UITableViewCellAccessoryType.none
        }
        cellToReturn.selectionStyle = UITableViewCellSelectionStyle.none
        return cellToReturn
    }
    
    
    // MARK: - Action sheet Handler
    override func actionSheet(_ actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        super.actionSheet(actionSheet, willDismissWithButtonIndex: buttonIndex)
        if (pageActionSheet != nil)&&(actionSheet == pageActionSheet)&&(buttonIndex != 0) {
            setCurrentPage(pageNumber: buttonIndex)
            getProducts()
        }
    }
    
    // MARK: - Switch Store
    override func switchStore() {
        super.switchStore()
        setCurrentPage(pageNumber: 1)
        getProducts()
    }
}
