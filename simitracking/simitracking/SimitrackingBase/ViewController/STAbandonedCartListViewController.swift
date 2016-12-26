//
//  STAbandonedCartListViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/23/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STAbandonedCartListViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource, STSearchViewControllerDelegate, UIActionSheetDelegate {
    
    let ROW_HEIGHT:CGFloat = 80
    let ITEMS_PER_PAGE = SimiGlobalVar.itemsPerPage
    
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<SimiSection> = []
    var lastContentOffset:CGPoint?
    var abandonedCartModelCollection:AbandonedCartModelCollection!
    var refreshControl:UIRefreshControl!
    
    var searchVC:STSearchViewController!
    var searchTerm = ""
    var searchAttribute = ""
    var searchButton:SimiButton!
    
    var totalAbandonedCarts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = STLocalizedString(inputString: "Abandoned Carts").uppercased()
        if (mainTableView == nil) {
            mainTableView = SimiTableView()
            mainTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.delegate = self
            mainTableView.dataSource = self
            mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
            self.view.addSubview(mainTableView)
            
            refreshControl = UIRefreshControl()
            refreshControl.backgroundColor = UIColor.white
            refreshControl.tintColor = UIColor.lightGray
            refreshControl.addTarget(self, action: #selector(getAbandonedCarts), for: UIControlEvents.valueChanged)
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
        
        getAbandonedCarts()
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
    
    func getAbandonedCarts() {
        if (abandonedCartModelCollection == nil) {
            abandonedCartModelCollection = AbandonedCartModelCollection()
        }
        if (refreshControl != nil) {
            refreshControl.endRefreshing()
        }
        self.showLoadingView()
        var paramMeters:Dictionary<String, String> =  ["dir":"desc","order":"entity_id","limit":String(ITEMS_PER_PAGE),"offset":String((currentPage-1) * ITEMS_PER_PAGE)]
        
        if (searchAttribute != "") && (searchTerm != "") {
            let attributeToSearch = "filter[" + searchAttribute + "][like]"
            paramMeters[attributeToSearch] = "%" + searchTerm + "%"
        }
        abandonedCartModelCollection.getAbandonedCartWithParams(params: paramMeters)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetAbandonedCartList(notification:)), name: NSNotification.Name(rawValue: "DidGetAbandonedCartList"), object: nil)
    }
    
    // Get Abandoned Carts List handler
    func didGetAbandonedCartList(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetAbandonedCartList"), object: nil)
        
        if abandonedCartModelCollection.isSucess == false {
            let alert = UIAlertController(title: "", message: abandonedCartModelCollection.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            totalAbandonedCarts = abandonedCartModelCollection.total!
            maxPage = totalAbandonedCarts/ITEMS_PER_PAGE + 1
            setMainTableViewCells()
            mainTableView.reloadData()
            setCurrentPage(pageNumber: currentPage)
            updatePagingView()
        }
    }
    
    // Display Functions
    func setMainTableViewCells() {
        mainTableViewCells = []
        let items = abandonedCartModelCollection.data
        
        var newSection:SimiSection = SimiSection()
        var currentDate = ""
        for item in items {
            let fullCreatedTime:String = item["created_at"] as! String
            let fullDateArray = fullCreatedTime.characters.split(separator: " ").map(String.init)
            let dateCreated:String = fullDateArray[0]
            if (dateCreated != currentDate) {
                if (currentDate != "") {
                    mainTableViewCells.append(newSection)
                }
                currentDate = dateCreated
                newSection = SimiSection()
                newSection.data["header_title"] = currentDate
            }
            let newRow:SimiRow = SimiRow(withIdentifier: (item["entity_id"] as! String))
            newRow.data = item
            newSection.childRows.append(newRow)
        }
        if newSection.childRows.count != 0 {
            mainTableViewCells.append(newSection)
        }
    }
    
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = mainTableViewCells[section]
        
        let headerView:SimiView = SimiView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: 26))
        headerView.backgroundColor = THEME_COLOR
        
        let dateLabel = SimiLabel(frame: CGRect(x: scaleValue(inputSize: 42), y: 6, width: SimiGlobalVar.screenWidth, height: 14))
        dateLabel.font = UIFont.boldSystemFont(ofSize: 14)
        dateLabel.textColor = UIColor.white
        dateLabel.text = section.data["header_title"] as? String
        headerView.addSubview(dateLabel)
        
        let calendarIcon = SimiImageView(frame: CGRect(x: scaleValue(inputSize: 18), y: 2, width: 22, height: 22))
        calendarIcon.image = UIImage(named: "calendar_ic")
        headerView.addSubview(calendarIcon)
        
        return headerView
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
        if (SimiGlobalVar.permissionsAllowed[ABANDONED_CARTS_DETAILS] == false) {
            return
        }
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        let rowData = row.data
        
        let newAbandonedCartDetailVC = STAbandonedCartDetailViewController()
        newAbandonedCartDetailVC.abandonedCartModel = AbandonedCartModel()
        newAbandonedCartDetailVC.abandonedCartModel.data = rowData
        self.navigationController?.pushViewController(newAbandonedCartDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        var rowData = row.data
        var identifier = row.identifier
        identifier += SimiGlobalVar.layoutDirection
        
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        
        if (cellToReturn == nil) {
            cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            cellToReturn?.frame = CGRect(x: 0, y: 0, width: 280, height: 40)
            
            var rowHeight = CGFloat(10)
            let idLabel = SimiLabel(frame: CGRect(x: 22, y: rowHeight, width: 35, height: 20))
            idLabel.textColor = UIColor.lightGray
            idLabel.font = UIFont.boldSystemFont(ofSize: 11)
            idLabel.text =  (rowData["entity_id"] as! String)
            cellToReturn?.addSubview(idLabel)
            
            let grandTotalLabel = SimiLabel(frame: CGRect(x: 65, y: rowHeight, width: scaleValue(inputSize: 120), height: 20))
            grandTotalLabel.textColor = UIColor.red
            grandTotalLabel.font = UIFont.boldSystemFont(ofSize: 12)
            
            grandTotalLabel.text = SimiGlobalVar.getPrice(currency: (rowData["base_currency_code"] as! String), value: (rowData["base_grand_total"] as! String))
            cellToReturn?.addSubview(grandTotalLabel)
            
            let emailLabel = SimiLabel(frame: CGRect(x: 65 + scaleValue(inputSize: 90), y: rowHeight, width: SimiGlobalVar.screenWidth - (80 + scaleValue(inputSize: 120)), height: 20))
            if (rowData["customer_email"] is NSNull) {
                emailLabel.textColor = UIColor.gray
                rowData["customer_email"] = STLocalizedString(inputString: "Not Logged In")
            } else {
                emailLabel.textColor = UIColor.blue
            }
            emailLabel.font = UIFont.systemFont(ofSize: 12)
            emailLabel.text =  rowData["customer_email"] as? String
            cellToReturn?.addSubview(emailLabel)
            rowHeight += 20
            
            if !(rowData["items_count"] is NSNull) {
                let itemsCount = (rowData["items_count"] as? String)!
                let itemCountLabel = SimiLabel(frame: CGRect(x: 65, y: rowHeight, width: SimiGlobalVar.screenWidth - (80 + scaleValue(inputSize: 120)), height: 20))
                itemCountLabel.textColor = UIColor.gray
                itemCountLabel.font = UIFont.systemFont(ofSize: 12)
                if (itemsCount == "1") || (itemsCount == "0") {
                    itemCountLabel.text = itemsCount + " " + STLocalizedString(inputString: "item")
                } else {
                    itemCountLabel.text = itemsCount + " " + STLocalizedString(inputString: "items")
                }
                cellToReturn?.addSubview(itemCountLabel)
            }
            
            if !(rowData["remote_ip"] is NSNull) {
                let abandoned = SimiLabel(frame: CGRect(x: 65 + scaleValue(inputSize: 90), y: rowHeight, width: SimiGlobalVar.screenWidth - (80 + scaleValue(inputSize: 120)), height: 20))
                abandoned.textColor = UIColor.gray
                abandoned.font = UIFont.systemFont(ofSize: 12)
                abandoned.text =  rowData["remote_ip"] as? String
                cellToReturn?.addSubview(abandoned)
            }
            
            rowHeight += 20
            
            if !(rowData["updated_at"] is NSNull) {
                let updatedAtLabel = SimiLabel(frame: CGRect(x: 65, y: rowHeight, width: SimiGlobalVar.screenWidth - (80 + scaleValue(inputSize: 120)), height: 20))
                updatedAtLabel.textColor = UIColor.gray
                updatedAtLabel.font = UIFont.systemFont(ofSize: 12)
                updatedAtLabel.text = STLocalizedString(inputString: "Last Updated:")
                cellToReturn?.addSubview(updatedAtLabel)
                
                
                let updatedAtValueLabel = SimiLabel(frame: CGRect(x: 65 + scaleValue(inputSize: 90), y: rowHeight, width: SimiGlobalVar.screenWidth - (80 + scaleValue(inputSize: 120)), height: 20))
                updatedAtValueLabel.textColor = UIColor.gray
                updatedAtValueLabel.font = UIFont.systemFont(ofSize: 12)
                updatedAtValueLabel.text = rowData["updated_at"] as? String
                cellToReturn?.addSubview(updatedAtValueLabel)
            }
            
            if (SimiGlobalVar.permissionsAllowed[ABANDONED_CARTS_DETAILS] == true) {
                cellToReturn?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            cellToReturn?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        if (indexPath.row % 2) == 1 {
            cellToReturn?.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#F3F3F3")
        }
        else {
            cellToReturn?.backgroundColor = UIColor.white
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
        if totalAbandonedCarts <= ITEMS_PER_PAGE {
            return
        }
        pageActionSheet.addButton(withTitle: String(1))
        for index in 1...(totalAbandonedCarts/ITEMS_PER_PAGE) {
            pageActionSheet.addButton(withTitle: String(index + 1))
        }
        pageActionSheet.delegate = self
        pageActionSheet.show(in: self.view)
    }
    
    
    // MARK: - Page Navigation
    override func openNextPage() {
        super.openNextPage()
        getAbandonedCarts()
    }
    override func openPreviousPage() {
        super.openPreviousPage()
        getAbandonedCarts()
    }
    
    // MARK: - Action sheet Handler
    func actionSheet(_ actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if (pageActionSheet != nil)&&(actionSheet == pageActionSheet)&&(buttonIndex != 0) {
            setCurrentPage(pageNumber: buttonIndex)
            getAbandonedCarts()
        }
    }
    
    // MARK: - Search
    func floatButtonTapped() {
        if (searchVC == nil) {
            searchVC = STSearchViewController()
        }
        searchVC.attributeList = ["entity_id":"Cart ID","customer_email":"Customer Email"]
        searchVC.delegate = self
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func searchButtonTappedWith(attribute: String, andValue: String) {
        self.navigationController!.popViewController(animated: true)
        searchTerm = andValue
        searchAttribute = attribute
        abandonedCartModelCollection = nil
        currentPage = 1
        getAbandonedCarts()
    }

}
