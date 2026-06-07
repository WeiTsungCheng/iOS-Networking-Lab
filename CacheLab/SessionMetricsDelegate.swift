//
//  SessionMetricsDelegate.swift
//  CacheLab
//
//  Created by WEITSUNG on 07/06/2026.
//

import Foundation

// 建立ㄧ個實作 URLSessionTaskDelegate 的物件
final class SessionMetricsDelegate: NSObject, URLSessionTaskDelegate {
    
    var onMetricsCollected: ((URLSessionTaskMetrics) -> Void)? // 設定客製的 closure 將 URLSessionTaskMetrics 資料帶回
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        onMetricsCollected?(metrics)
    }
}
