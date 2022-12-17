//
//  ExtensionDelegate.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 07.09.21.
//

import Foundation
import WatchKit
import os

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                loadComplicationData()
                scheduleComplicationBackgroundRefresh()
                backgroundTask.setTaskCompletedWithSnapshot(true)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}

func scheduleComplicationBackgroundRefresh() {
    
    let targetDate = Date().addingTimeInterval(16.0 * 60.0)
    WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: targetDate, userInfo: nil) { (error) in
        
        if let error = error {
            NSLog("error creating background task: \(error.localizedDescription)")
            return
        }
    }
}
