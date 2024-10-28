
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