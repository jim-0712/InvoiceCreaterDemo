//
//  HistoryViewController.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/24.
//  Copyright © 2020 Fu Jim. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var invoiceHistory: [Histories] = [] {
        didSet {
            DispatchQueue.main.async {
                self.noDataLabel.isHidden = !(self.invoiceHistory.count == 0)
                self.historyTableView.reloadData()
            }
        }
    }
    
    var preViewCreater: PDFCreater?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.delegate = self
        historyTableView.dataSource = self
        noDataLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        invoiceHistory = StorageManager.shared.fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewSegue" {
            guard let pdfcreater = preViewCreater,
                let vc = segue.destination as? PDFPreviewViewController else { return }
            vc.documentData = pdfcreater.createFlyer()
        }
    }
    
    func rePrint(invoice: PDFCreater) {
        let pdfData = invoice.createFlyer()
        let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
        present(vc, animated: true, completion: nil)
     }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoiceHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.dateLabel.text = "發票日期:\(invoiceHistory[indexPath.row].createTime ?? "")"
        cell.totalLabel.text = "總額:\(invoiceHistory[indexPath.row].total ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension HistoryViewController: tapManager {
    func tapOnPreview(_ preview: Bool, cell: HistoryTableViewCell) {
        guard let index = historyTableView.indexPath(for: cell) else {
            return
        }
        let invoice = invoiceHistory[index.row]
        let pdfCreater = PDFCreater(track: invoice.track ?? "",
                                           editor: invoice.editor ?? "",
                                           productName: invoice.productName ?? "",
                                           money: invoice.money ?? "",
                                           tax: invoice.tax ?? "",
                                           total: invoice.total ?? "",
                                           buyer: invoice.buyer ?? "")
        if preview {
            preViewCreater = pdfCreater
            performSegue(withIdentifier: "previewSegue", sender: nil)
        } else {
            rePrint(invoice: pdfCreater)
        }
    }
}
