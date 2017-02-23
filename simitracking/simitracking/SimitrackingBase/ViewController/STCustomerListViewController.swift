//
//  STCustomerListViewController
//  SimiTracking
//
//  Created by Hai Nguyen on 11/19/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STCustomerListViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource, STSearchViewControllerDelegate, UIActionSheetDelegate {

    private var emptyLabel:UILabel!
    
    let ROW_HEIGHT:CGFloat = 50
    
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<SimiSection> = []
    var lastContentOffset:CGPoint?
    var customerModelCollection:CustomerModelCollection!
    var totalCustomers = 0
    var refreshControl:UIRefreshControl!
    
    
    var searchVC:STSearchViewController!
    var searchTerm = ""
    var searchAttribute = ""
    var searchButton:SimiButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = STLocalizedString(inputString: "Customers").uppercased()
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
            refreshControl.addTarget(self, action: #selector(getCustomers), for: UIControlEvents.valueChanged)
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
        getCustomers()
        
        if (emptyLabel == nil) {
            emptyLabel = SimiLabel(frame: view.bounds)
            emptyLabel.text = STLocalizedString(inputString: "No Customers Found")
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.textColor = UIColor.gray
            emptyLabel.backgroundColor = UIColor.white
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

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
    }
    
    func getCustomers() {
        if (refreshControl != nil) {
            refreshControl.endRefreshing()
        }
        
        if (customerModelCollection == nil) {
            customerModelCollection = CustomerModelCollection()
        }
        self.showLoadingView()
        var paramMeters:Dictionary<String, String> =  ["dir":"desc","order":"entity_id","limit":String(STUserData.sharedInstance.itemPerPage),"offset":String((currentPage-1) * STUserData.sharedInstance.itemPerPage)]
        
        if (searchAttribute != "") && (searchTerm != "") {
            let attributeToSearch = "filter[" + searchAttribute + "][like]"
            paramMeters[attributeToSearch] = "%" + searchTerm + "%"
            trackEvent("list_customers_action", params: ["search_action":searchAttribute])
        }
        customerModelCollection.getCustomerListWithParam(params: paramMeters)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetCustomerList(notification:)), name: NSNotification.Name(rawValue: "DidGetCustomerList"), object: nil)
    }
    
    // Get Customer List handler
    func didGetCustomerList(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetCustomerList"), object: nil)
        
        if customerModelCollection.isSucess == false {
            let alert = UIAlertController(title: "", message: customerModelCollection.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if customerModelCollection.total == 0{
                emptyLabel.isHidden = false
            }else{
                emptyLabel.isHidden = true
                totalCustomers = customerModelCollection.total!
                maxPage = totalCustomers/STUserData.sharedInstance.itemPerPage + 1
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
        let items = customerModelCollection.data
        
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
        if (SimiGlobalVar.permissionsAllowed[CUSTOMER_DETAIL] == false) {
            return
        }
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        let rowData = row.data
        
        let newCustomerDetailVC = STCustomerDetailViewController()
        newCustomerDetailVC.customerModel = CustomerModel()
        newCustomerDetailVC.customerModel.data = rowData
        trackEvent("list_customers_action", params: ["action":"view_customer_detail"])
        self.navigationController?.pushViewController(newCustomerDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        var rowData = row.data
        
        var identifier = row.identifier
        identifier+=SimiGlobalVar.layoutDirection
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        
        if (cellToReturn == nil) {
            cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            cellToReturn?.frame = CGRect(x: 0, y: 0, width: 280, height: 40)
            
            let requiredIndexes = ["prefix","middlename","suffix","firstname","lastname","email"]
            for index in requiredIndexes {
                if (rowData[index] == nil) || (rowData[index] is NSNull) {
                    rowData[index] = ""
                }
            }
            
            let idLabel = SimiLabel(frame: CGRect(x: 15, y: 10, width: 35, height: 30))
            idLabel.textColor = UIColor.lightGray
            idLabel.numberOfLines = 2
            idLabel.font = UIFont.boldSystemFont(ofSize: 12)
            idLabel.text =  (rowData["entity_id"] as! String)
            cellToReturn?.addSubview(idLabel)
            
            let fullNameLabel = SimiLabel(frame: CGRect(x: 55, y: 10, width: scaleValue(inputSize: 120), height: 30))
            fullNameLabel.textColor = UIColor.black
            fullNameLabel.numberOfLines = 2
            fullNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
            
            var namevalueString = (rowData["firstname"] as! String) + " " + (rowData["middlename"] as! String) + " " + (rowData["lastname"] as! String) + " " + (rowData["suffix"] as! String)
            if (rowData["prefix"] as! String) != "" {
                namevalueString = (rowData["prefix"] as! String) + " " + namevalueString
            }
            fullNameLabel.text = namevalueString
            cellToReturn?.addSubview(fullNameLabel)
            
            let emailLabel = SimiLabel(frame: CGRect(x: 65 + scaleValue(inputSize: 120), y: 10, width: SimiGlobalVar.screenWidth - (80 + scaleValue(inputSize: 120)), height: 30))
            emailLabel.textColor = UIColor.blue
            emailLabel.numberOfLines = 2
            emailLabel.font = UIFont.boldSystemFont(ofSize: 12)
//            emailLabel.urlType = .emailAddress
            emailLabel.text =  rowData["email"] as? String
            cellToReturn?.addSubview(emailLabel)
            
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
    
    // MARK: - Search
    func floatButtonTapped() {
        if (searchVC == nil) {
            searchVC = STSearchViewController()
        }
        searchVC.attributeList = ["entity_id":"Customer ID","email":"Email","firstname":"First Name","lastname":"Last Name","website_id":"Website (Website Id)","group_id":"Group (Group Id)"]
        searchVC.delegate = self
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func searchButtonTappedWith(attribute: String, andValue: String) {
        self.navigationController!.popViewController(animated: true)
        searchTerm = andValue
        searchAttribute = attribute
        customerModelCollection = nil
        currentPage = 1
        getCustomers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - Change Page
    override func showPageActionSheet() {
        super.showPageActionSheet()
        pageActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Select Page"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
        if totalCustomers <= STUserData.sharedInstance.itemPerPage {
            return
        }
        pageActionSheet.addButton(withTitle: String(1))
        for index in 1...(totalCustomers/STUserData.sharedInstance.itemPerPage) {
            pageActionSheet.addButton(withTitle: String(index + 1))
        }
        pageActionSheet.delegate = self
        pageActionSheet.show(in: self.view)
    }
    

    // MARK: - Page Navigation
    override func openNextPage() {
        super.openNextPage()
        trackEvent("list_customers_action", params: ["action":"next_page"])
        getCustomers()
    }
    override func openPreviousPage() {
        super.openPreviousPage()
        trackEvent("list_customers_action", params: ["action":"previous_page"])
        getCustomers()
    }
    
    // MARK: - Action sheet Handler
    func actionSheet(_ actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if (pageActionSheet != nil)&&(actionSheet == pageActionSheet)&&(buttonIndex != 0) {
            setCurrentPage(pageNumber: buttonIndex)
            getCustomers()
        }
    }
    
}
