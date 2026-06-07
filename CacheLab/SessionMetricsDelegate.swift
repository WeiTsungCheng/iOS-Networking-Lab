//
//  SessionMetricsDelegate.swift
//  CacheLab
//
//  Created by WEITSUNG on 07/06/2026.
//

import Foundation

final class SessionMetricsDelegate: NSObject, URLSessionTaskDelegate {
    
    var onMetricsCollected: ((URLSessionTaskMetrics) -> Void)?
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        onMetricsCollected?(metrics)
    }
}
