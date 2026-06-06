//
//  ContentView.swift
//  CacheLab
//
//  Created by WEITSUNG on 06/06/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel: URLCacheLabViewModel
    
    init() {
        _viewModel = State(wrappedValue: URLCacheLabViewModel())
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                Section("Session Mode") {
                    Picker("Mode", selection: $viewModel.selectedMode) {
                        ForEach(SessionMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(viewModel.selectedMode.explanation)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                
                Section("Experiments") {
                    
                    Button("Run Request Twice") {
                        Task {
                            await viewModel.runRequestTwice()
                        }
                    }
                    
                    Button("Cache Only Request") {
                        Task {
                            await viewModel.runCacheOnlyRequest()
                        }
                    }
                    
                    Button("Reload Ignoring Cache") {
                        Task {
                            await viewModel.runReloadIgnoringCacheRequest()
                        }
                    }
                    
                    Button("Inspect Cache") {
                        viewModel.inspectCache()
                    }
                }
                
                Section("Utility") {
                    Button("Clear Cache", role: .destructive) {
                        viewModel.clearCache()
                    }
                }
                
                Section("Result") {
                    ScrollView(.horizontal) {
                        Text(viewModel.output)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                
            }
        }
    }
}

#Preview {
    ContentView()
}
