//
//  URLCacheLabViewModel.swift
//  CacheLab
//
//  Created by WEITSUNG on 06/06/2026.
//

import Foundation

@MainActor
@Observable
final class URLCacheLabViewModel {
    
    var selectedMode: SessionMode = .default
    var output: String = "Ready"
    
    private let url = URL(string: "https://api.github.com/repos/apple/swift")!
    private let metricsDelegate = SessionMetricsDelegate()
    
    // 單純打ㄧ次 API
    func runSingleRequest() async {
        
        output = ""
        appendExperimentHeader(title: "Single Request")
        
        await performRequest(
            title: "Single Request",
            cachePolicy: nil
        )
    }
    
    // 連續打兩次 API
    func runRequestTwice() async {
        
        output = ""
        appendExperimentHeader(title: "Request Twice")
        
        await performRequest(
            title: "First Request",
            cachePolicy: nil
        )
        
        await performRequest(
            title: "Second Request",
            cachePolicy: nil
        )
    }
    
    // 只取 Cache 不真的打網路
    func runCacheOnlyRequest() async {
        output = ""
        appendExperimentHeader(title: "Cache Only Request")
        
        await performRequest(
            title: "Cache Only Request",
            cachePolicy: .returnCacheDataDontLoad
        )
    }
    
    // 無論有無 Cache 都打網路
    func runReloadIgnoringCacheRequest() async {
        output = ""
        appendExperimentHeader(title: "Reload Ignoring Cache Request")
        
        await performRequest(
            title: "Reload Ignoring Cache Request",
            cachePolicy: .reloadIgnoringLocalCacheData
        )
    }
    
    func inspectCache() {
        output = ""
        
        let request = URLRequest(url: url)
        let cache = URLSessionFactory.cache(for: selectedMode)
        let cachedResponse = cache?.cachedResponse(for: request)
        
        append("""
            ===== Inspect Cache =====
            Mode: \(selectedMode.title)
            
            Cache Object Exists: \(cache != nil)
            
            Cached Response Exists: \(cachedResponse != nil)
            
            Memory Usage: \(cache?.currentMemoryUsage ?? 0)
            
            Disk Usage: \(cache?.currentDiskUsage ?? 0)
                
            """)
    }
    
    func clearCache() {
        switch selectedMode {
        case .default:
            URLSessionFactory.resetPersistentCache()
            output = "Default persistent cache cleared"
        case .ephemeral:
            URLSessionFactory.resetEphemeralMemoryCache()
            output = "Ephermeral cache is not persistent. Requires session or restart app to observe the difference"
        case .noCache:
            output = "No cache mode has no URLCache to clear"
        }
    }
    
    private func performRequest(
        title: String,
        cachePolicy: URLRequest.CachePolicy? ) async {
            
            configureMetricsDelegate()
            
            let session = URLSessionFactory.makeSession(
                mode: selectedMode,
                delegate: metricsDelegate) // 在生成 Session 時, 將自製的 delegate 的物件傳入
            
            await request(title: title, session: session, cachePolicy: cachePolicy)
            
            session.finishTasksAndInvalidate() // Session 在 Task 完成後需要清除, 避免 delegate 發生錯誤
        }
    
    private func request(
        title: String,
        session: URLSession,
        cachePolicy: URLRequest.CachePolicy?
    ) async {
        do {
            let request = makeRequest(cachePolicy: cachePolicy)
            
            let beforeCache = URLSessionFactory.cache(for: selectedMode)
            let cachedBefore = beforeCache?.cachedResponse(for: request) != nil
            
            let (data, response) = try await session.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                append("\n\(title): Invalid response")
                return
            }
            
            let afterCache = URLSessionFactory.cache(for: selectedMode)
            let cachedAfter = afterCache?.cachedResponse(for: request) != nil
            
            append("""
                ===== \(title) Success =====
                
                Session Mode: \(selectedMode.title)
                
                Request Cache Policy: \(cachePolicy, default: "nil")
                
                Cached Before Request: \(cachedBefore)
                
                Status Code: \(http.statusCode)
                
                Data Size: \(data.count)
                
                Cache-Control: \(http.value(forHTTPHeaderField: "Cache-Control") ?? "nil")
                
                ETag: \(http.value(forHTTPHeaderField: "ETag") ?? "nil")
                
                Last-Modified: \(http.value(forHTTPHeaderField: "Last-Modified") ?? "nil")
                
                Cache Object Exists: \(afterCache != nil)
                
                Cached After Request: \(cachedAfter)
                
                Memory Usage: \(afterCache?.currentMemoryUsage ?? 0)
                
                Disk Usage: \(afterCache?.currentDiskUsage ?? 0)
                
                """)
            
        } catch {
            
            append("""
                ===== \(title) Failed =====
                
                Session Mode: \(selectedMode.title)
                
                Request Cache Policy: \(cachePolicy, default: "nil")
                
                Error: \(error.localizedDescription)
                
                """)
        }
    }
    
    // MARK: - Metrics
    
    private func configureMetricsDelegate() {
        metricsDelegate.onMetricsCollected = { [weak self] metrics in
            Task { @MainActor in
                self?.appendMetrics(metrics)
            }
        }
    }
    
    private func appendExperimentHeader(title: String) {
        
        append("""
        ===== \(title) Experiment =====
        
        Mode: \(selectedMode.title)
        
        Meaning: \(selectedMode.explanation)
        
        Target: \(url.absoluteString)
        
        """)
        
    }
    
    
    
    private func appendMetrics(_ metrics: URLSessionTaskMetrics) {
        append("""
            ===== URLSessionTaskMetrics =====
            
            Redirect Count:
            \(metrics.redirectCount)
            
            Transaction Count:
            \(metrics.transactionMetrics.count)
            
            """)
        
        for (index, transaction) in metrics.transactionMetrics.enumerated() {
            
            //每一個 transaction 代表：這個 URLSession task 裡的一段 request/response 過程。
            append("""
                   
                   Transaction \(index + 1):
                   
                   Resource Fetch Type: 
                   \(describeFetchType(transaction.resourceFetchType))
                   
                   Network Protocol: \(transaction.networkProtocolName ?? "nil")
                   
                   Is Reused Connection: \(transaction.isReusedConnection)
                   
                   Request Start: \(transaction.requestStartDate?.description ?? "nil")
                   
                   Response Start: \(transaction.responseStartDate?.description ?? "nil")
                   
                   Response End: \(transaction.responseEndDate?.description ?? "nil")
                   
                   """)
        }
        
    }
    
    // MARK: - Helpers
    
    private func makeRequest(cachePolicy: URLRequest.CachePolicy? = nil) -> URLRequest {
        
        var request = URLRequest(url: url)
        
        if let cachePolicy {
            request.cachePolicy = cachePolicy
        }
        
        return request
    }
    
    private func describeFetchType(_ type: URLSessionTaskMetrics.ResourceFetchType) -> String {
        
        switch type {
        case .unknown:
            return "unknown (\(type.rawValue))"
            
        case .networkLoad:
            return "networkLoad (\(type.rawValue))"
            
        case .serverPush:
            return "serverPush (\(type.rawValue))"
            
        case .localCache:
            return "localCache (\(type.rawValue))"
            
        @unknown default:
            return "future case (\(type.rawValue))"
        }
        
    }
    
    
    private func append(_ text: String) {
        output += "\n" + text
    }
    
}
