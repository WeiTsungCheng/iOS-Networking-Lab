
![image](https://github.com/WeiTsungCheng/iOS-Networking-Lab/blob/main/demo/screenshot.png)

# iOS Networking Lab

A SwiftUI playground project for learning and experimenting with:

- URLSession
- URLSessionConfiguration
- URLCache
- Cache Policies
- URLSessionTaskMetrics

The project uses the GitHub API as a real-world endpoint and provides visual feedback to help understand how networking and caching behave under different configurations.

---

## Learning Goals

This project is designed for developers who want to understand:

- How URLSession works
- The difference between `.default` and `.ephemeral`
- How URLCache stores responses
- How request cache policies affect behavior
- How to inspect cached responses
- How to determine whether a response comes from the network or local cache

---

## Features

### Session Modes

#### Default

Uses:

- Memory Cache
- Disk Cache

```swift

URLSessionConfiguration.default

```

---

#### Ephemeral

Uses temporary storage only.

Uses:

- Memory Cache

Does not persist:

- Disk Cache

```swift

URLSessionConfiguration.ephemeral

```

---

#### No Cache

Disables URLCache entirely.

```swift

config.urlCache = nil

```
---

## Supported Experiments

### Single Request

Send a single request and inspect the response.

---

### Request Twice

Send two consecutive requests.

Observe:

- First request → network

- Second request → cache

---

### Cache Only Request

Uses:

```swift

.returnCacheDataDontLoad

```

Only returns cached data.

No network request is allowed.

---

### Reload Ignoring Cache

Uses:

```swift

.reloadIgnoringLocalCacheData

```

Forces a network request.

---

## URLSessionTaskMetrics

The project uses:

```swift

URLSessionTaskDelegate

```

to collect:

```swift

URLSessionTaskMetrics

```

Useful metrics include:

- Resource Fetch Type
- Network Protocol
- Reused Connection
- Request Start Time
- Response Start Time
- Response End Time

---

## API Endpoint

GitHub Repository API:

https://api.github.com/repos/apple/swift

This endpoint is useful because it provides:

- Cache-Control
- ETag
- Last-Modified

allowing cache-related experiments.

---
