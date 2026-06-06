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
    
    func runRequestTwice() async {
        output = ""
        append("""
            Mode: \(selectedMode.title)
            
            Meaning: \(selectedMode.explanation)
            
            Target: \(url.absoluteString)
            """)
        
        let session = URLSessionFactory.makeSession(mode: selectedMode)
        
        await request(title: "First Request",
                      session: session,
                      cachePolicy: .useProtocolCachePolicy)
        
        await request(title: "Second Request",
                      session: session,
                      cachePolicy: .useProtocolCachePolicy)
    }
    
    func runCacheOnlyRequest() async {
        output = ""
        append("""
            ===== Cache Only Experiment =====
            Mode: \(selectedMode.title)
            
            Request Policy: returnCacheDataLontLoad
            
            Meaning: Ony return cached data. Do not load from network
            
            """)
        
        let session = URLSessionFactory.makeSession(mode: selectedMode)
        
        await request(title: "Cache Only Request",
                      session: session,
                      cachePolicy: .returnCacheDataDontLoad)
    }
    
    func runReloadIgnoringCacheRequest() async {
        output = ""
        append("""
            ====== Reload Ignoring Cache Experiment =====
            Mode: \(selectedMode.title)
            
            Request Policy: reloadIgnoringLocalCacheData
            
            """)
        
        let session = URLSessionFactory.makeSession(mode: selectedMode)
        
        await request(title: "Reload Ignoring Cache Request",
                      session: session,
                      cachePolicy: .reloadIgnoringLocalCacheData)
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
            URLSessionFactory.persistentCache.removeAllCachedResponses()
            output = "Default persistent cache cleared"
        case .ephemeral:
            URLSessionFactory.ephemeralMemoryCache.removeAllCachedResponses()
            output = "Ephermeral cache is not persistent. Requires session or restart app to observe the difference"
        case .noCache:
            output = "No cache mode has no URLCache to clear"
        }
    }
    
    private func request(
        title: String,
        session: URLSession,
        cachePolicy: URLRequest.CachePolicy
    ) async {
        do {
            var request = URLRequest(url: url)
            request.cachePolicy = cachePolicy
            
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
                
                Request Cache Policy: \(cachePolicy)
                
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
                
                Request Cache Policy: \(cachePolicy)

                Error: \(error.localizedDescription)

                """)
        }
    }
    
    
    private func append(_ text: String) {
        output += "\n" + text
    }
    
}
