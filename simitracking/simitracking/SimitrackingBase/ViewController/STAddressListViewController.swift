//
//  STAddressListViewController
//  SimiTracking
//
//  Created by Hai Nguyen on 11/21/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STAddressListViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var customerId:String?
    private let ROW_HEIGHT:CGFloat = 50
    
    private var mainTableView:SimiTableView!
    private var mainTableViewCells:Array<SimiSection> = []
    private var addressModelCollection:AddressModelCollection!

    private var emptyLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = STLocalizedString(inputString: "Addresses").uppercased()
        if (mainTableView == nil) {
            mainTableView = SimiTableView(frame:
                CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight), style: UITableViewStyle.grouped)
            mainTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
            mainTableView.delegate = self
            mainTableView.dataSource = self
            self.view.addSubview(mainTableView)
        }
        if (emptyLabel == nil) {
            emptyLabel = UILabel(frame: view.bounds)
            emptyLabel.text = STLocalizedString(inputString: "No Addresses Found")
            emptyLabel.textColor = UIColor.gray
            emptyLabel.backgroundColor = UIColor.white
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.font = UIFont.systemFont(ofSize: 14)
            self.view.addSubview(emptyLabel)
        }
        if customerId != nil && customerId != ""{
            getAddresses()
        }
    }

    override func updateViews() {
        super.updateViews()
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.reloadData()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainTableView.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
    }
    
    func getAddresses() {
        if (addressModelCollection == nil) {
            addressModelCollection = AddressModelCollection()
        }
        self.showLoadingView()
        emptyLabel.isHidden = true
        let paramMeters:Dictionary<String, String> = ["limit":"9999","offset":"0","customer_id":customerId!]
        
        addressModelCollection.getAddressListWithParams(params: paramMeters)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetAddressList(notification:)), name: NSNotification.Name(rawValue: "DidGetAddressList"), object: nil)
    }
    
    // Get Customer List handler
    func didGetAddressList(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetAddressList"), object: nil)
        
        if addressModelCollection.isSucess == false {
            let alert = UIAlertController(title: "", message: addressModelCollection.error[0]["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: STLocalizedString(inputString: "OK"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if addressModelCollection.total == 0{
                emptyLabel.isHidden = false
            }else{
                emptyLabel.isHidden = true
                setMainTableViewCells()
                mainTableView.reloadData()
            }
            //setCurrentPage(pageNumber: currentPage)
        }
    }
    
    // Display Functions
    func setMainTableViewCells() {
        mainTableViewCells = []
        let items = addressModelCollection.data
        for item in items {
            let newSection:SimiSection = SimiSection()
            newSection.data["title"] = "#" + (item["entity_id"] as! String)
            let newRow:SimiRow = SimiRow(withIdentifier: (item["entity_id"] as! String))
            newRow.data = item
            newSection.childRows.append(newRow)
            mainTableViewCells.append(newSection)
        }
        if (addressModelCollection.data.count == 0) {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
        }
    }
    
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = mainTableViewCells[indexPath.section] 
        let row = section.childRows[indexPath.row]
        return row.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: 20))
        let section = mainTableViewCells[section]
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
        if (mainTableViewCells.count == 0) {
            return 0
        }
        let mainSection =  mainTableViewCells[section]
        return mainSection.childRows.count
    }
    /*
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
        self.navigationController?.pushViewController(newCustomerDetailVC, animated: true)
    }
     */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        let rowData = row.data
        
        var identifier = row.identifier
        identifier += SimiGlobalVar.layoutDirection
        
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        
        if (cellToReturn == nil) {
            cellToReturn = createAddressDetailRow(row: row, identifier: identifier, addressData:rowData)
        }
        return cellToReturn!
    }
    
    
    func createAddressDetailRow(row: SimiRow, identifier: String, addressData: Dictionary<String, Any>)->UITableViewCell{
        let cellToReturn = STAddressTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        cellToReturn.setCellWithInfo(addressData: addressData, row: row)
        return cellToReturn
    }

}
