//
//  STOrderListViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/14/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STOrderListViewController: StoreviewFilterViewController, UITableViewDelegate, UITableViewDataSource, STSearchViewControllerDelegate {
    
    let ROW_HEIGHT:CGFloat = 65
    
    public var customerEmail: String!
    private var orderModelCollection:OrderModelCollection!
    private var reloadedTime = 0
    private var totalOrders = 0
    private var mainTableView:SimiTableView!
    private var mainTableViewCells:Array<SimiSection> = []
    private var lastContentOffset:CGPoint?
    private var statusDict:Dictionary<String, String>! = [:]
    private var refreshControl:UIRefreshControl!
    
    private var emptyLabel:SimiLabel!
    
    private var actionView:SimiView!
    private var actionFooterView:SimiView!
    private var actionTimeFilterButton:SimiButton!
    private var actionSeparator1:UIView!
    private var actionSortFilterButton:SimiButton!
    private var actionSeparator2:UIView!
    private var actionStatusFilterButton:UIButton!
    
    private var sortFilterLabel:SimiLabel!
    private var timeFilterLabel:SimiLabel!
    private var statusFilterLabel:SimiLabel!
    
    private var statusActionSheet:UIActionSheet!
    private var currentStatus = ""
    
    private var timeRangeActionSheet:UIActionSheet!
    private var currentTimeRangeStart = ""
    private var currentTimeRangeEnd = ""
    
    private var sortingActionSheet:UIActionSheet!
    private var currentSortingAttribute = ""
    private var currentSortingDirection = ""
    
    private var searchVC:STSearchViewController!
    private var searchTerm = ""
    private var searchAttribute = ""
    private var isSearchExactlyMatch = false
    private var searchButton:SimiButton!
    
    // MARK: - init functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = STLocalizedString(inputString: "Orders").uppercased()
        if (mainTableView == nil) {
            mainTableView = SimiTableView()
            mainTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            mainTableView.frame = CGRect(x: 0, y: 40, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight - 40)
            mainTableView.delegate = self
            mainTableView.dataSource = self
            mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
            self.view.addSubview(mainTableView)
            
            refreshControl = UIRefreshControl()
            refreshControl.backgroundColor = UIColor.white
            refreshControl.tintColor = UIColor.lightGray
            refreshControl.addTarget(self, action: #selector(getOrders), for: UIControlEvents.valueChanged)
            mainTableView.addSubview(refreshControl)
        }
        
        if (customerEmail != nil && customerEmail != "") {
            searchAttribute = "customer_email"
            searchTerm = customerEmail
        }
        
        self.getOrders()
        showActionView()
        if (emptyLabel == nil) {
            emptyLabel = SimiLabel(frame: view.bounds)
            emptyLabel.text = STLocalizedString(inputString: "No Orders Found")
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.textColor = UIColor.gray
            emptyLabel.backgroundColor = UIColor.white
            emptyLabel.isHidden = true
            view.addSubview(emptyLabel)
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
        
        if customerEmail == nil || customerEmail == ""{
            addFloatView(withView: searchButton)
        }
        // Do any additional setup after loading the view.
        
    }
    
    override func updateViews() {
        super.updateViews()
        updateActionView()
        
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 40, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight - 40)
            mainTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainTableView.frame = CGRect(x: 0, y: 40, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight - 40)
    }
    
    // MARK: - Get Orders
    
    public func getOrders() {
        self.showLoadingView()
        if (orderModelCollection == nil) {
            orderModelCollection = OrderModelCollection()
        }
        if (refreshControl != nil) {
            refreshControl.endRefreshing()
        }
        var trackingParams : Dictionary<String, String> = [:]
        var paramMeters:Dictionary<String, String> = ["dir":"desc","order":"entity_id","limit":String(STUserData.sharedInstance.itemPerPage),"offset":String((currentPage-1) * STUserData.sharedInstance.itemPerPage)]
        if (currentTimeRangeStart != "") && currentTimeRangeEnd != "" {
            paramMeters["from_date"] = currentTimeRangeStart
            paramMeters["to_date"] = currentTimeRangeEnd
            trackingParams["from_date"] = currentTimeRangeStart
            trackingParams["to_date"] = currentTimeRangeEnd
        }
        if (currentStatus != "") {
            paramMeters["filter[status]"] = currentStatus
            trackingParams["filter_action"] = currentStatus
        }
        if (SimiGlobalVar.selectedStoreId != "") {
            paramMeters["filter[store_id]"] = SimiGlobalVar.selectedStoreId
        }
        if (currentSortingDirection != "") && (currentSortingAttribute != "") {
            paramMeters["order"] = currentSortingAttribute
            paramMeters["dir"] = currentSortingDirection
            trackingParams["sort_action"] = currentSortingAttribute
            trackingParams["dir"] = currentSortingDirection
        }
        
        if searchAttribute != "" && searchTerm != ""{
            let attributeToSearch = "filter[" + searchAttribute + "][like]"
            if (isSearchExactlyMatch == false) {
                paramMeters[attributeToSearch] = "%" + searchTerm + "%"
            } else {
                paramMeters[attributeToSearch] = searchTerm
            }
            trackingParams["search_action"] = searchAttribute
        }
        orderModelCollection.getOrderListWithParam(params: paramMeters)
        trackEvent("list_orders_action", params: trackingParams)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetOrderList(notification:)), name: NSNotification.Name(rawValue: "DidGetOrderList"), object: nil)
    }
    
    // Get Order List handler
    func didGetOrderList(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
        if orderModelCollection.isSucess == false {
            let alert = UIAlertController(title: "", message: orderModelCollection.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            totalOrders = orderModelCollection.total!
            maxPage = totalOrders/STUserData.sharedInstance.itemPerPage + 1
            updateStatusDict()
            setMainTableViewCells()
            updateActionView()
            mainTableView.reloadData()
            setCurrentPage(pageNumber: currentPage)
            updatePagingView()
        }
    }
    
    func updateStatusDict() {
        if (orderModelCollection.responseObject?["layers"] != nil) {
            let layerArray = (orderModelCollection.responseObject?["layers"] as! Dictionary<String, Any>)["layer_filter"] as! Array<Dictionary<String, Any>>
            for layerAttribute in layerArray {
                if (layerAttribute["attribute"] != nil) && (layerAttribute["attribute"] as! String == "status") {
                    let statusArray = layerAttribute["filter"] as! Array<Dictionary<String, String>>
                    for statusItem in statusArray {
                        statusDict[statusItem["status"]!] = statusItem["label"]
                    }
                }
            }
        }
    }
    
    
    // MARK: - Display Functions
    func setMainTableViewCells() {
        reloadedTime += 1
        mainTableViewCells = []
        let items = orderModelCollection.data
        var newSection:SimiSection = SimiSection()
        var currentDate = ""
        for item in items {
            let fullCreatedTime:String = item["created_at"] as! String
            let fullDateArray = fullCreatedTime.characters.split(separator: " ").map(String.init)
            let dateCreated:String = fullDateArray[0]
            let timeCreated: String = fullDateArray[1]
            if (dateCreated != currentDate) {
                if (currentDate != "") {
                    mainTableViewCells.append(newSection)
                }
                currentDate = dateCreated
                newSection = SimiSection()
                newSection.data["header_title"] = currentDate
            }
            let newRow:SimiRow = SimiRow(withIdentifier: (item["entity_id"] as! String) + String(reloadedTime))
            newRow.data["order_item"] = item
            newRow.data["time_created"] = timeCreated
            newSection.childRows.append(newRow)
        }
        if newSection.childRows.count != 0 {
            mainTableViewCells.append(newSection)
        }
        if (mainTableViewCells.count == 0) {
            emptyLabel.isHidden = false
        }
        else {
            emptyLabel.isHidden = true
        }
    }
    
    func showActionView() {
        if (actionView == nil) {
            actionView = SimiView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: 40))
            actionView.backgroundColor = UIColor.white
            
            actionTimeFilterButton = SimiButton(frame: CGRect(x: 0, y: 0, width: scaleValue(inputSize: 107), height: 40))
            let timeIcon = SimiImageView(image: UIImage(named: "icon_time"))
            ImageViewToColor(imageView: timeIcon, color: UIColor.gray)
            timeIcon.frame = CGRect(x: 17, y: 8, width: 25, height: 25)
            actionTimeFilterButton.addSubview(timeIcon)
            timeFilterLabel = SimiLabel(frame: CGRect(x: 42, y: 11, width: scaleValue(inputSize: 107) - 42, height: 20))
            timeFilterLabel.text = STLocalizedString(inputString: "All Time")
            timeFilterLabel.font = UIFont.systemFont(ofSize: 12)
            timeFilterLabel.textColor = UIColor.gray
            actionTimeFilterButton.addTarget(self, action: #selector(showTimeRangeActionSheet), for: UIControlEvents.touchUpInside)
            actionTimeFilterButton.addSubview(timeFilterLabel)
            
            actionSeparator1 = SimiView(frame: CGRect(x: scaleValue(inputSize: 107), y: 8, width: 1, height: 24))
            actionSeparator1.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#EEEEEE")
            
            actionSortFilterButton = SimiButton(frame: CGRect(x: scaleValue(inputSize: 107), y: 0, width: scaleValue(inputSize: 107), height: 40))
            let sortIcon = SimiImageView(image: UIImage(named: "icon_sort"))
            ImageViewToColor(imageView: sortIcon, color: UIColor.gray)
            sortIcon.frame = CGRect(x: 14, y: 8, width: 25, height: 25)
            actionSortFilterButton.addSubview(sortIcon)
            sortFilterLabel = SimiLabel(frame: CGRect(x: 40, y: 11, width: scaleValue(inputSize: 107) - 40, height: 20))
            sortFilterLabel.font = UIFont.systemFont(ofSize: 12)
            sortFilterLabel.textColor = UIColor.gray
            sortFilterLabel.text = STLocalizedString(inputString: "Sort By")
            setCurrentPage(pageNumber: 1)
            actionSortFilterButton.addSubview(sortFilterLabel)
            actionSortFilterButton.addTarget(self, action: #selector(showSortingActionSheet), for: UIControlEvents.touchUpInside)
            
            
            actionSeparator2 = SimiView(frame: CGRect(x: scaleValue(inputSize: 214), y: 8, width: 1, height: 24))
            actionSeparator2.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#EEEEEE")
            
            actionStatusFilterButton = SimiButton(frame: CGRect(x: scaleValue(inputSize: 214), y: 0, width: scaleValue(inputSize: 107), height: 40))
            let statusIcon = SimiImageView(image: UIImage(named: "icon_status_filter"))
            ImageViewToColor(imageView: statusIcon, color: UIColor.gray)
            statusIcon.frame = CGRect(x: 10, y: 8, width: 25, height: 25)
            actionStatusFilterButton.addSubview(statusIcon)
            statusFilterLabel = SimiLabel(frame: CGRect(x: 32, y: 11, width: scaleValue(inputSize: 107) - 50, height: 20))
            statusFilterLabel.text = STLocalizedString(inputString: "All Status")
            statusFilterLabel.font = UIFont.systemFont(ofSize: 12)
            statusFilterLabel.textColor = UIColor.gray
            actionStatusFilterButton.addTarget(self, action: #selector(showStatusActionSheet), for: UIControlEvents.touchUpInside)
            actionStatusFilterButton.addSubview(statusFilterLabel)
            
            actionFooterView = SimiView(frame: CGRect(x: 0, y: 39, width: SimiGlobalVar.screenWidth, height: 1))
            actionFooterView.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#EEEEEE")
            
            actionView.addSubview(actionTimeFilterButton)
            actionView.addSubview(actionSeparator1)
            actionView.addSubview(actionSortFilterButton)
            actionView.addSubview(actionSeparator2)
            actionView.addSubview(actionStatusFilterButton)
            actionView.addSubview(actionFooterView)
            
            self.view.addSubview(actionView)
        }
    }
    
    func hideActionView() {
        if (actionView != nil) {
            actionView.isHidden = true
        }
    }
    
    func updateActionView() {
        if (actionView != nil) {
            if (SimiGlobalVar.screenWidth < SimiGlobalVar.screenHeight) || (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                actionView.frame = CGRect(x: 0, y: 64, width: SimiGlobalVar.screenWidth, height: 40)
            } else {
                actionView.frame = CGRect(x: 0, y: 32, width: SimiGlobalVar.screenWidth, height: 40)
            }
            
            actionTimeFilterButton.frame = CGRect(x: 0, y: 0, width: scaleValue(inputSize: 107), height: 40)
            actionSeparator1.frame = CGRect(x: scaleValue(inputSize: 107), y: 8, width: 1, height: 24)
            actionSortFilterButton.frame = CGRect(x: scaleValue(inputSize: 107), y: 0, width: scaleValue(inputSize: 107), height: 40)
            actionSeparator2.frame = CGRect(x: scaleValue(inputSize: 214), y: 8, width: 1, height: 24)
            actionStatusFilterButton.frame = CGRect(x: scaleValue(inputSize: 214), y: 0, width: scaleValue(inputSize: 107), height: 40)
            actionFooterView.frame = CGRect(x: 0, y: 39, width: SimiGlobalVar.screenWidth, height: 1)
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
        if (SimiGlobalVar.permissionsAllowed[ORDER_DETAIL] == false) {
            return
        }
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        let rowData = row.data["order_item"] as! Dictionary<String, Any>

        let newOrderDetailVC = STOrderDetailViewController()
        newOrderDetailVC.parentOrderListVC = self
//        newOrderDetailVC.orderModel = OrderModel()
        newOrderDetailVC.orderId = rowData["entity_id"] as! String
//        newOrderDetailVC.orderModel.data = rowData
        newOrderDetailVC.statusDict = statusDict
        trackEvent("list_orders_action", params: ["action":"view_order_detail"])
        self.navigationController?.pushViewController(newOrderDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        var rowData = row.data["order_item"] as! Dictionary<String, Any>
        rowData["time_created"] = row.data["time_created"]
        
        var identifier = row.identifier
        identifier += SimiGlobalVar.layoutDirection
        
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        
        if (cellToReturn == nil) {
            cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            cellToReturn?.frame = CGRect(x: 0, y: 0, width: 280, height: 40)
            
            let idLabel = SimiLabel(frame: CGRect(x: scaleValue(inputSize: 22), y: 5, width: scaleValue(inputSize: 130), height: 18))
            idLabel.textColor = UIColor.black
            idLabel.font = UIFont.boldSystemFont(ofSize: 12)
            if !(rowData["increment_id"] is NSNull) {
                idLabel.text = "#" + (rowData["increment_id"] as! String)
            }
            cellToReturn?.addSubview(idLabel)
            
            
            let titleLabel = SimiLabel(frame: CGRect(x: scaleValue(inputSize: 170), y: 5, width: scaleValue(inputSize: 150), height: 18))
            titleLabel.textColor = UIColor.black
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            var customerFullName = ""
            if !(rowData["customer_firstname"] is NSNull) {
                customerFullName += rowData["customer_firstname"] as! String
            }
            
            if !(rowData["customer_middlename"] is NSNull) {
                customerFullName += " " + (rowData["customer_middlename"] as! String)
            }
            if !(rowData["customer_lastname"] is NSNull) {
                customerFullName += " " + (rowData["customer_firstname"] as! String)
            }
            titleLabel.text = customerFullName
            cellToReturn?.addSubview(titleLabel)
            
            let emailLabel = SimiLabel(frame: CGRect(x: scaleValue(inputSize: 22), y: 23, width: scaleValue(inputSize: 120), height: 18))
            emailLabel.font = UIFont.systemFont(ofSize: 12)
            if !(rowData["customer_email"] is NSNull) {
                emailLabel.text = rowData["customer_email"] as? String
            }
            cellToReturn?.addSubview(emailLabel)
            
            let statusLabel = SimiLabel(frame: CGRect(x: scaleValue(inputSize: 170), y: 23, width: scaleValue(inputSize: 150), height: 18))
            statusLabel.font = UIFont.systemFont(ofSize: 12)
            if (rowData["status"] is NSNull){
                rowData["status"] = STLocalizedString(inputString: "N/A")
            }
            var statusColor:UIColor
            switch rowData["status"] as! String {
            case "pending":
                statusColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#0db700")
            case "complete":
                statusColor = UIColor.blue
            case "processing":
                statusColor = UIColor.orange
            case "canceled":
                statusColor = UIColor.gray
            default:
                statusColor = UIColor.black
            }
            
            if statusDict[rowData["status"] as! String] != nil {
                let statusString = statusDict[rowData["status"] as! String]
                rowData["status"] = statusString
            }
            statusLabel.text = rowData["status"] as? String
            statusLabel.textColor = statusColor
            cellToReturn?.addSubview(statusLabel)
            
            let cellLeftColorBlock:SimiView = SimiView(frame: CGRect(x: 0, y: 0, width: 4, height: ROW_HEIGHT))
            cellLeftColorBlock.backgroundColor = statusColor
            cellToReturn?.addSubview(cellLeftColorBlock)
            
            let timeLabel = SimiLabel(frame: CGRect(x: scaleValue(inputSize: 22), y: 41, width: scaleValue(inputSize: 120), height: 18))
            timeLabel.font = UIFont.systemFont(ofSize: 12)
            timeLabel.text = rowData["time_created"] as? String
            cellToReturn?.addSubview(timeLabel)
            
            let grandTotalLabel = SimiLabel(frame: CGRect(x: scaleValue(inputSize: 170), y: 41, width: scaleValue(inputSize: 150), height: 18))
            grandTotalLabel.font = UIFont.systemFont(ofSize: 13)
            var grandTotalText = SimiGlobalVar.getPrice(currency: (rowData["base_currency_code"] as? String)!, value: (rowData["base_grand_total"] as? String)!)
            if (rowData["base_grand_total"] as! String !=  rowData["grand_total"] as! String) {
                grandTotalText += " [" + SimiGlobalVar.getPrice(currency: (rowData["order_currency_code"] as? String)!, value: (rowData["grand_total"] as? String)!) + "]"
            }
            grandTotalLabel.text = grandTotalText
            cellToReturn?.addSubview(grandTotalLabel)
            
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
    
    // MARK: - Switch Store
    override func switchStore() {
        super.switchStore()
        setCurrentPage(pageNumber: 1)
        getOrders()
    }
    
    // MARK: - Change Page 
    override func showPageActionSheet() {
        super.showPageActionSheet()
        pageActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Select Page"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
        if totalOrders <= STUserData.sharedInstance.itemPerPage {
            return
        }
        pageActionSheet.addButton(withTitle: String(1))
        for index in 1...(totalOrders/STUserData.sharedInstance.itemPerPage) {
                pageActionSheet.addButton(withTitle: String(index + 1))
        }
        pageActionSheet.delegate = self
        pageActionSheet.show(in: self.view)
    }
    
    // MARK: - Add Status Filter
    func showStatusActionSheet() {
        if (statusDict.count == 0) {
            return
        }
        statusActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Select Status To Filter"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)

        for (_,title) in statusDict {
            statusActionSheet.addButton(withTitle: title)
        }
        statusActionSheet.addButton(withTitle: STLocalizedString(inputString: "All Status"))
        statusActionSheet.delegate = self
        statusActionSheet.show(in: self.view)
    }
    
    // MARK: - Add Time Range
    func showTimeRangeActionSheet() {
        timeRangeActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Select Time Range To Filter"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
        
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "All Time")) //1
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Today")) //2
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Yesterday")) //3
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Last 7 Days")) //4
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Current month")) //5
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Last month")) //6
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Last 3 months (90 days)")) //7
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "YTD").uppercased()) //8
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "2YTD").uppercased()) //9
        
        timeRangeActionSheet.delegate = self
        timeRangeActionSheet.show(in: self.view)
    }
    
    func getTimeRangeParam(month: Int, day: Int, year: Int)->String {
        return String(year)  + "-" +  String(month) + "-" + String(day)
    }
    
    // MARK: - Add Time Range
    func showSortingActionSheet() {
        sortingActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Sort By"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
        
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "ID (Low to High)")) //1
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "ID (High to Low)")) //2
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "Increment Id (Low to High")) //3
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "Increment Id (High to Low)")) //4
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "Firstname (A to Z)")) //5
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "Firstname (Z to A)")) //6
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "Lastname (A to Z)")) //7
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "Lastname (Z to A)")) //8
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "Grandtotal (Low to High)")) //9
        sortingActionSheet.addButton(withTitle: STLocalizedString(inputString: "Grandtotal (High to Low)")) //10
        sortingActionSheet.delegate = self
        sortingActionSheet.show(in: self.view)
    }
    
    
    // MARK: - Action sheet Handler
    override func actionSheet(_ actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        super.actionSheet(actionSheet, willDismissWithButtonIndex: buttonIndex)
        if (pageActionSheet != nil)&&(actionSheet == pageActionSheet)&&(buttonIndex != 0) {
            setCurrentPage(pageNumber: buttonIndex)
            getOrders()
        } else if (statusActionSheet != nil)&&(actionSheet == statusActionSheet)&&(buttonIndex != 0) {
            var i = 0
            currentStatus = ""
            statusFilterLabel.text = STLocalizedString(inputString: "All Status")
            for (status,title) in statusDict {
                i += 1
                if (i == buttonIndex) {
                    currentStatus = status
                    statusFilterLabel.text = title
                }
            }
            setCurrentPage(pageNumber: 1)
            getOrders()
        } else if (timeRangeActionSheet != nil)&&(actionSheet == timeRangeActionSheet)&&(buttonIndex != 0) {
            var dateStart = Date()
            var dateEnd = Date()
            let calendar = NSCalendar.current
            
            var selectedAllTime = false
            switch buttonIndex {
            case 2: //Today
                trackEvent("list_orders_action", params: ["time_filter_action":"today"])
                break
            case 3: //Yesterday
                dateStart = calendar.date(byAdding: .day, value: -1, to: dateStart)!
                dateEnd = calendar.date(byAdding: .day, value: -1, to: dateEnd)!
                trackEvent("list_orders_action", params: ["time_filter_action":"yesterday"])
                break
            case 4: //Last 7 days
                dateStart = calendar.date(byAdding: .day, value: -6, to: dateStart)!
                trackEvent("list_orders_action", params: ["time_filter_action":"7_days"])
                break
            case 5: //Current month
                let daysPassedCurrentMonth = calendar.dateComponents([.day], from: dateStart as Date).day! - 1
                dateStart = calendar.date(byAdding: .day, value: -daysPassedCurrentMonth, to: dateStart)!
                trackEvent("list_orders_action", params: ["time_filter_action":"current_month"])
                break
            case 6: //Last month
                let daysPassedCurrentMonth = calendar.dateComponents([.day], from: dateStart as Date).day!
                dateEnd = calendar.date(byAdding: .day, value: -daysPassedCurrentMonth, to: dateStart)!
                var lastMontComponent = calendar.dateComponents([.day, .month, .year], from: dateEnd as Date)
                lastMontComponent.day = 1
                dateStart = calendar.date(from: lastMontComponent)!
                trackEvent("list_orders_action", params: ["time_filter_action":"last_month"])
                break
            case 7: //Last 3 months (90 days)
                dateStart = calendar.date(byAdding: .day, value: -90, to: dateStart)!
                trackEvent("list_orders_action", params: ["time_filter_action":"3_months"])
                break
            case 8: //YTD
                var yearComponent = calendar.dateComponents([.day, .month, .year], from: dateStart as Date)
                yearComponent.day = 1
                yearComponent.month = 1
                dateStart = calendar.date(from: yearComponent)!
                trackEvent("list_orders_action", params: ["time_filter_action":"this_year"])
                break
            case 9: //2YTD
                var yearComponent = calendar.dateComponents([.day, .month, .year], from: dateStart as Date)
                yearComponent.day = 1
                yearComponent.month = 1
                yearComponent.year! -= 1
                dateStart = calendar.date(from: yearComponent)!
                trackEvent("list_orders_action", params: ["time_filter_action":"2_years_to_day"])
                break
            default:
                selectedAllTime = true
                trackEvent("list_orders_action", params: ["time_filter_action":"all_time"])
                break
            }
            timeFilterLabel.text = timeRangeActionSheet.buttonTitle(at: buttonIndex)
            if selectedAllTime {
                currentTimeRangeStart = ""
                currentTimeRangeEnd = ""
            }
            else {
                let componentsStart = calendar.dateComponents([.day, .month, .year], from: dateStart as Date)
                let yearStart =  componentsStart.year
                let monthStart = componentsStart.month
                let dayStart = componentsStart.day
                
                
                let componentsEnd = calendar.dateComponents([.day, .month, .year], from: dateEnd as Date)
                let yearEnd = componentsEnd.year
                let monthEnd = componentsEnd.month
                let dayEnd = componentsEnd.day
                
                currentTimeRangeStart = getTimeRangeParam(month: monthStart!, day: dayStart!, year: yearStart!)
                currentTimeRangeEnd = getTimeRangeParam(month: monthEnd!, day: dayEnd!, year: yearEnd!)
            }
            setCurrentPage(pageNumber: 1)
            getOrders()
        } else if (sortingActionSheet != nil)&&(actionSheet == sortingActionSheet)&&(buttonIndex != 0) {
            switch buttonIndex {
            case 1:
                currentSortingAttribute = "entity_id"
                currentSortingDirection = "asc"
                sortFilterLabel.text = "ID (ASC)"
                break
            case 2:
                currentSortingAttribute = "entity_id"
                currentSortingDirection = "desc"
                sortFilterLabel.text = "ID (DESC)"
                break
            case 3:
                currentSortingAttribute = "increment_id"
                currentSortingDirection = "asc"
                sortFilterLabel.text = "Increment Id (ASC)"
                break
            case 4:
                currentSortingAttribute = "increment_id"
                currentSortingDirection = "desc"
                sortFilterLabel.text = "Increment Id (DESC)"
                break
            case 5:
                currentSortingAttribute = "customer_firstname"
                currentSortingDirection = "asc"
                sortFilterLabel.text = "Firstname (ASC)"
                break
            case 6:
                currentSortingAttribute = "customer_firstname"
                currentSortingDirection = "desc"
                sortFilterLabel.text = "Firstname (DESC)"
                break
            case 7:
                currentSortingAttribute = "customer_lastname"
                currentSortingDirection = "asc"
                sortFilterLabel.text = "Lastname (ASC)"
                break
            case 8:
                currentSortingAttribute = "customer_lastname"
                currentSortingDirection = "desc"
                sortFilterLabel.text = "Lastname (DESC)"
                break
            case 9:
                currentSortingAttribute = "base_grand_total"
                currentSortingDirection = "asc"
                sortFilterLabel.text = "Grantotal (ASC)"
                break
            case 10:
                currentSortingAttribute = "base_grand_total"
                currentSortingDirection = "desc"
                sortFilterLabel.text = "Grantotal (DESC)"
                break
            default:
                break
            }
            setCurrentPage(pageNumber: 1)
            getOrders()
        }
    }
    
    // MARK: - Search
    func floatButtonTapped() {
        if (searchVC == nil) {
            searchVC = STSearchViewController()
        }
        
        searchVC.attributeList = ["entity_id":"Order ID","customer_email":"Customer Email","increment_id":"Increment Id"]
        if customerEmail != nil && customerEmail != ""{
            searchVC.attributeList = ["entity_id":"Order ID","increment_id":"Increment Id"]
        }
        
        searchVC.delegate = self
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func searchButtonTappedWith(attribute: String, andValue: String) {
        self.navigationController!.popViewController(animated: true)
        searchTerm = andValue
        searchAttribute = attribute
        if customerEmail != nil && customerEmail != ""{
            if attribute == "" && andValue == ""{
                searchAttribute = "customer_email"
                searchTerm = customerEmail
            }
        }
        orderModelCollection = nil
        currentPage = 1
        getOrders()
    }
    
    // MARK: - Page Navigation
    override func openNextPage() {
        super.openNextPage()
        trackEvent("list_orders_action", params: ["action":"next_page"])
        getOrders()
    }
    override func openPreviousPage() {
        super.openPreviousPage()
        trackEvent("list_orders_action", params: ["action":"next_page"])
        getOrders()
    }

}
