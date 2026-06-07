//
//  SessionMode.swift
//  CacheLab
//
//  Created by WEITSUNG on 06/06/2026.
//

import Foundation

enum SessionMode: String, CaseIterable, Identifiable {
    var id: Self { self }

    case `default`
    case ephemeral
    case noCache
    
    var title: String {
        switch self {
        case .default: 
            return "Default"
        case .ephemeral: 
            return "Ephemeral"
        case .noCache: 
            return "No Cache"
        }
    }
    
    var explanation: String {
        switch self {
        case .default:
            return "Uses persistent storage. Can use memory cache and disk cache."
        case .ephemeral:
            return "Does not write cache, cookies, or credentials to disk. Mainly memory only."
        case .noCache:
            return "urlCache is nil. URLSession should not use URLCache."
        }
    }
}
