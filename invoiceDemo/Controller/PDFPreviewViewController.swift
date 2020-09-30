//
//  PDFPreviewViewController.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/8.
//  Copyright © 2020 Fu Jim. All rights reserved.
//

import UIKit
import PDFKit

class PDFPreviewViewController: UIViewController {

    @IBOutlet weak var PDFview: PDFView!
    public var documentData: Data?
    override func viewDidLoad() {
        super.viewDidLoad()
       if let data = documentData {
          PDFview.document = PDFDocument(data: data)
          PDFview.autoScales = true
        }
    }

}
