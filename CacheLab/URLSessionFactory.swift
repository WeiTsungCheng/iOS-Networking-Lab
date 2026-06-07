//
//  URLSessionFactory.swift
//  CacheLab
//
//  Created by WEITSUNG on 06/06/2026.
//

import Foundation

struct URLSessionFactory {
    
    private static var cacheDirectory: URL {
        let cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0]
        
        let directory = cacheDirectory.appendingPathComponent("CacheLab.DefaultCache", isDirectory: true)
        
        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return directory
    }
    
    static var persistentCache = URLCache(
        memoryCapacity: 10 * 1024 * 1024,
        diskCapacity: 50 * 1024 * 1024,
        directory: cacheDirectory
    )
    
    static var ephemeralMemoryCache = URLCache(
        memoryCapacity: 10 * 1024 * 1024,
        diskCapacity: 0
    )
    
    static func makeSession(
        mode: SessionMode,
        delegate: URLSessionTaskDelegate? = nil
    ) -> URLSession {
        let config: URLSessionConfiguration
        
        switch mode {
        case .default:
            config = .default
            config.urlCache = persistentCache
        case .ephemeral:
            config = .ephemeral
            // ephemeral 的儲存是內部機制, 這裡直接寫入是為了觀察只有 memory 有資料 disk 沒有
            config.urlCache = ephemeralMemoryCache
            config.requestCachePolicy = .useProtocolCachePolicy // 要不要使用快取，由 HTTP 協定（Cache-Control、Expires、ETag 等 Header）來決定
        case .noCache:
            config = .default
            config.urlCache = nil
            config.requestCachePolicy = .reloadIgnoringLocalCacheData // 不要相信本機快取（Cache），每次都直接去網路抓最新資料。
        }
        
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }
    
    static func cache(for mode: SessionMode) -> URLCache? {
        switch mode {
        case .default:
            return persistentCache
        case .ephemeral:
            return ephemeralMemoryCache
        case .noCache:
            return nil
        }
    }
    
    // 為 .default 設定客製化的 Cache
    static func resetPersistentCache() {
        persistentCache.removeAllCachedResponses()
        persistentCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024,
            directory: cacheDirectory
        )
    }
    
    // 為 .ephemeral 設定客製化的 Cache (實際專案不需要, 這裡只是為了驗證真的會存在 memory 而設置)
    static func resetEphemeralMemoryCache() {
        ephemeralMemoryCache.removeAllCachedResponses()
        ephemeralMemoryCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 0,
            directory: cacheDirectory
        )
    }
    
}
