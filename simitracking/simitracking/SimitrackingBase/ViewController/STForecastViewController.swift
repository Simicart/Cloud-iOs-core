//
//  STForecastViewController.swift
//  SimiTracking
//
//  Created by Hoang Van Trung on 1/17/17.
//  Copyright © 2017 SimiCart. All rights reserved.
//

import UIKit
import Charts

class STForecastViewController: StoreviewFilterViewController, UITableViewDelegate, UITableViewDataSource, IAxisValueFormatter, ChartViewDelegate{
    
    let MAIN_SECTION = "MAIN_SECTION"
    let CHART_ROW = "CHART_ROW"
    let REVENUE_ROW = "REVENUE_ROW"
    let SALE_ROW = "SALE_ROW"
    
    private var forecastChartView:LineChartView!
    
    private var mainTableView: SimiTableView!
    private var table: SimiTable!
    private var forecastSaleModel: ForecastSaleModel!
    private var totalChartData: Array<Dictionary<String,Any>>!

    private var timeForecastLabel:SimiLabel!
    private var forecastLabel:SimiLabel!
    
    private var currentRevenueLabel: SimiLabel!
    private var forecastedRevenueLabel:SimiLabel!
    private var lifeTimeSaleLabel:SimiLabel!
    private var averageSaleLabel:SimiLabel!
    
    private var refreshControl:UIRefreshControl!
    
    private var leftAxis:YAxis!
    private var rightAxis:YAxis!
    
    private var timeRangeActionSheet: UIActionSheet!
    private var forecastDays:Int = 90
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getForecastSale(numberOfDay: 90)
    }
    
    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight);
            mainTableView.reloadData()
        }
    }
    
    func initTableCells(){
        table = SimiTable()
        let mainSection = table.addSectionWithIdentifier(identifier: MAIN_SECTION)
        mainSection.addRowWithIdentifier(identifier: CHART_ROW, height: 390)
//        mainSection.addRowWithIdentifier(identifier: REVENUE_ROW, height: 70)
//        mainSection.addRowWithIdentifier(identifier: SALE_ROW, height: 70)
    }
    
    func getForecastSale(numberOfDay:Int){
        forecastDays = numberOfDay
        if forecastSaleModel == nil{
            forecastSaleModel = ForecastSaleModel()
        }
        var params:Dictionary = Dictionary<String,String>()
        if (SimiGlobalVar.selectedStoreId != "") {
            params["store_id"] = SimiGlobalVar.selectedStoreId
        }
        params["number_of_days"] = String(numberOfDay)
        forecastSaleModel.getForecastSaleWith(params: params)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetForecastSale(noti:)), name: NSNotification.Name(rawValue: DidGetSaleInfo), object: nil)
        refreshControl.endRefreshing()
        self.showLoadingView()
    }

    func didGetForecastSale(noti:Notification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DidGetSaleInfo), object: nil)
        mainTableView.reloadData()
        switch forecastDays {
        case 30:
            timeForecastLabel.text = "1 " + STLocalizedString(inputString: "month")
            break
        case 60:
            timeForecastLabel.text = "2 " + STLocalizedString(inputString: "months")
            break
        case 90:
            timeForecastLabel.text = "3 " + STLocalizedString(inputString: "months")
            break
        default:
            break
        }
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
            timeForecastLabel = SimiLabel(frame:CGRect(x:15,y:10,width:SimiGlobalVar.screenWidth/2 - 15,height:30))
            timeForecastLabel.textColor = UIColor.green
            timeForecastLabel.font = UIFont.boldSystemFont(ofSize: 15)
            timeForecastLabel.text = "3 months"
            timeForecastLabel.textAlignment = .right
            timeForecastLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTimeRangeActionSheet)))
            timeForecastLabel.isUserInteractionEnabled = true
            forecastLabel = SimiLabel(frame:CGRect(x:SimiGlobalVar.screenWidth/2 + 10,y:10,width:SimiGlobalVar.screenWidth/2 - 25,height:30))
            forecastLabel.text = STLocalizedString(inputString: "forecast")
            forecastLabel.font = UIFont.boldSystemFont(ofSize: 14)
            forecastLabel.textColor = UIColor.gray
            chartCell?.contentView.addSubview(timeForecastLabel)
            chartCell?.contentView.addSubview(forecastLabel)
            
            forecastChartView = LineChartView()
            
            forecastChartView.chartDescription?.enabled = false
            forecastChartView.maxVisibleCount = 40
            forecastChartView.pinchZoomEnabled = false
            forecastChartView.drawGridBackgroundEnabled = false
            forecastChartView.rightAxis.enabled = false
            forecastChartView.drawBordersEnabled = false
            forecastChartView.dragEnabled = true
            forecastChartView.setScaleEnabled(true)
            
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
            
            let chartLegend = forecastChartView.legend
            chartLegend.horizontalAlignment = .left
            chartLegend.verticalAlignment = .bottom
            chartLegend.orientation = .horizontal
            chartLegend.drawInside = false
            
            chartCell?.contentView.addSubview(forecastChartView)
            
            forecastChartView.isHidden = true
            forecastLabel.isHidden = true
            timeForecastLabel.isHidden = true
        }else{
            forecastChartView.isHidden = false
            forecastLabel.isHidden = false
            timeForecastLabel.isHidden = false
        }
        
        //Update frames
        forecastChartView.frame = CGRect(x:15,y:40,width:Int(SimiGlobalVar.screenWidth - 30), height:350)
        timeForecastLabel.frame = CGRect(x:15,y:10,width:SimiGlobalVar.screenWidth/2 - 15,height:30)
        forecastLabel.frame = CGRect(x:SimiGlobalVar.screenWidth/2 + 10,y:10,width:SimiGlobalVar.screenWidth/2 - 25,height:30)
        updateChartData()
        return chartCell!
    }
    
    func updateChartData(){
        if forecastSaleModel != nil && forecastSaleModel.data["day"] != nil{
            totalChartData = forecastSaleModel.data["day"] as! Array<Dictionary<String, Any>>
            var lineChartDataSets = Array<LineChartDataSet>()
            var upperDataEntries = Array<ChartDataEntry>()
            var lowerDataEntries = Array<ChartDataEntry>()
            
            if totalChartData != nil && totalChartData.count > 0 {
                var incomeValue:Double = 0
                for item in totalChartData{
                    var incomeLowerValue:Double = 0
                    var incomeUpperValue:Double = 0
                    if (item["total_invoiced_amount_upper"] != nil) {
                        incomeUpperValue = (item["total_invoiced_amount_upper"] as! Double)
                    }
                    upperDataEntries.append(ChartDataEntry(x: Double(incomeValue), y: incomeUpperValue))
                    if (item["total_invoiced_amount_lower"] != nil) {
                        incomeLowerValue = item["total_invoiced_amount_lower"] as! Double
                    }
                    lowerDataEntries.append(ChartDataEntry(x: Double(incomeValue), y: incomeLowerValue))
                    incomeValue += 1
                }
            }
            
            let upperLineChartDataSet = LineChartDataSet(values: upperDataEntries, label: STLocalizedString(inputString: "Income Upper") + " (" + SimiGlobalVar.baseCurrency + ")")
            upperLineChartDataSet.colors = [SimiGlobalVar.colorWithHexString(hexStringInput: "#3399ff")]
            upperLineChartDataSet.circleColors = [UIColor.clear]
            upperLineChartDataSet.valueColors = [UIColor.clear]
            upperLineChartDataSet.circleRadius = 1.0
            upperLineChartDataSet.circleHoleRadius = 0
            upperLineChartDataSet.mode = .horizontalBezier
            
            let lowerLineChartDataSet = LineChartDataSet(values: lowerDataEntries, label: STLocalizedString(inputString: "Income Lower") + " (" + SimiGlobalVar.baseCurrency + ")")
            lowerLineChartDataSet.colors = [SimiGlobalVar.colorWithHexString(hexStringInput: "#ffa500")]
            lowerLineChartDataSet.circleColors = [UIColor.clear]
            lowerLineChartDataSet.valueColors = [UIColor.clear]
            lowerLineChartDataSet.circleRadius = 1.0
            lowerLineChartDataSet.circleHoleRadius = 0
            lowerLineChartDataSet.mode = .linear
            
            lineChartDataSets.append(upperLineChartDataSet)
            lineChartDataSets.append(lowerLineChartDataSet)
            
            forecastChartView.data = LineChartData(dataSets: lineChartDataSets)
        }
    }
    
    // MARK: - Add Time Range
    func showTimeRangeActionSheet() {
        if timeRangeActionSheet == nil{
            timeRangeActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Select Time Range To Forecast"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
            timeRangeActionSheet.addButton(withTitle: "1 " + STLocalizedString(inputString: "month")) //1
            timeRangeActionSheet.addButton(withTitle: "2 " + STLocalizedString(inputString: "months")) //2
            timeRangeActionSheet.addButton(withTitle: "3 " + STLocalizedString(inputString: "months")) //3
        }
        timeRangeActionSheet.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if timeRangeActionSheet != nil && actionSheet == timeRangeActionSheet{
            switch buttonIndex {
            case 1:
                getForecastSale(numberOfDay: 30)
                trackEvent("forecast_action", params: ["filter_action":"chart_1_month"])
                break
            case 2:
                getForecastSale(numberOfDay: 60)
                trackEvent("forecast_action", params: ["filter_action":"chart_2_months"])
                break
            case 3:
                getForecastSale(numberOfDay: 90)
                trackEvent("forecast_action", params: ["filter_action":"chart_3_months"])
                break
            default:
                break
            }
        }
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
            return String(Int(value))
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
        getForecastSale(numberOfDay: forecastDays)
    }
}

