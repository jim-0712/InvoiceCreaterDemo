//
//  ViewController.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/7.
//  Copyright © 2020 Fu Jim. All rights reserved.
//

import UIKit

class InvoiceBuliderViewController: UIViewController {

    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackContentLabel: UILabel!
    @IBOutlet weak var editorTitleLabel: UILabel!
    @IBOutlet weak var editorTextField: UITextField!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var priceContentLabel: UILabel!
    @IBOutlet weak var taxTitleLabel: UILabel!
    @IBOutlet weak var taxContentLabel: UILabel!
    @IBOutlet weak var totlaPriceTitleLabel: UILabel!
    @IBOutlet weak var totalPriceContentLabel: UILabel!
    @IBOutlet weak var buyerTitleLabel: UILabel!
    @IBOutlet weak var buyerTextField: UITextField!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var printButton: UIButton!
    var isEdit = false
    var isBuyer = false
    var invoiceData: PDFCreater?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if UserDefaults.standard.integer(forKey: "number") == 0 {
            trackContentLabel.text = "AB-10000000"
        } else {
             let number = UserDefaults.standard.integer(forKey: "number")
            trackContentLabel.text = "AB-\(number)"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(saveToCore), name: Notification.Name("save"), object: nil)
        
        editorTextField.delegate = self
        productNameTextField.delegate = self
        buyerTextField.delegate = self
        previewButton.addTarget(self, action: #selector(previewPress), for: .touchUpInside)
        printButton.addTarget(self, action: #selector(printPress), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("asdadsada")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func saveToCore() {
        guard let invoice = invoiceData else { return }
        StorageManager.shared.saveContext(history: invoice)
        print("save")
    }
    
    @objc func previewPress(){
        checkTheRule()
        if isEdit && isBuyer {
            performSegue(withIdentifier: "previewSegue", sender: nil)
        } else {
            showAlarm("請先填完資料")
        }
    }
    
    @objc func printPress() {
        checkTheRule()
        if isEdit && isBuyer {
            if let track = trackContentLabel.text,
                let editor = editorTextField.text,
                let productName = productNameTextField.text,
                let money = priceContentLabel.text,
                let tax = taxContentLabel.text,
                let total = totalPriceContentLabel.text,
                let buyer = buyerTextField.text {
                let pdfCreator = PDFCreater(track: track,
                                            editor: editor,
                                            productName: productName,
                                            money: money,
                                            tax: tax,
                                            total: total,
                                            buyer: buyer)
                invoiceData = pdfCreator
                let pdfData = pdfCreator.createFlyer()
                let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
                vc.completionWithItemsHandler = { (type,completed,items,error) in
                    if completed  {
                        guard let track = self.trackContentLabel.text else { return }
                        let index = track.index(track.startIndex, offsetBy: 3)
                        let number = track[index..<track.endIndex]
                        if let interger = Int(number) {
                            UserDefaults.standard.set(interger+1, forKey: "number")
                            if let root = (((UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.visibleViewController as? InvoiceBuliderViewController) {
                                NotificationCenter.default.post(name: Notification.Name("save"), object: nil)
                                root.viewWillAppear(true)
                            }
                        }
                    }
                }
                present(vc, animated: true, completion: nil)
            }
        } else {
            showAlarm("請先填寫資料")
        }
    }
    
    func isPureInt(_ string: String) -> Bool {
        let scan: Scanner = Scanner(string: string)
        if let _ = scan.scanInt() {
            return scan.isAtEnd
        }
        return false
    }
    
    func showAlarm(_ content: String) {
        let alert = UIAlertController(title: "警告", message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkEditRule(_ editor: String) -> Bool {
        let multi = [1, 2, 1, 2, 1, 2, 4, 1]
        var result = 0
        for index in 0 ..< editor.count {
            var deci = 0
            if let number = Int(String(editor[editor.index(editor.startIndex, offsetBy: index)])) {
                if number * multi[index] >= 10 {
                    deci = number * multi[index] / 10
                }
                result += (number * multi[index] % 10 + deci)
            }
        }
        return result % 10 == 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewSegue" {
            guard let vc = segue.destination as? PDFPreviewViewController else { return }
                if let track = trackContentLabel.text, let editor = editorTextField.text, let productName = productNameTextField.text, let money = priceContentLabel.text, let tax = taxContentLabel.text, let total = totalPriceContentLabel.text, let buyer = buyerTextField.text {
                    let pdfCreator = PDFCreater(track: track,
                                                editor: editor,
                                                productName: productName,
                                                money: money,
                                                tax: tax,
                                                total: total,
                                                buyer: buyer)
                    vc.documentData = pdfCreator.createFlyer()
            }
        }
    }
    
    func checkTheRule() {
        guard let content = editorTextField.text else {
            isEdit = false
            return
        }
        
        if content.isEmpty || !isPureInt(content) || !checkEditRule(content) {
            isEdit = false
            return
        }
        
        isEdit = true
        guard let buyerContent = buyerTextField.text else {
            isBuyer = false
            return
        }
        
        if buyerContent.isEmpty {
            isEdit = false
        }
        
        switch buyerContent.findChineseCharacters {
        case .all:
            isBuyer = !(buyerContent.count > 20)
        case .notFound:
            isBuyer = true
        case .contain:
            isBuyer = false
            return
        }
        
        let numbersRange = buyerContent.rangeOfCharacter(from: .decimalDigits)
        isBuyer = numbersRange == nil
    }
    
}

extension InvoiceBuliderViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case editorTextField:
            guard let content = textField.text else {
                showAlarm("統編不得為空")
                isEdit = false
                return
            }
            
            if content.isEmpty {
                showAlarm("統編不得為空")
                isEdit = false
            }
            
            if !isPureInt(content) {
                isEdit = false
                showAlarm("統編只得為數字")
                return
            }
            
            if content.count != 8 {
                isEdit = false
                return
                    showAlarm("統編長度不服")
            }
            if !checkEditRule(content) {
                isEdit = false
                showAlarm("請輸入合法統編")
                return
            }
            
            isEdit = true
            
        case buyerTextField:
            guard let content = buyerTextField.text else {
                showAlarm("買方不得為空")
                isBuyer = false
                return
            }
            
            if content.isEmpty {
                showAlarm("買方不得為空")
                isEdit = false
            }
            
            switch content.findChineseCharacters {
            case .all:
                if content.count > 20 {
                    isBuyer = false
                    showAlarm("字數不得超過20字")
                } else {
                    isBuyer = true
                }
                
            case .notFound:
                isBuyer = true
            case .contain:
                isBuyer = false
                showAlarm("買方只能全中文或全英文(不能包含空格及特殊符號)")
                return
            }
            
            let numbersRange = content.rangeOfCharacter(from: .decimalDigits)
            isBuyer = numbersRange == nil
            if numbersRange != nil {
                showAlarm("買方只能完全中文或全英文")
            }
            
        default:
            break
        }
    }
}

