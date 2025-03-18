# Getting Started 

A Swift library for handling async and sync errors without `try` and `catch` blocks.

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

* **Always** guard the success case. 
* **Never** check the error case.

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
guard success else {
    print(error)
    return
}

print(result) // "Success"
```

### Simplified Return Type

```swift
// Returns just (error, result)
let (error, result) = mightFail {
    return 42
}

guard let result else {
    print(error)
    return
}

print(result) // 42
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
for (index, (error, result, success)) in results.enumerated() {
    guard success else {
        print("Operation \(index + 1) failed with error: \(error)")
        continue
    }
    
    print("Operation \(index + 1) succeeded with result: \(result!)")
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

If you pass an optional value to mightFail, the first guard is for the error check, you'll need a second guard to see if you have a value.

```swift
func returnOptional() throws -> String? {
    return nil
}

let (error, result) = mightFail {
    try returnOptional()
}

// result is String??
guard let result else {
    // there was an error, handle it 
    print(error)
    return
}

guard let result else {
   // no error, but result is nil, handle it 
   print("No result")
   return
}

print(result) // "Success"
```