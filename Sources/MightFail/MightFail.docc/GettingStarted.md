# Getting Started with MightFail

Learn how to use MightFail in your Swift projects.

## Basic Usage

The core function of MightFail is the `mightFail(_:)` function. It takes a throwing function as its argument and returns a tuple containing the error (if any), the result (if successful), and a boolean indicating success.

```swift
let (error, result, success) = mightFail {
    try someThrowingFunction()
}

if success {
    print("Operation succeeded with result: \(result!)")
} else {
    print("Operation failed with error: \(error)")
}
```

## Async Operations

MightFail also supports async operations:

```swift
let (error, result, success) = await mightFail {
    try await someAsyncThrowingFunction()
}
```

## Multiple Operations

You can use MightFail with multiple operations:

```swift
let results = mightFail([
    { try operation1() },
    { try operation2() },
    { try operation3() }
])

for (error, result, success) in results {
    if success {
        print("Operation succeeded with result: \(result!)")
    } else {
        print("Operation failed with error: \(error)")
    }
}
```

## Async Multiple Operations

For async operations, you can use the async version of `mightFail(_:)` with an array of async throwing functions:

```swift
let results = await mightFail([
    { try await asyncOperation1() },
    { try await asyncOperation2() },
    { try await asyncOperation3() }
])

for (error, result, success) in results {
    if success {
        print("Async operation succeeded with result: \(result!)")
    } else {
        print("Async operation failed with error: \(error)")
    }
}
```

This setup allows you to handle multiple potentially failing operations, both synchronous and asynchronous, in a clean and consistent manner.
