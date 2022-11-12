

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scanBarButton: UIButton!
    @IBOutlet weak var scanTextField: UITextField!
    let scannerViewController = ScannerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        scannerViewController.delegate = self
    }
    
    @IBInspectable var rounded: Bool = false {
        didSet{
            
        }
    }
    
    func update_corner_radius(){
        
    }
}


extension ViewController: ScannerViewDelegate {
    func didFindScannedText(text: String) {
        scanTextField.text = text
    }
}

extension ViewController {
    private func updateUI() {
        scanBarButton.layer.cornerRadius = 10
        scanTextField.isHidden = true
        view.backgroundColor = UIColor(hex: "FFFFFF")
        scanBarButton.setTitle("Begin Scanning", for: .normal)
        scanBarButton.setTitleColor(UIColor.white, for: .normal)
        scanBarButton.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-Thin" , size: 25)
        scanBarButton.addTarget(self, action: #selector(scanBarTapped), for: .touchUpInside)
        
        scanTextField.text = "Default"
        scanTextField.textAlignment = .center
        scanTextField.textColor = UIColor.white
        scanTextField.font = (UIFont(name: "AppleSDGothicNeo-Bold", size: 25))
    }
    
    @objc func scanBarTapped() {
        self.navigationController?.pushViewController(scannerViewController, animated: true)
    }
}
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
