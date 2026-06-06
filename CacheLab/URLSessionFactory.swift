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
    
    static let persistentCache = URLCache(
        memoryCapacity: 10 * 1024 * 1024,
        diskCapacity: 50 * 1024 * 1024,
        directory: cacheDirectory
    )
    
    static let ephemeralMemoryCache = URLCache(
        memoryCapacity: 10 * 1024 * 1024,
        diskCapacity: 0
    )
    
    static func makeSession(mode: SessionMode) -> URLSession {
        let config: URLSessionConfiguration
        
        switch mode {
        case .default:
            config = .default
            config.urlCache = persistentCache
        case .ephemeral:
            config = .ephemeral
            // ephemeral 的儲存是內部機制, 這裡直接寫入是為了觀察只有 memory 有資料 disk 沒有
            config.urlCache = ephemeralMemoryCache
            config.requestCachePolicy = .useProtocolCachePolicy
        case .noCache:
            config = .default
            config.urlCache = nil
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
        }
        
        return URLSession(configuration: config)
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
    
}
