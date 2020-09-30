//
//  StorageManager.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/24.
//  Copyright © 2020 Fu Jim. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class StorageManager {
    static let shared = StorageManager()
    private init(){}
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "invoiceDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext(history: PDFCreater) {
        let context = persistentContainer.viewContext
        let historyItem = Histories(entity: Histories.entity(), insertInto: context)
        historyItem.track = history.track
        historyItem.editor = history.editor
        historyItem.productName = history.productName
        historyItem.money = history.money
        historyItem.tax = history.tax
        historyItem.total = history.total
        historyItem.buyer = history.buyer
        historyItem.createTime = history.createTime
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func fetchData() -> [Histories] {
      
      let context = persistentContainer.viewContext
      
      var returnData: [Histories] = []
      
      do {
        
        returnData = try context.fetch(Histories.fetchRequest())
        return returnData
        
      } catch {
        fatalError("\(error)")
      }
    }
}
