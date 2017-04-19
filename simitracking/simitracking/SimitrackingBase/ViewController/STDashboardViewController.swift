//
//  STDashboardViewController.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/5/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit
import Mixpanel
import Charts

class STDashboardViewController: StoreviewFilterViewController, UITableViewDelegate, UITableViewDataSource, IAxisValueFormatter, ChartViewDelegate{
    let SALES_SECTION_IDENTIFIER = "SALES_SECTION_IDENTIFIER"
    let SALES_TIME_RANGE_SELECT_ROW = "SALES_TIME_RANGE_SELECT_ROW"
    let CHART_LABEL_ROW = "CHART_LABEL_ROW"
    let SALES_CHART_ROW = "SALES_CHART_ROW"
    let TOTAL_SALES_INFO_ROW = "TOTAL_SALES_INFO_ROW"
    let LIFETIME_SALES_INFO_ROW = "LIFETIME_SALES_INFO_ROW"
    
    let LATEST_ORDERS_SECTION_IDENTIFIER = "LATEST_ORDERS_SECTION_IDENTIFIER"
    let LATEST_ORDERS_ROW = "LATEST_ORDERS_ROW"
    
    let LATEST_CUSTOMERS_SECTION_IDENTIFIER = "LATEST_CUSTOMERS_SECTION_IDENTIFIER"
    let LATEST_CUSTOMERS_ROW = "LATEST_CUSTOMERS_ROW"
    
    let BEST_SELLERS_SECTION_IDENTIFIER = "BEST_SELLERS_SECTION_IDENTIFIER"
    let BEST_SELLERS_ROW = "BEST_SELLERS_ROW"
    
    
    //tableviews
    private var mainTableView:SimiTableView!
    private var mainTableViewCells:Array<Any>!
    private var refreshControl:UIRefreshControl!
    
    //models
    private var saleModel:SaleModel!
    private var salePeriod = "day"
    private var orderModelCollection:OrderModelCollection!
    private var customerModelCollection:CustomerModelCollection!
    private var bestsellerModelCollection:BestsellerModelCollection!
    
    
    //time range
    private var timeFilterLabel:SimiLabel!
    private var timeRangeActionSheet:UIActionSheet!
    private var currentTimeRangeStart = ""
    private var currentTimeRangeEnd = ""
    
    
    //chart
    private var saleChartView:CombinedChartView!
    private var totalsChartData: Array<Dictionary<String, Any>>!
    private var leftAxis:YAxis!
    private var rightAxis:YAxis!
    private var amountAndCountRatio:Double = 1
    
    //views need to be changed frame when rotate the screen
    private var ordersLabel: SimiLabel!
    private var invoicesLabel:SimiLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if didChangeShowingItemOnDashboard{
            setMainTableViewCells()
            mainTableView.reloadData()
        }
        getSales()
        getOrders()
        getCustomers()
        getBestsellers()
    }
    
    func addViews() {
        self.setMainTableViewCells()
        mainTableView = SimiTableView(frame:
            CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight) , style: .plain)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.white
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(refreshDashboardInfos), for: UIControlEvents.valueChanged)
        mainTableView.addSubview(refreshControl)
        
        self.view.addSubview(mainTableView)
        self.title = STLocalizedString(inputString: "Dashboard").uppercased()
        
        selectDefaultTimeRange()
        
    }
    
    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight);
            mainTableView.reloadData()
        }
        if (saleChartView != nil) {
            saleChartView.frame = CGRect(x: 15, y: 0, width: SimiGlobalVar.screenWidth - 30, height: 320)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Refresh stats
    func refreshMagentoStats() {
        if (refreshControl != nil) {
            refreshControl.endRefreshing()
        }
        showLoadingView()
        var paramMeters = ["period":salePeriod]
        if (SimiGlobalVar.selectedStoreId != "") {
            paramMeters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        if (currentTimeRangeStart != "") && currentTimeRangeEnd != "" {
            paramMeters["from_date"] = currentTimeRangeStart
            paramMeters["to_date"] = currentTimeRangeEnd
        }
        saleModel.refreshSaleInfo(params: paramMeters)
        trackEvent("dashboard_action", params: ["action":"chart_refresh"])
        NotificationCenter.default.addObserver(self, selector: #selector(didGetSales(notification:)), name: NSNotification.Name(rawValue: "DidGetSaleInfo"), object: nil)
    }
    
    //MARK: -Refresh all infos
    func refreshDashboardInfos(){
        showLoadingView()
        refreshMagentoStats()
        getBestsellers()
        getOrders()
        getCustomers()
    }
    
    //MARK: - Get Information
    func getSales() {
        showLoadingView()
        if (saleModel == nil) {
            saleModel = SaleModel()
        }
        var paramMeters = ["period":salePeriod]
        if (SimiGlobalVar.selectedStoreId != "") {
            paramMeters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        if (currentTimeRangeStart != "") && currentTimeRangeEnd != "" {
            paramMeters["from_date"] = currentTimeRangeStart
            paramMeters["to_date"] = currentTimeRangeEnd
        }
        
        saleModel.getSaleInfoWith(params:
            paramMeters)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetSales(notification:)), name: NSNotification.Name(rawValue: "DidGetSaleInfo"), object: nil)
    }
    
    func didGetSales(notification: NSNotification) {
        hideLoadingView()
        if (saleModel != nil &&  saleModel.data["total_chart"] != nil && saleModel.data["total_chart"] is Array<Dictionary<String,Any>>) {
            totalsChartData = saleModel.data["total_chart"] as! Array<Dictionary<String, Any>>
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetSaleInfo"), object: nil)
            setMainTableViewCells()
            mainTableView.reloadData()
        }
    }
    
    func getOrders() {
        if (orderModelCollection == nil) {
            orderModelCollection = OrderModelCollection()
        }
        var paramMeters = ["dir":"desc","order":"entity_id","limit":"5","offset":"0"]
        if (SimiGlobalVar.selectedStoreId != "") {
            paramMeters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        orderModelCollection.getOrderListWithParam(params:
            paramMeters)
        orderModelCollection.currentNotificationName = "DidGetOrderListDashboard"
        NotificationCenter.default.addObserver(self, selector: #selector(didGetOrders(notification:)), name: NSNotification.Name(rawValue: "DidGetOrderListDashboard"), object: nil)
    }
    func didGetOrders(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetOrderListDashboard"), object: nil)
        setMainTableViewCells()
        mainTableView.reloadData()
    }
    
    func getCustomers() {
        if (customerModelCollection == nil) {
            customerModelCollection = CustomerModelCollection()
        }
        customerModelCollection.getCustomerListWithParam(params:
            ["dir":"desc","order":"entity_id","limit":"5","offset":"0"])
        customerModelCollection.currentNotificationName = "DidGetCustomerListDashboard"
        NotificationCenter.default.addObserver(self, selector: #selector(didGetCustomers(notification:)), name: NSNotification.Name(rawValue: "DidGetCustomerListDashboard"), object: nil)
    }
    func didGetCustomers(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetCustomerListDashboard"), object: nil)
        setMainTableViewCells()
        mainTableView.reloadData()
    }
    
    func getBestsellers() {
        if (bestsellerModelCollection == nil) {
            bestsellerModelCollection = BestsellerModelCollection()
        }
        var paramMeters = ["limit":"5","offset":"0"]
        if (SimiGlobalVar.selectedStoreId != "") {
            paramMeters["store_id"] = SimiGlobalVar.selectedStoreId
        }
        bestsellerModelCollection.getBestsellersWithParams(params:
            paramMeters)
        bestsellerModelCollection.currentNotificationName = "DidGetBestSellersListDashboard"
        NotificationCenter.default.addObserver(self, selector: #selector(didGetBestsellers(notification:)), name: NSNotification.Name(rawValue: "DidGetBestSellersListDashboard"), object: nil)
    }
    
    func didGetBestsellers(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetBestSellersListDashboard"), object: nil)
        setMainTableViewCells()
        mainTableView.reloadData()
    }
    
    
    
    //MARK: - Set Data for TableView
    func setMainTableViewCells() {
        mainTableViewCells = []
        if (saleModel != nil) && (SimiGlobalVar.permissionsAllowed[SALE_TRACKING] == true) && (STUserData.sharedInstance.showDashboardSales == true) {
            let salesSection = SimiSection()
            salesSection.data["title"] = STLocalizedString(inputString: "Sales Reports").uppercased()
            salesSection.height = 0
            salesSection.identifier = SALES_SECTION_IDENTIFIER
            let salesTimeRangeRow:SimiRow = SimiRow(withIdentifier: SALES_TIME_RANGE_SELECT_ROW, andHeight: 40)
            salesSection.childRows.append(salesTimeRangeRow)
            let chartLabelRow:SimiRow = SimiRow(withIdentifier:CHART_LABEL_ROW, andHeight:40)
            let salesChartRow:SimiRow = SimiRow(withIdentifier: SALES_CHART_ROW, andHeight: 350)
            salesSection.childRows.append(chartLabelRow)
            salesSection.childRows.append(salesChartRow)
            if (SimiGlobalVar.permissionsAllowed[TOTAL_DETAIL] == true) {
                let totalSalesInfoRow:SimiRow = SimiRow(withIdentifier: TOTAL_SALES_INFO_ROW, andHeight: 160)
                salesSection.childRows.append(totalSalesInfoRow)
            }
            if (SimiGlobalVar.permissionsAllowed[SALE_DETAIL] == true) {
                let lifetimeSalesInfoRow:SimiRow = SimiRow(withIdentifier: LIFETIME_SALES_INFO_ROW, andHeight: 60)
                salesSection.childRows.append(lifetimeSalesInfoRow)
            }
            mainTableViewCells.append(salesSection)
        }
        
        if SimiGlobalVar.permissionsAllowed != nil && SimiGlobalVar.permissionsAllowed[PRODUCT_LIST] == true && (bestsellerModelCollection != nil) && (bestsellerModelCollection.data.count > 0) && (STUserData.sharedInstance.showDashboardBestsellers == true) {
            let bestsellerSection = SimiSection()
            bestsellerSection.data["title"] = STLocalizedString(inputString: "Best Sellers").uppercased()
            bestsellerSection.height = 30
            bestsellerSection.identifier = BEST_SELLERS_SECTION_IDENTIFIER
            var itemCount = 0
            for item in bestsellerModelCollection.data {
                itemCount += 1
                let productRow:SimiRow = SimiRow(withIdentifier: BEST_SELLERS_ROW + (item["entity_id"] as! String), andHeight: 50)
                productRow.data = item
                bestsellerSection.childRows.append(productRow)
            }
            mainTableViewCells.append(bestsellerSection)
        }
        
        
        if SimiGlobalVar.permissionsAllowed != nil && SimiGlobalVar.permissionsAllowed[ORDER_LIST] == true && (orderModelCollection != nil) && (orderModelCollection.data.count > 0) && (STUserData.sharedInstance.showDashboardLatestOrders == true)  {
            let latestOrdersSection = SimiSection()
            latestOrdersSection.data["title"] = STLocalizedString(inputString: "Latest Orders").uppercased()
            latestOrdersSection.height = 30
            latestOrdersSection.identifier = LATEST_ORDERS_SECTION_IDENTIFIER
            var itemCount = 0
            for item in orderModelCollection.data {
                itemCount += 1
                let orderRow:SimiRow = SimiRow(withIdentifier: LATEST_ORDERS_ROW+(item["entity_id"] as! String), andHeight: 50)
                orderRow.data = item
                latestOrdersSection.childRows.append(orderRow)
            }
            mainTableViewCells.append(latestOrdersSection)
        }
        
        if SimiGlobalVar.permissionsAllowed != nil  && SimiGlobalVar.permissionsAllowed[CUSTOMER_LIST] == true && (customerModelCollection != nil) && (customerModelCollection.data.count > 0) && (STUserData.sharedInstance.showDashboardLatestCustomers == true)  {
            let latestCustomersSection = SimiSection()
            latestCustomersSection.data["title"] = STLocalizedString(inputString: "Latest Customers").uppercased()
            latestCustomersSection.height = 30
            latestCustomersSection.identifier = LATEST_CUSTOMERS_SECTION_IDENTIFIER
            var itemCount = 0
            for item in customerModelCollection.data {
                itemCount += 1
                let customerRow:SimiRow = SimiRow(withIdentifier: LATEST_CUSTOMERS_ROW+(item["entity_id"] as! String), andHeight: 50)
                customerRow.data = item
                latestCustomersSection.childRows.append(customerRow)
            }
            mainTableViewCells.append(latestCustomersSection)
        }
    }
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = mainTableViewCells[indexPath.section] as! SimiSection
        let row = section.childRows[indexPath.row]
        return row.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = mainTableViewCells[section] as! SimiSection
        return section.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = mainTableViewCells[section] as! SimiSection
        if (section.identifier == LATEST_ORDERS_SECTION_IDENTIFIER) || (section.identifier == LATEST_CUSTOMERS_SECTION_IDENTIFIER) || (section.identifier == BEST_SELLERS_SECTION_IDENTIFIER) {
            let sectionView = SimiView()
            sectionView.backgroundColor = THEME_COLOR
            let titleLabel = SimiLabel(frame: CGRect(x: 15, y: 5, width: SimiGlobalVar.screenWidth - 30, height: 20))
            titleLabel.textColor = UIColor.white
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            titleLabel.text = (section.data["title"] as! String).uppercased()
            sectionView.addSubview(titleLabel)
            return sectionView
        }
        return nil
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
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        if (cellToReturn == nil) {
            if row.identifier == SALES_TIME_RANGE_SELECT_ROW {
                cellToReturn = createTimeRangeRow(row: row, identifier: "_noreuse")
            }else if row.identifier == CHART_LABEL_ROW{
                cellToReturn = createChartLabelRow(row: row, identifier: "_noreuse")
            }else if row.identifier.range(of:SALES_CHART_ROW) != nil {
                cellToReturn = createChartRow(row: row, identifier: "_noreuse")
            } else if row.identifier.range(of:TOTAL_SALES_INFO_ROW) != nil {
                cellToReturn = createTotalSalesRow(row: row, identifier: "_noreuse")
            } else if row.identifier.range(of:LIFETIME_SALES_INFO_ROW) != nil {
                cellToReturn = createLifetimeSalesRow(row: row, identifier: "_noreuse")
            } else if row.identifier.range(of:LATEST_ORDERS_ROW) != nil {
                cellToReturn = createOrderRow(row: row, identifier: "_noreuse")
            } else if row.identifier.range(of:LATEST_CUSTOMERS_ROW) != nil {
                cellToReturn = createCustomerRow(row: row, identifier: "_noreuse")
            } else if row.identifier.range(of:BEST_SELLERS_ROW) != nil {
                cellToReturn = createBestsellerRow(row: row, identifier: "_noreuse")
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
        if (SimiGlobalVar.permissionsAllowed[PRODUCT_DETAIL] == true) && (row.identifier.range(of:BEST_SELLERS_ROW) != nil) {
            let newproductVC = STProductDetailViewController()
            newproductVC.productModel = ProductModel()
            newproductVC.productModel.data = row.data
            trackEvent("dashboard_action", params: ["action":"view_best_seller_detail"])
            self.navigationController?.pushViewController(newproductVC, animated: true)
        } else if (SimiGlobalVar.permissionsAllowed[ORDER_DETAIL] == true) && (row.identifier.range(of:LATEST_ORDERS_ROW) != nil) {
            let newOrderVC = STOrderDetailViewController()
            newOrderVC.orderId = row.data["entity_id"] as! String!
            trackEvent("dashboard_action", params: ["action":"view_latest_order_detail"])
            self.navigationController?.pushViewController(newOrderVC, animated: true)
        } else if (SimiGlobalVar.permissionsAllowed[CUSTOMER_DETAIL] == true) && (row.identifier.range(of:LATEST_CUSTOMERS_ROW) != nil) {
            let newCustomerVC = STCustomerDetailViewController()
            newCustomerVC.customerModel = CustomerModel()
            newCustomerVC.customerModel.data = row.data
            trackEvent("dashboard_action", params: ["action":"view_latest_customer_detail"])
            self.navigationController?.pushViewController(newCustomerVC, animated: true)
        }
    }
    
    func createChartLabelRow(row:SimiRow, identifier:String) -> UITableViewCell {
        let cellToReturn = UITableViewCell(style: UITableViewCellStyle.default,reuseIdentifier: identifier)
        let invoicesLabel = SimiLabel(frame:CGRect(x:15,y:0,width:SimiGlobalVar.screenWidth/2 - 15, height:row.height))
        invoicesLabel.text = STLocalizedString(inputString: "Invoices ") + "(\(SimiGlobalVar.baseCurrency))"
        invoicesLabel.textAlignment = NSTextAlignment.left
        cellToReturn.addSubview(invoicesLabel)
        let ordersLabel = SimiLabel(frame:CGRect(x:SimiGlobalVar.screenWidth/2,y:0,width:SimiGlobalVar.screenWidth/2 - 15, height:row.height))
        ordersLabel.text = STLocalizedString(inputString: "Orders")
        ordersLabel.textAlignment = NSTextAlignment.right
        cellToReturn.addSubview(ordersLabel)
        invoicesLabel.font = THEME_BOLD_FONT
        ordersLabel.font = THEME_BOLD_FONT
        ordersLabel.textColor = UIColor.lightGray
        invoicesLabel.textColor = UIColor.lightGray
        return cellToReturn
    }
    
    //MARK: - Order rows
    func createOrderRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        if (row.data["increment_id"] != nil) && !(row.data["increment_id"] is NSNull) {
            let titleLabel = SimiLabel(frame: CGRect(x: 15, y: 15, width: 75, height: 20))
            titleLabel.textColor = UIColor.darkGray
            titleLabel.font = UIFont.systemFont(ofSize: 11)
            titleLabel.text = "#" + (row.data["increment_id"] as! String)
            cellToReturn.addSubview(titleLabel)
        }
        if (row.data["base_grand_total"] != nil) && !(row.data["base_grand_total"] is NSNull) {
            let totalLabel = SimiLabel(frame: CGRect(x: 90, y: 15, width: 90, height: 20))
            totalLabel.textColor = UIColor.darkGray
            totalLabel.font = UIFont.systemFont(ofSize: 12)
            totalLabel.text = SimiGlobalVar.getPrice(currency: SimiGlobalVar.baseCurrency, value: (row.data["base_grand_total"] as! String))
            totalLabel.textColor = UIColor.red
            totalLabel.textAlignment = NSTextAlignment.right
            cellToReturn.addSubview(totalLabel)
        }
        if (row.data["customer_firstname"] != nil) && !(row.data["customer_firstname"] is NSNull) && (row.data["customer_lastname"] != nil) && !(row.data["customer_lastname"] is NSNull) {
            let nameLabel = SimiLabel(frame: CGRect(x: 200, y: 8, width: SimiGlobalVar.screenWidth - 215, height: 20))
            nameLabel.textColor = UIColor.darkGray
            nameLabel.font = UIFont.systemFont(ofSize: 12)
            
            var middleName = ""
            if (row.data["customer_middlename"] == nil) && (row.data["customer_middlename"] is NSNull) {
                middleName = (row.data["customer_middlename"] as! String) + " "
            }
            
            var nameString = (row.data["customer_firstname"] as! String) + " " + middleName + (row.data["customer_lastname"] as! String)
            if (row.data["customer_prefix"] != nil) && !(row.data["customer_prefix"] is NSNull) {
                nameString = (row.data["customer_prefix"] as! String) + " " + nameString
            }
            if (row.data["customer_suffix"] != nil) && !(row.data["customer_suffix"] is NSNull) {
                nameString += " " + (row.data["customer_suffix"] as! String)
            }
            nameLabel.textAlignment = NSTextAlignment.right
            nameLabel.text = nameString
            cellToReturn.addSubview(nameLabel)
        }
        if (row.data["customer_email"] != nil) && !(row.data["customer_email"] is NSNull) {
            let emailLabel = SimiLabel(frame: CGRect(x: 200, y: 23, width: SimiGlobalVar.screenWidth - 215, height: 20))
            emailLabel.textColor = UIColor.lightGray
            emailLabel.font = UIFont.italicSystemFont(ofSize: 11)
            emailLabel.text = (row.data["customer_email"] as! String)
            emailLabel.textColor = UIColor.blue
            emailLabel.textAlignment = NSTextAlignment.right
            cellToReturn.addSubview(emailLabel)
        }
        
        let separatorView = UIView(frame: CGRect(x: 40, y: row.height-1, width: SimiGlobalVar.screenWidth - 80, height: 1))
        separatorView.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#f1f1f1")
        cellToReturn.addSubview(separatorView)
        
        return cellToReturn
    }
    
    //MARK: - Customer rows
    func createCustomerRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        if (row.data["entity_id"] != nil) && !(row.data["entity_id"] is NSNull) {
            let titleLabel = SimiLabel(frame: CGRect(x: 15, y: 15, width: 40, height: 20))
            titleLabel.textColor = UIColor.lightGray
            titleLabel.font = UIFont.systemFont(ofSize: 11)
            titleLabel.text = (row.data["entity_id"] as! String)
            cellToReturn.addSubview(titleLabel)
        }
        
        if (row.data["firstname"] != nil) && !(row.data["firstname"] is NSNull) && (row.data["lastname"] != nil) && !(row.data["lastname"] is NSNull) {
            let nameLabel = SimiLabel(frame: CGRect(x: 60, y: 15, width: 120, height: 20))
            nameLabel.textColor = UIColor.darkGray
            nameLabel.font = UIFont.systemFont(ofSize: 12)
            var middleName = ""
            if (row.data["middlename"] == nil) && (row.data["middlename"] is NSNull) {
                middleName = (row.data["middlename"] as! String) + " "
            }
            var nameString = (row.data["firstname"] as! String) + " " + middleName + (row.data["lastname"] as! String)
            if (row.data["prefix"] != nil) && !(row.data["prefix"] is NSNull) {
                nameString = (row.data["prefix"] as! String) + " " + nameString
            }
            if (row.data["suffix"] != nil) && !(row.data["suffix"] is NSNull) {
                nameString += " " + (row.data["suffix"] as! String)
            }
            nameLabel.text = nameString
            cellToReturn.addSubview(nameLabel)
        }
        
        if (row.data["email"] != nil) && !(row.data["email"] is NSNull) {
            let emailLabel = SimiLabel(frame: CGRect(x: 200, y: 15, width: SimiGlobalVar.screenWidth - 210, height: 20))
            emailLabel.textColor = THEME_COLOR
            emailLabel.font = UIFont.italicSystemFont(ofSize: 12)
            emailLabel.textAlignment = NSTextAlignment.right
            emailLabel.textColor = UIColor.blue
            emailLabel.text = (row.data["email"] as! String)
            cellToReturn.addSubview(emailLabel)
        }
        
        let separatorView = UIView(frame: CGRect(x: 40, y: row.height-1, width: SimiGlobalVar.screenWidth - 80, height: 1))
        separatorView.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#f1f1f1")
        cellToReturn.addSubview(separatorView)
        
        return cellToReturn
    }
    
    //MARK: - Bestseller rows
    func createBestsellerRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        if (row.data["entity_id"] != nil) && !(row.data["entity_id"] is NSNull) {
            let titleLabel = SimiLabel(frame: CGRect(x: 15, y: 15, width: 40, height: 20))
            titleLabel.textColor = UIColor.lightGray
            titleLabel.font = UIFont.systemFont(ofSize: 11)
            titleLabel.text = (row.data["entity_id"] as! String)
            cellToReturn.addSubview(titleLabel)
        }
        
        if (row.data["ordered_qty"] != nil) && !(row.data["ordered_qty"] is NSNull) {
            let qtyLabel = SimiLabel(frame: CGRect(x: 60, y: 15, width: 100, height: 20))
            qtyLabel.textColor = UIColor.darkGray
            qtyLabel.font = UIFont.systemFont(ofSize: 12)
            let orderedQty:Double = Double(row.data["ordered_qty"] as! String)!
            qtyLabel.text = STLocalizedString(inputString: "Ordered: ") + orderedQty.description
            cellToReturn.addSubview(qtyLabel)
        }
        
        if (row.data["name"] != nil) && !(row.data["name"] is NSNull) {
            let nameLabel = SimiLabel(frame: CGRect(x: 170, y: 6, width: SimiGlobalVar.screenWidth - 185, height: 38))
            nameLabel.textColor = UIColor.darkGray
            nameLabel.font = UIFont.systemFont(ofSize: 12)
            nameLabel.textAlignment = NSTextAlignment.right
            nameLabel.text = (row.data["name"] as! String)
            nameLabel.numberOfLines = 2
            cellToReturn.addSubview(nameLabel)
        }
        
        let separatorView = UIView(frame: CGRect(x: 40, y: row.height-1, width: SimiGlobalVar.screenWidth - 80, height: 1))
        separatorView.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#f1f1f1")
        cellToReturn.addSubview(separatorView)
        return cellToReturn
    }
    
    // MARK: - Sale Rows 
    func createTimeRangeRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        let timeFilterButton = SimiButton(frame: CGRect(x: 10, y: 5, width: scaleValue(inputSize: 160), height: 35))
        timeFilterButton.layer.borderColor = UIColor.lightGray.cgColor
        timeFilterButton.layer.borderWidth = 0.5
        timeFilterButton.layer.cornerRadius = 15
        let timeIcon = SimiImageView(image: UIImage(named: "icon_time"))
        ImageViewToColor(imageView: timeIcon, color: UIColor.gray)
        timeIcon.frame = CGRect(x: 17, y: 5, width: 25, height: 25)
        timeFilterButton.addSubview(timeIcon)
        if (timeFilterLabel == nil) {
            timeFilterLabel = SimiLabel(frame: CGRect(x: 42, y: 7.5, width: scaleValue(inputSize: 160) - 42, height: 20))
            timeFilterLabel.text = STLocalizedString(inputString: "Last 7 Days")
            timeFilterLabel.font = UIFont.systemFont(ofSize: 11)
            timeFilterLabel.textColor = UIColor.gray
        }
        timeFilterButton.addSubview(timeFilterLabel)
        timeFilterButton.addTarget(self, action: #selector(showTimeRangeActionSheet), for: UIControlEvents.touchUpInside)
        cellToReturn.addSubview(timeFilterButton)
        
        let refreshStatiticsButton = SimiButton(frame: CGRect(x: SimiGlobalVar.screenWidth - scaleValue(inputSize: 160), y: 0, width: scaleValue(inputSize: 150), height: 40))
        let refreshIcon = SimiImageView(image: UIImage(named: "refresh_icon"))
        ImageViewToColor(imageView: refreshIcon, color: UIColor.gray)
        refreshIcon.frame = CGRect(x: scaleValue(inputSize: 160) - 37, y: 12, width: 17, height: 17)
        refreshStatiticsButton.addSubview(refreshIcon)
        let refreshLabel = SimiLabel(frame: CGRect(x: 0, y: 11, width: scaleValue(inputSize: 160) - 42, height: 20))
        refreshLabel.text = STLocalizedString(inputString: "Refresh Site Stats")
        refreshLabel.font = UIFont.systemFont(ofSize: 11)
        refreshLabel.textAlignment = NSTextAlignment.right
        refreshLabel.textColor = UIColor.gray
        refreshStatiticsButton.addSubview(refreshLabel)
        refreshStatiticsButton.addTarget(self, action: #selector(refreshMagentoStats), for: UIControlEvents.touchUpInside)
        cellToReturn.addSubview(refreshStatiticsButton)
    
        return cellToReturn
    }
    
    func createChartRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        if (saleChartView == nil) {
            saleChartView = CombinedChartView()
            saleChartView.frame = CGRect(x: 15, y: 0, width: SimiGlobalVar.screenWidth - 30, height: 320)
            
            saleChartView.chartDescription?.enabled = false
            saleChartView.maxVisibleCount = 40
            saleChartView.pinchZoomEnabled = false
            saleChartView.drawGridBackgroundEnabled = false
            saleChartView.drawBarShadowEnabled = false
            saleChartView.drawValueAboveBarEnabled = false
            saleChartView.highlightFullBarEnabled = false
            //saleChartView.rightAxis.enabled = false
            
            let xAxis = saleChartView.xAxis
            xAxis.labelPosition = .bottom
            xAxis.labelRotationAngle = -60
            xAxis.valueFormatter = self
            xAxis.gridColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#F1F1F1")
            xAxis.labelTextColor = UIColor.lightGray
            
            
            leftAxis = saleChartView.leftAxis
            leftAxis.labelPosition = .outsideChart
            leftAxis.gridColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#F1F1F1")
            leftAxis.axisMinimum = 0.0
            leftAxis.valueFormatter = self
            leftAxis.labelTextColor = UIColor.lightGray
            leftAxis.labelCount = 5
            
            rightAxis = saleChartView.rightAxis
            rightAxis.labelPosition = .outsideChart
            rightAxis.gridColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#F1F1F1")
            rightAxis.axisMinimum = 0.0
            rightAxis.valueFormatter = self
            rightAxis.labelTextColor = UIColor.lightGray
            rightAxis.labelCount = 5
            //saleChartView.backgroundColor = UIColor.yellow
        }
        
        //bar chart Data
        if (totalsChartData != nil) && (totalsChartData.count > 0) {
            var maxOrderCount:Double = 1
            var maxOrderValue:Double = 1
            for item in totalsChartData {
                if (item["orders_count"] != nil) && !(item["orders_count"] is NSNull) {
                    let orderCount = Double(item["orders_count"] as! String)!
                    if (orderCount > maxOrderCount) {
                        maxOrderCount = orderCount
                    }
                }
                if (item["total_invoiced_amount"] != nil) && !(item["total_invoiced_amount"] is NSNull) {
                    let orderValue = Double(item["total_invoiced_amount"] as! String)!
                    if (orderValue > maxOrderValue) {
                        maxOrderValue = orderValue
                    }
                }
            }
            amountAndCountRatio = 0.8 * maxOrderValue/maxOrderCount
        }
        
        let saleCombinedChartData = CombinedChartData()
        
        var barChartData:Array<BarChartDataEntry> = []
        var lineChartData:Array<ChartDataEntry> = []
        if (totalsChartData != nil) && (totalsChartData.count > 0) {
            var itemCount:Double = 0
            for item in totalsChartData {
                var orderCountValue:Double = 0
                var incomeValue:Double = 0
                if (item["total_invoiced_amount"] != nil) && !(item["total_invoiced_amount"] is NSNull) {
                    incomeValue = Double(item["total_invoiced_amount"] as! String)! / amountAndCountRatio
                }
                if (item["orders_count"] != nil) && !(item["orders_count"] is NSNull) {
                    orderCountValue = Double(item["orders_count"] as! String)!
                }
                let newBarEntry = BarChartDataEntry(x: itemCount, y: orderCountValue)
                barChartData.append(newBarEntry)
                
                let newLineEntry = ChartDataEntry(x: itemCount, y: incomeValue)
                lineChartData.append(newLineEntry)
                itemCount += 1
            }
        }
        
        let barDataSet = BarChartDataSet(values: barChartData, label: STLocalizedString(inputString: "Orders Count"))
        barDataSet.colors = [THEME_COLOR]
        barDataSet.valueColors = [UIColor.white]
        let barDataSets = [barDataSet]
        let barData = BarChartData(dataSets: barDataSets)
        saleCombinedChartData.barData = barData
        
        let lineDataSet = LineChartDataSet(values: lineChartData, label: (STLocalizedString(inputString: "Total Invoiced") + " (" + SimiGlobalVar.baseCurrency + ")"))
        lineDataSet.colors = [SimiGlobalVar.colorWithHexString(hexStringInput: "#7D0000")]
        lineDataSet.circleColors = [UIColor.clear]
        lineDataSet.valueColors = [UIColor.clear]
        lineDataSet.circleRadius = 1.0
        lineDataSet.circleHoleRadius = 0
        let lineData = LineChartData(dataSets: [lineDataSet])
        if (lineChartData.count > 0) {
            saleCombinedChartData.lineData = lineData
        }
        
        saleChartView.data = saleCombinedChartData
        
        cellToReturn.addSubview(saleChartView)
        return cellToReturn
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if (axis == rightAxis) {
            if (value == 0) {
                return ""
            }
            return String(Int(value))
        } else if (axis == leftAxis) {
            if (value == 0) {
                return ""
            }
            return String(Int(value * amountAndCountRatio))
            //return SimiGlobalVar.baseCurrency + " " + String(Int(value * amountAndCountRatio))
        } else if (axis is XAxis) {
            if (totalsChartData != nil) && (totalsChartData.count > 0) {
                let itemIndex = Int(value)
                if (totalsChartData.indices.contains(itemIndex)) {
                    return (totalsChartData[itemIndex]["period"] as! String)
                }
            }
        }
        return ""
    }
    
    func createTotalSalesRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var cellHeight = 10
        if (saleModel.data["total_sale"] != nil) && !(saleModel.data["total_sale"] is NSNull) {
            let totalSaleData = saleModel.data["total_sale"] as! Dictionary<String, Any>
            
            if (totalSaleData["revenue"] != nil) && !(totalSaleData["revenue"] is NSNull) {
                cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Revenue"), andValue: SimiGlobalVar.getPrice(currency: SimiGlobalVar.baseCurrency, value: (totalSaleData["revenue"] as! String)), atHeight: cellHeight)
                cellHeight += 20
            }
            if (totalSaleData["tax"] != nil) && !(totalSaleData["tax"] is NSNull) {
                cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Tax"), andValue: SimiGlobalVar.getPrice(currency: SimiGlobalVar.baseCurrency, value: (totalSaleData["tax"] as! String)), atHeight: cellHeight)
                cellHeight += 20
            }
            if (totalSaleData["shipping"] != nil) && !(totalSaleData["shipping"] is NSNull) {
                cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Shipping"), andValue: SimiGlobalVar.getPrice(currency: SimiGlobalVar.baseCurrency, value: (totalSaleData["shipping"] as! String)), atHeight: cellHeight)
                cellHeight += 20
            }
            if (totalSaleData["quantity"] != nil) && !(totalSaleData["quantity"] is NSNull) {
                cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Quantity"), andValue: (totalSaleData["quantity"] as! String), atHeight: cellHeight)
                cellHeight += 20
            }
        }
        cellToReturn.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#fafafa")
        cellHeight += 8
        row.height = CGFloat(cellHeight)
        return cellToReturn
    }

    func createLifetimeSalesRow(row: SimiRow, identifier: String)->UITableViewCell{
        let cellToReturn = SimiTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        var cellHeight = 10
        if (saleModel.data["lifetime_sale"] != nil) && !(saleModel.data["lifetime_sale"] is NSNull) {
            let totalSaleData = saleModel.data["lifetime_sale"] as! Dictionary<String, Any>
            
            if (totalSaleData["lifetime"] != nil) && !(totalSaleData["lifetime"] is NSNull) {
                cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Lifetime Sale"), andValue: SimiGlobalVar.getPrice(currency: SimiGlobalVar.baseCurrency, value: (totalSaleData["lifetime"] as! String)), atHeight: cellHeight)
                cellHeight += 20
            }
            if (totalSaleData["average"] != nil) && !(totalSaleData["average"] is NSNull) {
                cellToReturn.addValueLabel(withTitle: STLocalizedString(inputString: "Average"), andValue: SimiGlobalVar.getPrice(currency: SimiGlobalVar.baseCurrency, value: (totalSaleData["average"] as! String)), atHeight: cellHeight)
                cellHeight += 20
            }
        }
        cellHeight += 8
        row.height = CGFloat(cellHeight)
        return cellToReturn
    }
    // MARK: - Time Range
    // MARK: - Add Time Range
    func showTimeRangeActionSheet() {
        timeRangeActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Select Time Range To Filter"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
        
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Last 7 Days")) //1
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Current month")) //2
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Last month")) //3
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "Last 3 months (90 days)")) //4
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "YTD").uppercased()) //5
        timeRangeActionSheet.addButton(withTitle: STLocalizedString(inputString: "2YTD").uppercased()) //6
        timeRangeActionSheet.delegate = self
        
        timeRangeActionSheet.show(in: self.view)
    }
    
    func getTimeRangeParam(month: Int, day: Int, year: Int)->String {
        return String(year)  + "-" +  String(month) + "-" + String(day)
    }
    
    // last 7 days
    func selectDefaultTimeRange() {
        var dateStart = Date()
        let dateEnd = Date()
        let calendar = NSCalendar.current
        
        dateStart = calendar.date(byAdding: .day, value: -6, to: dateStart)!
        salePeriod = "day"
        
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
    
    // MARK: - Action sheet Handler
    override func actionSheet(_ actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        super.actionSheet(actionSheet, willDismissWithButtonIndex: buttonIndex)
        if (timeRangeActionSheet != nil)&&(actionSheet == timeRangeActionSheet)&&(buttonIndex != 0) {
            var dateStart = Date()
            var dateEnd = Date()
            let calendar = NSCalendar.current
            
            switch buttonIndex {
            case 2: //Current month
                let daysPassedCurrentMonth = calendar.dateComponents([.day], from: dateStart as Date).day! - 1
                dateStart = calendar.date(byAdding: .day, value: -daysPassedCurrentMonth, to: dateStart)!
                salePeriod = "day"
                trackEvent("dashboard_action", params: ["filter_action":"chart_current_month"])
                break
            case 3: //Last month
                let daysPassedCurrentMonth = calendar.dateComponents([.day], from: dateStart as Date).day!
                dateEnd = calendar.date(byAdding: .day, value: -daysPassedCurrentMonth, to: dateStart)!
                var lastMontComponent = calendar.dateComponents([.day, .month, .year], from: dateEnd as Date)
                lastMontComponent.day = 1
                dateStart = calendar.date(from: lastMontComponent)!
                salePeriod = "day"
                trackEvent("dashboard_action", params: ["filter_action":"chart_last_month"])
                break
            case 4: //Last 3 months (90 days)
                dateStart = calendar.date(byAdding: .day, value: -90, to: dateStart)!
                salePeriod = "day"
                trackEvent("dashboard_action", params: ["filter_action":"chart_last_3_months"])
                break
            case 5: //YTD
                var yearComponent = calendar.dateComponents([.day, .month, .year], from: dateStart as Date)
                yearComponent.day = 1
                yearComponent.month = 1
                dateStart = calendar.date(from: yearComponent)!
                salePeriod = "month"
                trackEvent("dashboard_action", params: ["filter_action":"chart_year_to_day"])
                break
            case 6: //2YTD
                var yearComponent = calendar.dateComponents([.day, .month, .year], from: dateStart as Date)
                yearComponent.day = 1
                yearComponent.month = 1
                yearComponent.year! -= 1
                dateStart = calendar.date(from: yearComponent)!
                salePeriod = "month"
                trackEvent("dashboard_action", params: ["filter_action":"chart_2_years_to_day"])
                break
            default:
                // last 7 days
                dateStart = calendar.date(byAdding: .day, value: -6, to: dateStart)!
                salePeriod = "day"
                trackEvent("dashboard_action", params: ["filter_action":"chart_last_7_days"])
                break
            }
            timeFilterLabel.text = timeRangeActionSheet.buttonTitle(at: buttonIndex)
            
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
            
            getSales()
            getOrders()
        }
    }
    
    // MARK: - Switch Store
    override func switchStore() {
        super.switchStore()
        getSales()
        getOrders()
    }
    
}
