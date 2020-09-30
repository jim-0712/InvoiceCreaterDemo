//
//  imageViewExtension.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/8.
//  Copyright © 2020 Fu Jim. All rights reserved.
//

import UIKit
import Foundation

extension UIImage {
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let ciimage = filter.outputImage {
                return UIImage(ciImage: ciimage)
            }
        }
        return nil
    }
    
    func generateBarCode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let ciimage = filter.outputImage {
                return UIImage(ciImage: ciimage)
            }
        }
        return nil
    }
}
