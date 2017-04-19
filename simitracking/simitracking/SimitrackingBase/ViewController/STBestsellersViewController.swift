//
//  STBestsellersViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 12/3/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit
import Mixpanel

class STBestsellersViewController: StoreviewFilterViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var mainTableView:SimiTableView!
    private var mainTableViewCells:Array<SimiSection> = []
    private var lastContentOffset:CGPoint?
    private var bestSellerModelCollection:BestsellerModelCollection!
    private var totalProducts = 0
    private var refreshControl:UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = STLocalizedString(inputString: "Best Sellers").uppercased()
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
            refreshControl.addTarget(self, action: #selector(getBestsellers), for: UIControlEvents.valueChanged)
            mainTableView.addSubview(refreshControl)
        }
        
        addPagingView()
        getBestsellers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.reloadData()
        }
    }
    
    func getBestsellers() {
        if (refreshControl != nil) {
            refreshControl.endRefreshing()
        }
        
        if (bestSellerModelCollection == nil) {
            bestSellerModelCollection = BestsellerModelCollection()
        }
        self.showLoadingView()
        var paramMeters:Dictionary<String, String> =  ["dir":"desc","order":"entity_id","limit":String(STUserData.sharedInstance.itemPerPage),"offset":String((currentPage-1) * STUserData.sharedInstance.itemPerPage)]
        
        if (SimiGlobalVar.selectedStoreId != "") {
            paramMeters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        else {
            paramMeters["store_id"] = "0"
        }
        
        bestSellerModelCollection.getBestsellersWithParams(params: paramMeters)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetProductList(notification:)), name: NSNotification.Name(rawValue: "DidGetBestSellersList"), object: nil)
    }
    
    // Get Product List handler
    func didGetProductList(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetBestSellersList"), object: nil)
        
        if bestSellerModelCollection.isSucess == false {
            let alert = UIAlertController(title: "", message: bestSellerModelCollection.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            totalProducts = bestSellerModelCollection.total!
            maxPage = totalProducts/STUserData.sharedInstance.itemPerPage + 1
            setMainTableViewCells()
            mainTableView.reloadData()
            setCurrentPage(pageNumber: currentPage)
            updatePagingView()
        }
    }
    
    // Display Functions
    func setMainTableViewCells() {
        mainTableViewCells = []
        let items = bestSellerModelCollection.data
        let newSection:SimiSection = SimiSection()
        for item in items {
            let newRow:SimiRow = SimiRow(withIdentifier: (item["entity_id"] as! String))
            newRow.data = item
            newRow.height = 90
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
        trackEvent("best_bellers_action", params: ["action":"view_product_detail"])
        self.navigationController?.pushViewController(newProductDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        
        var identifier = row.identifier
        if (rotatedOnce == true) {
            identifier = "_noReuse"
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - Change Page
    override func showPageActionSheet() {
        super.showPageActionSheet()
        pageActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Select Page"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
        if totalProducts <= STUserData.sharedInstance.itemPerPage {
            return
        }
        pageActionSheet.addButton(withTitle: String(1))
        for index in 1...(totalProducts/STUserData.sharedInstance.itemPerPage) {
            pageActionSheet.addButton(withTitle: String(index + 1))
        }
        pageActionSheet.delegate = self
        pageActionSheet.show(in: self.view)
    }
    
    
    // MARK: - Page Navigation
    override func openNextPage() {
        super.openNextPage()
        trackEvent("best_bellers_action", params: ["action":"next_page"])
        getBestsellers()
    }
    override func openPreviousPage() {
        super.openPreviousPage()
        trackEvent("best_bellers_action", params: ["action":"previous_page"])
        getBestsellers()
    }
    
    // MARK: - Create rows
    func createProductRow(row: SimiRow, reuseIdentifier: String)->UITableViewCell {
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        let itemData = row.data
        
        var heightCell = 10
        
        if !(itemData["name"] is NSNull) && (itemData["name"] != nil) {
            let productNameLabel = UITextField(frame: CGRect(x: 15, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 30), height: 16))
            productNameLabel.textColor = UIColor.blue
            productNameLabel.font = UIFont.boldSystemFont(ofSize: 13)
            productNameLabel.text = itemData["name"] as? String
            productNameLabel.delegate = cellToReturn
            cellToReturn.addSubview(productNameLabel)
            
            heightCell += 18
        }
        
        if !(itemData["entity_id"] is NSNull) && (itemData["entity_id"] != nil) {
            let productIdLabel = SimiLabel(frame: CGRect(x: 15, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 30), height: 16))
            productIdLabel.textColor = UIColor.darkGray
            productIdLabel.font = UIFont.systemFont(ofSize: 12)
            productIdLabel.text = STLocalizedString(inputString: "ID") + ": " + (itemData["entity_id"] as? String)!
            cellToReturn.addSubview(productIdLabel)
            
            heightCell += 18
        }
        
        if !(itemData["sku"] is NSNull) && (itemData["sku"] != nil) {
            let productSKULabel = SimiLabel(frame: CGRect(x: 15, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 30), height: 16))
            productSKULabel.textColor = UIColor.darkGray
            productSKULabel.font = UIFont.systemFont(ofSize: 12)
            productSKULabel.text = STLocalizedString(inputString: "SKU") + ": " + (itemData["sku"] as? String)!
            cellToReturn.addSubview(productSKULabel)
            
            heightCell += 18
        }
        
        if !(itemData["ordered_qty"] is NSNull) && (itemData["ordered_qty"] != nil) {
            let productQtyLabel = SimiLabel(frame: CGRect(x: 15, y: heightCell, width: Int(SimiGlobalVar.screenWidth - 30), height: 16))
            productQtyLabel.textColor = UIColor.darkGray
            productQtyLabel.font = UIFont.systemFont(ofSize: 12)
            let orderedQty:Double = Double(itemData["ordered_qty"] as! String)!
            productQtyLabel.text = STLocalizedString(inputString: "Ordered") + ": " + orderedQty.description
            cellToReturn.addSubview(productQtyLabel)
            
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
            getBestsellers()
        }
    }
    
    // MARK: - Switch Store
    override func switchStore() {
        super.switchStore()
        setCurrentPage(pageNumber: 1)
        getBestsellers()
    }

}
