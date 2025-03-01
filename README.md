# Might Fail

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmight-fail%2Fswift-might-fail%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/might-fail/swift-might-fail)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmight-fail%2Fswift-might-fail%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/might-fail/swift-might-fail)

![Build and Test](https://github.com/meech-ward/AsyncCoreBluetooth/actions/workflows/build.yml/badge.svg)


A Swift library for handling async and sync errors without `try` and `catch` blocks.

[Documentation](https://swift.mightfail.dev/documentation/mightfail)

## Installation

### Swift Package Manager

Add MightFail as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/might-fail/swift.git", from: "0.2.1")
]
```

Then add it to your target's dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["MightFail"]),
]
```

### Import

Import MightFail in your source files:

```swift
import MightFail
```

## Usage

MightFail provides a simplified way to handle errors in Swift without traditional try-catch blocks. It works with both synchronous and asynchronous code.

### Important

- **Always** guard the success case.
- **Never** check the error case.

```swift
// Good
guard let data else {
    // handle error
}
// Good
guard success else {
    // handle error
}
// Bad
if let error {
    // handle error
}
```

### Basic Synchronous Usage

```swift
// Returns (error, result, success)
let (error, result, success) = mightFail {
    return "Success"
}

// Check success
if success {
    print(result) // "Success"
}
```

### Simplified Return Type

```swift
// Returns just (error, result)
let (error, result) = mightFail {
    return 42
}

print(result) // 42
print(error) // nil
```

### Handling Errors

#### Traditional Error Handling:

```swift
var vendingMachine = VendingMachine()
vendingMachine.coinsDeposited = 8
do {
    try buyFavoriteSnack(person: "Alice", vendingMachine: vendingMachine)
    print("Success! Yum.")
} catch VendingMachineError.invalidSelection {
    print("Invalid Selection.")
} catch VendingMachineError.outOfStock {
    print("Out of Stock.")
} catch VendingMachineError.insufficientFunds(let coinsNeeded) {
    print("Insufficient funds. Please insert an additional \(coinsNeeded) coins.")
} catch {
    print("Unexpected error: \(error).")
}
```

#### With MightFail:

```swift
let vendingMachine = VendingMachine()
vendingMachine.coinsDeposited = 8
let (error, _, success) = mightFail {
    try buyFavoriteSnack(person: "Alice", vendingMachine: vendingMachine)
}
guard success else {
    switch error {
    case VendingMachineError.invalidSelection:
        print("Invalid Selection.")
    case VendingMachineError.outOfStock:
        print("Out of Stock.")
    case VendingMachineError.insufficientFunds(let coinsNeeded):
        print("Insufficient funds. Please insert an additional \(coinsNeeded) coins.")
    default:
        print("Unexpected error: \(error).")
    }
    return
}
print("Success! Yum.")
```

### Async Support

```swift
// Basic async usage
let (error, result, success) = await mightFail {
    try await Task.sleep(nanoseconds: 1_000_000)
    return "Async Success"
}

// Simplified async return
let (error, result) = await mightFail {
    try await Task.sleep(nanoseconds: 1_000_000)
    return 42
}
```

### Multiple Operations

You can run multiple operations and get their results:

```swift
let results = mightFail([
    { 1 },
    { throw TestError.simple },
    { 3 },
])

// Check results
results.forEach { (error, result) in
    guard let result else {
        print("Error: \(error)")
        return
    }
    print("Result: \(result)")
}
```

Or maybe something like this:

```swift
guard let imageFiles = await memoryStorage.imageFilesStore[imageId] else {
    return
}
let deleteResults = mightFail([
    { try FileStorage.deleteFile(name: imageFiles.fullSizeName, ext: imageFiles.ext) },
    { try FileStorage.deleteFile(name: imageFiles.thumbnailName, ext: imageFiles.ext) },
    { try FileStorage.deleteFile(name: imageFiles.mediumSizeName, ext: imageFiles.ext) },
])

for deleteResult in deleteResults.filter({ $0.success == false }) {
    print("Failed to delete image file: \(deleteResult.error)")
}

for deleteResult in deleteResults.filter({ $0.success == true }) {
    print("Deleted image file: \(deleteResult.result)")
}
```

### Optional Values

MightFail handles optional values gracefully:

```swift
func returnOptional() throws -> String? {
    return nil
}

let (error, result, success) = mightFail {
    try returnOptional()
}

// success will be true
// result will be nil
// error will be nil
```

# do, try, catch is bad

I think throwing exceptions is nice, I like that an exception breaks control flow and I like exception propogation. The only thing I don't like catching exceptions.

This mostly happens at the most "user facing" part of the code like an api endpoint or a UI component, the outer most function call. So catching an exception needs to notify the user that something went wrong, log the error for debugging, and stop the currently execution flow.

## Guard ✅

Guarding allows you to handle your errors early and return from the function early, making them more readable and easier to reason about.

```swift
// Generic fetch function that can work with any Codable type
func fetch<T: Codable>(from urlString: String) async throws -> Data {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }

    // Create and configure the URL session
    let session = URLSession.shared

    // Make the network request and await the response
    let (data, response) = try await session.data(from: url)

    guard let data = data else {
        throw URLError(.badServerResponse)
    }

    // Verify we got a successful HTTP response
    guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
}
```

The success case is now the only code that is not nested in an `if` or `guard` statement. It's also at the very bottom of the function making it easy to find.

But for some reason, when we invoke this function, we think it's fine to just throw away all the benefits of the guard statement.

```swift
do {
    let data = try await networkManager.fetch(
        from: "https://jsonplaceholder.typicode.com/posts/1"
    )
    // success case in the middle somewhere and nested
} catch {
    print("Error fetching post: \(error)")
}
```

## Everything in One Do/Try/Catch Block ❌

Then this leads to putting a whole bunch of code in the `do` block.

```swift
try {
    let data = try await networkManager.fetch(
        from: "https://jsonplaceholder.typicode.com/posts/1"
    )

    // Decode the JSON data into our Codable type
    let decoder = JSONDecoder()
    let post = try decoder.decode(Post.self, from: data)

    try post.data.write(toFile: "path/to/newfile.txt", atomically: true, encoding: .utf8)

    print("Successfully fetched, decoded, and saved the post")
} catch (error) {
  // handle any errors, not sure which one though 🤷‍♀️
}

// or

catch let error as URLError {
    print("Network error: \(error.localizedDescription)")

} catch let error as DecodingError {
    print("JSON error: \(error.localizedDescription)")

} catch let error as CocoaError {
    print("File error: \(error.localizedDescription)")

} catch {
    print("Unexpected error: \(error)")
}
```

This is bad because:

1. All the success case code will happen inside of the do block. Nested somewhere in the middle of the function.
2. We handle the errors away from the code that causes the error and a sense of order is lost.

## Multiple Do/Try/Catch Blocks ❌

```ts
// First try-catch for network request
let data: Data
do {
    data = try await networkManager.fetch(
        from: "https://jsonplaceholder.typicode.com/posts/1"
    )
} catch let error as URLError {
    print("Network error: \(error.localizedDescription)")
    return // or throw, or handle error differently
} catch {
    print("Unexpected network error: \(error)")
    return
}

// Second try-catch for JSON decoding
let post: Post
do {
    let decoder = JSONDecoder()
    post = try decoder.decode(Post.self, from: data)
} catch let error as DecodingError {
    print("JSON decoding error: \(error.localizedDescription)")
    return
} catch {
    print("Unexpected decoding error: \(error)")
    return
}

// Third try-catch for file writing
do {
    try post.data.write(toFile: "path/to/newfile.txt", atomically: true, encoding: .utf8)
} catch let error as CocoaError {
    print("File writing error: \(error.localizedDescription)")
    return
} catch {
    print("Unexpected file error: \(error)")
    return
}

// If we get here, everything succeeded
print("Successfully fetched, decoded, and saved the post")
```

This might be a better way to handle errors, but no one's going to write three do catch blocks like this. And a catch isn't as good as a guard because it doesn't force you to handle the error and return early.

## The correct way

Guarding is good, and error handling should be handled in a guard right next to the code that causes the error. Success case code should go after guarding for errors.

We already know this, now let's do this with code that throws.

```swift
// First try-catch for network request
let (networkError, data) = await mightFail { try await networkManager.fetch(
    from: "https://jsonplaceholder.typicode.com/posts/1")
}
guard let data else {
    switch networkError {
    case URLError.badURL:
        print("Bad URL")
    default:
        print("Network error: \(networkError)")
    }
    return // or throw, or handle error differently
}

// Second try-catch for JSON decoding
let decoder = JSONDecoder()
let (decodingError, post) = await mightFail {
    try decoder.decode(Post.self, from: data)
}
guard let post else {
    switch decodingError {
    case DecodingError.keyNotFound:
        print("Key not found")
    default:
        print("Decoding error: \(decodingError)")
    }
    return
}

// Third try-catch for file writing
let (fileError, _, success) = await mightFail {
    try post.data.write(toFile: "path/to/newfile.txt", atomically: true, encoding: .utf8)
}
guard success else {
    switch fileError {
    case CocoaError.fileWriteNoPermission:
        print("No permission to write file")
    default:
        print("File writing error: \(fileError)")
    }
    return
}

// If we get here, everything succeeded
print("Successfully fetched, decoded, and saved the post")
```
