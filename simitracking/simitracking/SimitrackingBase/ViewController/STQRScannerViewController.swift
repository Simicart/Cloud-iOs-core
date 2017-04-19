//
//  STQRScannerViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 12/6/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit
import AVFoundation

protocol STQRScannerViewControllerDelegate {
    func didScannedWithCode(code: String)
}

class STQRScannerViewController: SimiViewController, AVCaptureMetadataOutputObjectsDelegate {

    private var dissmissButton:SimiButton!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var squareView:SimiView!
    
    public var delegate:STQRScannerViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        captureSession.startRunning();

        
        dissmissButton = SimiButton(frame: CGRect(x: 20, y: (SimiGlobalVar.screenHeight - 60), width: (SimiGlobalVar.screenWidth - 40), height: 40))
        dissmissButton.layer.cornerRadius = 2
        dissmissButton.addTarget(self, action: #selector(dissmissVC), for: UIControlEvents.touchUpInside)
        dissmissButton.backgroundColor = THEME_COLOR
        dissmissButton.setTitle(STLocalizedString(inputString: "Dismiss"), for: UIControlState.normal)
        dissmissButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.view.addSubview(dissmissButton)
        
        squareView = SimiView(frame: CGRect(x: (SimiGlobalVar.screenWidth - 300)/2, y: (SimiGlobalVar.screenHeight - 300)/2, width: 300, height: 300))
        squareView.layer.borderColor = UIColor.white.cgColor
        squareView.layer.borderWidth = 1
        self.view.addSubview(squareView)

    }
    
    override func updateViews() {
        super.updateViews()
        dissmissButton.frame = CGRect(x: 20, y: (SimiGlobalVar.screenHeight - 60), width: (SimiGlobalVar.screenWidth - 40), height: 40)
        squareView.frame = CGRect(x: (SimiGlobalVar.screenWidth - 280)/2, y: (SimiGlobalVar.screenHeight - 280)/2, width: 280, height: 280)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    public func dissmissVC() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func failed() {
        let ac = UIAlertController(title: STLocalizedString(inputString:"Scanning not supported"), message: STLocalizedString(inputString: "Your device does not support scanning a code from an item. Please use a device with a camera."), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: readableObject.stringValue);
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        self.delegate.didScannedWithCode(code: code)
        print(code)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
