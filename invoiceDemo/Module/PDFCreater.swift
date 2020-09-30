//
//  PDFCreater.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/8.
//  Copyright © 2020 Fu Jim. All rights reserved.
//
import UIKit
import Foundation
import PDFKit

class PDFCreater {
    let title: String = "UDNShopping"
    let track: String
    let editor: String
    let productName: String
    let money: String
    let tax: String
    let total: String
    let buyer: String
    var createTime: String = ""
    
    init(track: String, editor: String, productName: String, money: String, tax: String, total: String, buyer: String) {
        self.track = track
        self.editor = editor
        self.productName = productName
        self.money = money
        self.tax = tax
        self.total = total
        self.buyer = buyer
    }
    
    func createFlyer() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Flyer Builder",
            kCGPDFContextAuthor: "Jim",
            kCGPDFContextTitle: title
        ]
        let format =  UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageWidth = 300
        let pageHeight = 400
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            context.beginPage()
            let titleBottom = addTitle(pageRect: pageRect)
            let timeBottom = addTime(pageRect: pageRect, bottom: titleBottom)
            let trackBottom = addTrack(pageRect: pageRect, bottom: timeBottom)
            let interTimeBottom = addTimeAndProductName(pageRect: pageRect, bottom: trackBottom)
            let priceBottom = addPrice(pageRect: pageRect, bottom: interTimeBottom)
            let barCodeBottom = addBarcode(pageRect: pageRect, bottom: priceBottom)
            let _ = addQRCode(pageRect: pageRect, bottom: barCodeBottom)
        }
        
        return data
    }
    
    func addTitle(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 24.0, weight: .heavy)
        let titleAttributes = [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0,
                                     y: 24,
                                     width: titleStringSize.width,
                                     height: titleStringSize.height)
        attributedTitle.draw(in: titleStringRect)
        
        let invoicTitleFont = UIFont.systemFont(ofSize: 26.0, weight: .regular)
        let invoiceAttributes = [NSAttributedString.Key.font: invoicTitleFont]
        let invoiceTitle = NSAttributedString(string: "電子發票證明聯", attributes: invoiceAttributes)
        let invoiceSize = invoiceTitle.size()
        let invoiceRect = CGRect(x: (pageRect.width - invoiceSize.width)/2,
                                 y: titleStringRect.origin.y + titleStringRect.size.height + 4,
                                 width: invoiceSize.width,
                                 height: invoiceSize.height)
        invoiceTitle.draw(in: invoiceRect)
        
        return invoiceRect.origin.y + invoiceRect.size.height
    }
    
    func addTime(pageRect: CGRect, bottom: CGFloat) -> CGFloat {
        let timeFont = UIFont.systemFont(ofSize: 22.0, weight: .regular)
        let timeAttributes = [NSAttributedString.Key.font: timeFont]
        let dateFormatString = createTimeString(isLocal: true)
        let timeTitle = NSAttributedString(string: dateFormatString, attributes: timeAttributes)
        let timeSize = timeTitle.size()
        let timeRect = CGRect(x: (pageRect.width - timeSize.width)/2,
                              y: bottom,
                              width: timeSize.width,
                              height: timeSize.height)
        timeTitle.draw(in: timeRect)
        return timeRect.origin.y + timeRect.height
    }
    
    func createTimeString(isLocal: Bool) -> String {
        let date: Date = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        if isLocal {
            dateFormatter.dateFormat = "yyy 年 MM 月"
            dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei")
            dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.republicOfChina)
            return dateFormatter.string(from: date)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let dateFormatterSimple = DateFormatter()
            dateFormatterSimple.dateFormat = "yyyy/MM/dd HH:mm"
            createTime = dateFormatterSimple.string(from: date)
            return dateFormatter.string(from: date)
        }
    }
    
    func addTrack(pageRect: CGRect, bottom: CGFloat) -> CGFloat {
        let trackFont = UIFont.systemFont(ofSize: 22, weight:.regular)
        let trackAttribure = [NSAttributedString.Key.font: trackFont]
        let trackString = NSAttributedString(string: track, attributes: trackAttribure)
        let trackSize = trackString.size()
        let trackRect = CGRect(x: (pageRect.width - trackSize.width)/2,
                               y: bottom,
                               width: trackSize.width,
                               height: trackSize.height)
        trackString.draw(in: trackRect)
        return trackRect.origin.y + trackRect.height
     }
    
    func addTimeAndProductName(pageRect: CGRect, bottom: CGFloat) -> CGFloat {
        let Font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        let Attributes = [NSAttributedString.Key.font: Font]
        let dateFormatString = createTimeString(isLocal: false)
        let timeTitle = NSAttributedString(string: dateFormatString, attributes: Attributes)
        let timeSize = timeTitle.size()
        let timeRect = CGRect(x: 30,
                              y: bottom + 4,
                              width: timeSize.width,
                              height: timeSize.height)
        timeTitle.draw(in: timeRect)
        
        let editorString = NSAttributedString(string: "賣方:\(editor)", attributes: Attributes)
        let editorSize = editorString.size()
        let editorRect = CGRect(x: pageRect.width / 2 + 15,
                                 y: bottom + 4,
                                 width: editorSize.width,
                                 height: editorSize.height)
        editorString.draw(in: editorRect)
        
        return timeRect.origin.y + timeRect.height
    }
    
    func addPrice(pageRect: CGRect, bottom: CGFloat) -> CGFloat {
        let Font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        let Attributes = [NSAttributedString.Key.font: Font]
        let number = Int.random(in: 1000..<9999)
        let randomTitle = NSAttributedString(string: "隨機碼:\(number)", attributes: Attributes)
        let taxSize = randomTitle.size()
        let taxRect = CGRect(x: 30,
                              y: bottom,
                              width: taxSize.width,
                              height: taxSize.height)
        randomTitle.draw(in: taxRect)
        let totalString = NSAttributedString(string: "總額:\(total)", attributes: Attributes)
        let totalSize = totalString.size()
        let totalRect = CGRect(x: pageRect.width / 2 + 15,
                                 y: bottom,
                                 width: totalSize.width,
                                 height: totalSize.height)
        totalString.draw(in: totalRect)
        
        return taxRect.origin.y + taxRect.height
    }
    
    func addBarcode(pageRect: CGRect, bottom: CGFloat) -> CGFloat {
        let image = UIImage()
        if let barImage = image.generateBarCode(from: "productName:\(productName) tax:\(tax) total:\(total)") {
            let aspectWidth = (pageRect.width - 60) / barImage.size.width
            let aspectHeight = 120 / barImage.size.height
            let aspectRatio = min(aspectWidth, aspectHeight)
            let scaledWidth = barImage.size.width * aspectRatio
            let imageX = (pageRect.width - scaledWidth) / 2.0
            let imageRect = CGRect(x: imageX,
                                   y: bottom + 6,
                                   width: scaledWidth,
                                   height: 60)
            barImage.draw(in: imageRect)
            return imageRect.origin.y + 60
        }
        return 0
    }
    
    func addQRCode(pageRect: CGRect, bottom: CGFloat) -> CGFloat {
        let rightImage = UIImage()
        if let qrcode = rightImage.generateQRCode(from: "商品名稱:\(productName) 稅額:\(tax) 總額:\(total)") {
            let aspectWidth = 100 / qrcode.size.width
            let aspectHeight = 100 / qrcode.size.height
            let aspectRatio = min(aspectWidth, aspectHeight)
            let scaledWidth = qrcode.size.width * aspectRatio
            let scaledHeight = qrcode.size.height * aspectRatio
            let imageRect = CGRect(x: 30,
                                   y: bottom + 6,
                                   width: scaledWidth,
                                   height: scaledHeight)
            
            let imageRectLeft = CGRect(x: (pageRect.width - scaledWidth - 30) ,
                                       y: bottom + 6,
                                       width: scaledWidth,
                                       height: scaledHeight)
            
            qrcode.draw(in: imageRect)
            qrcode.draw(in: imageRectLeft)
        }
        return 0
    }
}
