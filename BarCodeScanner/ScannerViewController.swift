//
//  ScannerViewController.swift
//  BarCodeScanner
//
//  Created by 1 on 11/27/20.
//

import AVFoundation
import UIKit


var response: String?


@objc protocol ScannerViewDelegate: AnyObject {
    @objc func didFindScannedText(text: String)
}

struct Pantry_Response: Codable {
    let success: Bool
}


var player: AVAudioPlayer!



class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @objc public weak var delegate: ScannerViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleFlash(mode: "ON")
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        playSound()
        toggleFlash(mode: "OFF")
        let code = String(code.dropFirst())
        print(code)
        fetchData(upc_code: code)
        //fetchData(upc_code: code)
        viewDidLoad()
        delegate?.didFindScannedText(text: code)
        //self.navigationController?.popViewController(animated: true)
    }
    
    func toggleFlash(mode: String?) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        if (mode == "OFF") {
            do {
                try device.lockForConfiguration()

                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }

                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }else{
            do {
                try device.lockForConfiguration()

                if (device.torchMode == AVCaptureDevice.TorchMode.off) {
                    device.torchMode = AVCaptureDevice.TorchMode.on
                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }

                device.unlockForConfiguration()
            } catch {
                print(error)
            }
            
        }
        
    }
    
    
    func playSound() {
          let url = Bundle.main.url(forResource: "beep boop", withExtension: "mp3")
          player = try! AVAudioPlayer(contentsOf: url!)
          player.play()
       }
    
    
    private func fetchData(upc_code: String){
            let child = SpinnerViewController()
            let key = "UVIzP8SVmJI3bbQ8"

        let url = "https://expired.deta.dev/api/barcode/process?barcode=\(upc_code)&key=\(key)"
                    
            addChild(child)
            child.view.frame = view.frame
            view.addSubview(child.view)
            child.didMove(toParent: self)
            
            URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
                guard let data = data, error == nil else {
                    print("Something Went Wrong!")
                    return
                }
                var result: Pantry_Response?
                do{
                    result = try JSONDecoder().decode(Pantry_Response.self, from: data)
                }
                catch{
                    print("Failed to convert \(error)")
                }
                guard let json = result else{
                    return
                }
                print(json.success)
                
                
                DispatchQueue.main.async {
                    
                    child.willMove(toParent: nil)
                    child.view.removeFromSuperview()
                    child.removeFromParent()

                }
            }).resume()
        }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
