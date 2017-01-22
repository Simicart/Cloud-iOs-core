//
//  STForecastViewController.swift
//  SimiTracking
//
//  Created by Hoang Van Trung on 1/17/17.
//  Copyright © 2017 SimiCart. All rights reserved.
//

import UIKit

class STForecastViewController: StoreviewFilterViewController, UITableViewDelegate, UITableViewDataSource, IAxisValueFormatter, ChartViewDelegate{
    
    let MAIN_SECTION = "MAIN_SECTION"
    let CHART_ROW = "CHART_ROW"
    let REVENUE_ROW = "REVENUE_ROW"
    let SALE_ROW = "SALE_ROW"
    
    private var forecastChartView:CombinedChartView!
    
    private var mainTableView: SimiTableView!
    private var table: SimiTable!
    private var forecastSaleModel: ForecastSaleModel!
    private var totalChartData: Array<Dictionary<String,Any>>!
    private var amountAndCountRatio:Double!
    
    private var ordersLabel: SimiLabel!
    private var invoicesLabel:SimiLabel!
    private var timeForecastLabel:SimiLabel!
    
    private var currentRevenueLabel: SimiLabel!
    private var forecastedRevenueLabel:SimiLabel!
    private var lifeTimeSaleLabel:SimiLabel!
    private var averageSaleLabel:SimiLabel!
    
    private var refreshControl:UIRefreshControl!
    
    private var leftAxis:YAxis!
    private var rightAxis:YAxis!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView = SimiTableView(frame:view.bounds, style:UITableViewStyle.plain)
        mainTableView.separatorStyle = .none
        view .addSubview(mainTableView)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        //Add refresh control
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.white
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(getForecastSale), for: UIControlEvents.valueChanged)
        mainTableView.addSubview(refreshControl)
        
        navigationItem.title = STLocalizedString(inputString: "Forecast").uppercased()
        
        initTableCells()
        getForecastSale()
    }
    
    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight);
            initTableCells()
        }
    }
    
    func initTableCells(){
        table = SimiTable()
        let mainSection = table.addSectionWithIdentifier(identifier: MAIN_SECTION)
        mainSection.addRowWithIdentifier(identifier: CHART_ROW, height: SimiGlobalVar.screenWidth)
        mainSection.addRowWithIdentifier(identifier: REVENUE_ROW, height: 70)
        mainSection.addRowWithIdentifier(identifier: SALE_ROW, height: 70)
        
        mainTableView.reloadData()
    }
    
    func getForecastSale(){
        if forecastSaleModel == nil{
            forecastSaleModel = ForecastSaleModel()
        }
        forecastSaleModel.getForecastSaleWith(params: ["number_of_days":"7"])
        NotificationCenter.default.addObserver(self, selector: #selector(didGetForecastSale(noti:)), name: NSNotification.Name(rawValue: DidGetSaleInfo), object: nil)
        refreshControl.endRefreshing()
        self.showLoadingView()
    }

    func didGetForecastSale(noti:Notification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DidGetSaleInfo), object: nil)
        mainTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: -UITableViewDelegate && UITableViewDataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let simiSection = table.sectionAtIndex(index: indexPath.section)
        let simiRow = simiSection.rowAtIndex(index: indexPath.row)
        return simiRow.height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let simiSection = table.sectionAtIndex(index: section)
        return simiSection.rowCount
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return table.sectionCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simiSection = table.sectionAtIndex(index: indexPath.section)
        let simiRow = simiSection.rowAtIndex(index: indexPath.row)
        var cell: UITableViewCell!
        if(simiRow.identifier == CHART_ROW){
            cell = createChartRow(row: simiRow)
        }else if simiRow.identifier == REVENUE_ROW{
            cell = createRevenueRow(row: simiRow)
        }else if simiRow.identifier == SALE_ROW{
            cell = createSaleRow(row: simiRow)
        }
        if cell == nil{
            cell = UITableViewCell()
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func createRevenueRow(row:SimiRow) -> UITableViewCell{
        var revenueCell = mainTableView.dequeueReusableCell(withIdentifier: row.identifier)
        if revenueCell == nil{
            revenueCell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:row.identifier)
            let currentRevenueTitleLabel = SimiLabel(frame:CGRect(x:15,y:10,width:SimiGlobalVar.screenWidth/2 - 15,height:25))
            currentRevenueTitleLabel.font = UIFont.systemFont(ofSize: 13)
            currentRevenueTitleLabel.text = STLocalizedString(inputString: "Current Revenue")
            currentRevenueLabel = SimiLabel(frame:CGRect(x:SimiGlobalVar.screenWidth/2,y:10,width:SimiGlobalVar.screenWidth/2-15,height:25))
            currentRevenueLabel.font = UIFont.boldSystemFont(ofSize: 12)
            let forecastedRevenueTitleLabel = SimiLabel(frame:CGRect(x:15,y:35,width:SimiGlobalVar.screenWidth/2 - 15,height:25))
            forecastedRevenueTitleLabel.font = UIFont.systemFont(ofSize: 13)
            forecastedRevenueTitleLabel.text = STLocalizedString(inputString: "Forecasted Revenue")
            forecastedRevenueLabel = SimiLabel(frame:CGRect(x:SimiGlobalVar.screenWidth/2,y:35,width:SimiGlobalVar.screenWidth/2-15,height:25))
            forecastedRevenueLabel.font = UIFont.boldSystemFont(ofSize: 12)
            revenueCell?.contentView.addSubview(currentRevenueTitleLabel)
            revenueCell?.contentView.addSubview(currentRevenueLabel)
            revenueCell?.contentView.addSubview(forecastedRevenueTitleLabel)
            revenueCell?.contentView.addSubview(forecastedRevenueLabel)
            revenueCell?.contentView.backgroundColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#f1f1f1")
        }
        return revenueCell!
    }
    
    func createSaleRow(row:SimiRow) -> UITableViewCell{
        var saleCell = mainTableView.dequeueReusableCell(withIdentifier: row.identifier)
        if saleCell == nil{
            saleCell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:row.identifier)
            let lifeTimeSaleTitleLabel = SimiLabel(frame:CGRect(x:15,y:10,width:SimiGlobalVar.screenWidth/2 - 15,height:25))
            lifeTimeSaleTitleLabel.font = UIFont.systemFont(ofSize: 13)
            lifeTimeSaleTitleLabel.text = STLocalizedString(inputString: "Lifetime Sale")
            lifeTimeSaleLabel = SimiLabel(frame:CGRect(x:SimiGlobalVar.screenWidth/2,y:10,width:SimiGlobalVar.screenWidth/2-15,height:25))
            lifeTimeSaleLabel.font = UIFont.boldSystemFont(ofSize: 12)
            let averageSaleTitleLabel = SimiLabel(frame:CGRect(x:15,y:35,width:SimiGlobalVar.screenWidth/2 - 15,height:25))
            averageSaleTitleLabel.font = UIFont.systemFont(ofSize: 13)
            averageSaleTitleLabel.text = STLocalizedString(inputString: "Average")
            averageSaleLabel = SimiLabel(frame:CGRect(x:SimiGlobalVar.screenWidth/2,y:35,width:SimiGlobalVar.screenWidth/2-15,height:25))
            averageSaleLabel.font = UIFont.boldSystemFont(ofSize: 12)
            saleCell?.contentView.addSubview(lifeTimeSaleTitleLabel)
            saleCell?.contentView.addSubview(lifeTimeSaleLabel)
            saleCell?.contentView.addSubview(averageSaleTitleLabel)
            saleCell?.contentView.addSubview(averageSaleLabel)
        }
        return saleCell!
    }
    
    func createChartRow(row: SimiRow)->UITableViewCell{
        var chartCell = mainTableView.dequeueReusableCell(withIdentifier: row.identifier)
        if chartCell == nil{
            chartCell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:row.identifier)
            timeForecastLabel = SimiLabel(frame:CGRect(x:15,y:10,width:SimiGlobalVar.screenWidth - 30,height:20))
            timeForecastLabel.textColor = UIColor.green
            timeForecastLabel.font = UIFont.boldSystemFont(ofSize: 15)
            timeForecastLabel.text = "3 month forecast"
            timeForecastLabel.textAlignment = NSTextAlignment.center
            chartCell?.contentView.addSubview(timeForecastLabel)
            ordersLabel = SimiLabel(frame:CGRect(x:15,y:35,width:SimiGlobalVar.screenWidth/2 - 15,height:20))
            ordersLabel.textColor = UIColor.lightGray
            ordersLabel.font = THEME_BOLD_FONT
            ordersLabel.text = "Orders"
            chartCell?.contentView.addSubview(ordersLabel)
            invoicesLabel = SimiLabel(frame:CGRect(x:SimiGlobalVar.screenWidth/2,y:35,width:SimiGlobalVar.screenWidth/2 - 15,height:20))
            invoicesLabel.text = "Invoices"
            chartCell?.contentView.addSubview(invoicesLabel)
            invoicesLabel.textColor = UIColor.lightGray
            invoicesLabel.font = THEME_BOLD_FONT
            invoicesLabel.textAlignment = NSTextAlignment.right
            
            forecastChartView = CombinedChartView(frame:CGRect(x:15,y:60,width:Int(SimiGlobalVar.screenWidth - 30), height:Int(row.height - 60)))
            forecastChartView.chartDescription?.enabled = false
            forecastChartView.maxVisibleCount = 40
            forecastChartView.pinchZoomEnabled = false
            forecastChartView.drawGridBackgroundEnabled = false
            forecastChartView.drawBarShadowEnabled = false
            forecastChartView.drawValueAboveBarEnabled = false
            forecastChartView.highlightFullBarEnabled = false
            //saleChartView.rightAxis.enabled = false
            
            
            let xAxis = forecastChartView.xAxis
            xAxis.labelPosition = .bottom
            xAxis.labelRotationAngle = -60
            xAxis.valueFormatter = self
            xAxis.gridColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#F1F1F1")
            xAxis.labelTextColor = UIColor.lightGray
            
            
            leftAxis = forecastChartView.leftAxis
            leftAxis.labelPosition = .outsideChart
            leftAxis.gridColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#F1F1F1")
            leftAxis.axisMinimum = 0.0
            leftAxis.valueFormatter = self
            leftAxis.labelTextColor = UIColor.lightGray
            leftAxis.labelCount = 5
            
            rightAxis = forecastChartView.rightAxis
            rightAxis.labelPosition = .outsideChart
            rightAxis.gridColor = SimiGlobalVar.colorWithHexString(hexStringInput: "#F1F1F1")
            rightAxis.axisMinimum = 0.0
            rightAxis.valueFormatter = self
            rightAxis.labelTextColor = UIColor.lightGray
            rightAxis.labelCount = 5
            chartCell?.contentView.addSubview(forecastChartView)
        }
        if forecastSaleModel != nil{
            if(forecastSaleModel.data["day"] != nil){
                totalChartData = forecastSaleModel.data["day"] as! Array<Dictionary<String, Any>>
                //bar chart Data
                if (totalChartData != nil && totalChartData.count > 0) {
                    var maxOrderCount:Double = 1
                    var maxOrderValue:Double = 1
                    for item in totalChartData {
                        if (item["orders_count"] != nil){
                            let orderCount = item["orders_count"] as! Double
                            if (orderCount > maxOrderCount) {
                                maxOrderCount = orderCount
                            }
                        }
                        if (item["total_invoiced_amount"] != nil) {
                            let orderValue = item["total_invoiced_amount"] as! Double
                            if (orderValue > maxOrderValue) {
                                maxOrderValue = orderValue
                            }
                        }
                    }
                    amountAndCountRatio = 0.8 * maxOrderValue/maxOrderCount
                }
            }
        }
        
        let saleCombinedChartData = CombinedChartData()
        
        var barChartData:Array<BarChartDataEntry> = []
        var lineChartData:Array<ChartDataEntry> = []
        if totalChartData != nil && totalChartData.count > 0 {
            var itemCount:Double = 0
            for item in totalChartData {
                var orderCountValue:Double = 0
                var incomeValue:Double = 0
                if (item["total_invoiced_amount"] != nil) {
                    incomeValue = item["total_invoiced_amount"] as! Double
                }
                if (item["orders_count"] != nil) {
                    orderCountValue = item["orders_count"] as! Double
                }
                let newBarEntry = BarChartDataEntry(x: itemCount, y: orderCountValue)
                barChartData.append(newBarEntry)
                
                let newLineEntry = ChartDataEntry(x: itemCount, y: incomeValue)
                lineChartData.append(newLineEntry)
                itemCount += 1
            }
        }
        
        let barDataSet = BarChartDataSet(values: barChartData, label: STLocalizedString(inputString: "Orders Count"))
        barDataSet.colors = [UIColor.green]
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
        
        forecastChartView.data = saleCombinedChartData
        forecastChartView.frame = CGRect(x:15,y:60,width:Int(SimiGlobalVar.screenWidth - 30), height:Int(SimiGlobalVar.screenWidth - 60))
        
        ordersLabel.frame = CGRect(x:15,y:35,width:SimiGlobalVar.screenWidth/2 - 15,height:20)
        invoicesLabel.frame = CGRect(x:SimiGlobalVar.screenWidth/2,y:35,width:SimiGlobalVar.screenWidth/2 - 15,height:20)
        timeForecastLabel.frame = CGRect(x:15,y:10,width:SimiGlobalVar.screenWidth - 30,height:20)
        return chartCell!
    }
    
    //MARK :-IAxisValueFormatter
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
//            return SimiGlobalVar.baseCurrency + " " + String(Int(value * amountAndCountRatio))
        } else if (axis is XAxis) {
            if (totalChartData != nil) && (totalChartData.count > 0) {
                let itemIndex = Int(value)
                if (totalChartData.indices.contains(itemIndex)) {
                    return (totalChartData[itemIndex]["period"] as! String)
                }
            }
        }
        return ""
    }
    
    override func switchStore() {
        super.switchStore()
        getForecastSale()
    }
}

