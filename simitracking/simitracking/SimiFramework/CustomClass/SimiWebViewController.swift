//
//  SimiWebViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/28/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiWebViewController: SimiViewController, UIWebViewDelegate {

    public var content:String?
    public var urlPath:String?
    public var webTitle=""
    public var webview:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackButton()
        self.title = webTitle
        if (webview == nil) {
            webview = UIWebView(frame: CGRect(x: 0, y: 0, width: SimiGlobalVar.screenWidth, height: SimiGlobalVar.screenHeight))
            webview.scalesPageToFit = true
            webview.autoresizingMask = UIViewAutoresizing.flexibleBottomMargin
                /*| UIViewAutoresizing.flexibleLeftMargin | UIViewAutoresizing.flexibleRightMargin | UIViewAutoresizing.flexibleTopMargin | UIViewAutoresizing.flexibleWidth | UIViewAutoresizing.flexibleHeight*/
            self.view.addSubview(webview)
        }
        if content == nil {
            webview.delegate = self
            webview.loadRequest(URLRequest(url: URL(string: urlPath!)!))
        } else {
            let htmlString = "<style type=\"text/css\">*{font-family: ProximaNova-Light; font-size: 20 !important;}</style>" + content!
            webview.loadHTMLString(htmlString, baseURL: nil)
        }
    }

}
