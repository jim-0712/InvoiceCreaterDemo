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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editorTextField.delegate = self
        productNameTextField.delegate = self
        buyerTextField.delegate = self
        previewButton.addTarget(self, action: #selector(previewPress), for: .touchUpInside)
        printButton.addTarget(self, action: #selector(printPress), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func previewPress(){
        if isEdit {
            performSegue(withIdentifier: "previewSegue", sender: nil)
        } else {
            showAlarm("請先填完資料")
        }
    }
    
    @objc func printPress() {
        if let track = trackContentLabel.text, let editor = editorTextField.text, let productName = productNameTextField.text, let money = priceContentLabel.text, let tax = taxContentLabel.text, let total = totalPriceContentLabel.text, let buyer = buyerTextField.text {
            let pdfCreator = PDFCreater(track: track,
                                        editor: editor,
                                        productName: productName,
                                        money: money,
                                        tax: tax,
                                        total: total,
                                        buyer: buyer)
            let pdfData = pdfCreator.createFlyer()
            let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
            present(vc, animated: true, completion: nil)
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
            if isEdit && isBuyer {
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
            
            switch content.findChineseCharacters {
            case .all:
                isBuyer = true
            case .notFound:
                isBuyer = true
            case .contain:
                isBuyer = false
                showAlarm("買方只能完全中文或全英文")
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

