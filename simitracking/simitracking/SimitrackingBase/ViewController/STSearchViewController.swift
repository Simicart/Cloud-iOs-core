//
//  STSearchViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/20/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

protocol STSearchViewControllerDelegate {
    func searchButtonTappedWith(attribute: String, andValue:String)
}

class STSearchViewController: SimiViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var attributeList:Dictionary<String, String> = [:]
    var selectedAttribute = ""
    
    var mainTableView:SimiTableView!
    var mainTableViewCells:Array<SimiSection> = []
    
    var searchTextField:UISearchBar!
    var delegate: STSearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackButton()
        createResetSearchButton()
        self.title = STLocalizedString(inputString: "Search")
        if (mainTableView == nil) {
            mainTableView = SimiTableView()
            mainTableView.frame = CGRect(x: 0, y: 40, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.delegate = self
            mainTableView.dataSource = self
            self.view.addSubview(mainTableView)
        }
        
        mainTableViewCells = []
        let newSection:SimiSection = SimiSection()
        for (index, _) in attributeList {
            if (selectedAttribute == "") {
                selectedAttribute = index
            }
            let newRow:SimiRow = SimiRow(withIdentifier: index)
            newSection.childRows.append(newRow)
        }
        mainTableViewCells.append(newSection)
        searchTextField = UISearchBar(frame: CGRect(x: 0, y: 64, width: SimiGlobalVar.screenWidth, height: 40))
        searchTextField.delegate = self
        self.view.addSubview(searchTextField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDismiss), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Reset Search
    public func createResetSearchButton() {
        let resetSearchBtn: SimiButton = SimiButton(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
        resetSearchBtn.setTitle(STLocalizedString(inputString: "Reset"), for: UIControlState.normal)
        resetSearchBtn.addTarget(self, action: #selector(resetSearch), for: .touchUpInside)
        resetSearchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        let barResetSearchBtn = UIBarButtonItem(customView: resetSearchBtn)
        self.navigationItem.rightBarButtonItem = barResetSearchBtn
    }
    
    public func resetSearch() {
        searchTextField.text = ""
        selectedAttribute = ""
        for (index, _) in attributeList {
            if (selectedAttribute == "") {
                selectedAttribute = index
            }
        }
        mainTableView.reloadData()
        self.delegate?.searchButtonTappedWith(attribute: selectedAttribute, andValue: "")
    }
    
    // MARK: - Update Views
    override func updateViews() {
        super.updateViews()
        if (searchTextField != nil) {
            if (SimiGlobalVar.screenWidth < SimiGlobalVar.screenHeight) || (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                searchTextField.frame = CGRect(x: 0, y: 64, width: SimiGlobalVar.screenWidth, height: 40)
            } else {
                searchTextField.frame = CGRect(x: 0, y: 32, width: SimiGlobalVar.screenWidth, height: 40)
            }
        }
        if (mainTableView != nil) {
            mainTableView.frame = CGRect(x: 0, y: 40, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight)
            mainTableView.reloadData()
        }
    }

    //MARK: - Keyboard Hander
    func keyBoardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        mainTableView.contentInset = UIEdgeInsetsMake(65, 0, keyboardHeight+65, 0)
    }
    func keyboardWillDismiss(){
        mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (mainTableViewCells.count == 0) {
            return 0
        }
        let mainSection =  mainTableViewCells[section]
        return mainSection.childRows.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]
        selectedAttribute = row.identifier
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mainTableViewCells[indexPath.section]
        let row = section.childRows[indexPath.row]

        var identifier = row.identifier
        identifier += SimiGlobalVar.layoutDirection
        var cellToReturn = mainTableView.dequeueReusableCell(withIdentifier: identifier)
        if (cellToReturn == nil) {
            cellToReturn = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            cellToReturn?.frame = CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: 40)
            
            let optionLabel = SimiLabel(frame: CGRect(x: 15, y: 10, width: SimiGlobalVar.screenWidth - 40, height: 20))
            optionLabel.text = attributeList[row.identifier]
            optionLabel.font = UIFont.systemFont(ofSize: 14)
            cellToReturn?.addSubview(optionLabel)
        }
        if (row.identifier == selectedAttribute) {
            cellToReturn?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cellToReturn?.accessoryType = UITableViewCellAccessoryType.none
        }
        return cellToReturn!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Searchbar delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.delegate?.searchButtonTappedWith(attribute: selectedAttribute, andValue: searchTextField.text!)
    }
}
