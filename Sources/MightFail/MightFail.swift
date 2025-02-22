
/// Executes a throwing function and returns a tuple containing the error (if any), the result (if successful), and a boolean indicating success.
///
/// This function allows you to handle potentially throwing operations without using do-catch blocks.
///
/// - Parameter throwingFunction: A function that might throw an error.
/// - Returns: A tuple containing the error (if any), the result (if successful), and a boolean indicating success.
///
/// Example usage:
/// ```swift
/// func fetchData() throws -> Data {
///     // Simulating a network request that might fail
///     if Bool.random() {
///         throw NSError(domain: "NetworkError", code: 404, userInfo: nil)
///     }
///     return Data()
/// }
///
/// let (error, data, success) = mightFail {
///     try fetchData()
/// }
///
/// if success {
///     print("Data fetched successfully: \(data!)")
/// } else {
///     print("Failed to fetch data. Error: \(error)")
/// }
/// ```
@inlinable
public func mightFail<T>(_ throwingFunction: () throws -> T) -> MaybeWithSuccess<T> {
    do {
        let value = try throwingFunction()
        return maybe(result: value)
    } catch {
        return maybe(error: error)
    }
}

@inlinable
public func mightFail<T>(_ throwingFunction: () throws -> T?) -> (error: Error?, result: T?, success: Bool) {
    do {
        let value = try throwingFunction()
        return (error: nil, result: value, success: true)
    } catch {
        return (error: error, result: nil, success: false)
    }
}

/// Executes a throwing function and returns a tuple containing the error (if any) and the result (if successful).
///
/// This is a simplified version of the `mightFail` function that doesn't include the success boolean.
///
/// - Parameter throwingFunction: A function that might throw an error.
/// - Returns: A tuple containing the error (if any) and the result (if successful).
///
/// Example usage:
/// ```swift
/// func divide(_ a: Int, by b: Int) throws -> Int {
///     guard b != 0 else { throw DivisionError.divideByZero }
///     return a / b
/// }
///
/// let (error, result) = mightFail {
///     try divide(10, by: 2)
/// }
///
/// if let result = result {
///     print("Division result: \(result)")
/// } else {
///     print("Division failed. Error: \(error)")
/// }
/// ```
@inlinable
public func mightFail<T>(_ throwingFunction: () throws -> T) -> Maybe<T> {
    let (error, result, _) = mightFail(throwingFunction)
    return (error, result)
}

// MARK: - All Settled

/// Executes multiple throwing functions and returns an array of results.
///
/// This function allows you to execute multiple operations that might throw errors and collect all their results,
/// regardless of whether they succeeded or failed.
///
/// - Parameter throwingFunctions: An array of functions that might throw errors.
/// - Returns: An array of tuples, each containing the error (if any), the result (if successful), and a boolean indicating success for each function.
///
/// Example usage:
/// ```swift
/// func operation1() throws -> Int { return 1 }
/// func operation2() throws -> Int { throw NSError(domain: "TestError", code: 1, userInfo: nil) }
/// func operation3() throws -> Int { return 3 }
///
/// let results = mightFail([
///     { try operation1() },
///     { try operation2() },
///     { try operation3() }
/// ])
///
/// for (index, (error, result, success)) in results.enumerated() {
///     if success {
///         print("Operation \(index + 1) succeeded with result: \(result!)")
///     } else {
///         print("Operation \(index + 1) failed with error: \(error)")
///     }
/// }
/// ```
@inlinable
public func mightFail<T>(_ throwingFunctions: [() throws -> T]) -> [MaybeWithSuccess<T>] {
    var results: [MaybeWithSuccess<T>] = []
    for throwingFunction in throwingFunctions {
        let (error, result, success) = mightFail(throwingFunction)
        results.append((error, result, success))
    }
    return results
}

// MARK: - Async

/// Executes an async throwing function and returns a tuple containing the error (if any), the result (if successful), and a boolean indicating success.
///
/// This function is the asynchronous version of `mightFail`, allowing you to handle potentially throwing async operations.
///
/// - Parameter throwingFunction: An async function that might throw an error.
/// - Returns: A tuple containing the error (if any), the result (if successful), and a boolean indicating success.
///
/// Example usage:
/// ```swift
/// func fetchUserData(id: Int) async throws -> User {
///     // Simulating an async network request that might fail
///     try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
///     if id % 2 == 0 {
///         return User(id: id, name: "User \(id)")
///     } else {
///         throw NSError(domain: "UserFetchError", code: 404, userInfo: nil)
///     }
/// }
///
/// let (error, user, success) = await mightFail {
///     try await fetchUserData(id: 1)
/// }
///
/// if success {
///     print("User fetched successfully: \(user!)")
/// } else {
///     print("Failed to fetch user. Error: \(error)")
/// }
/// ```
@available(iOS 13.0.0, macOS 10.15, *)
@inlinable
public func mightFail<T>(_ throwingFunction: @Sendable () async throws -> T) async -> MaybeWithSuccess<T> {
    do {
        let value = try await throwingFunction()
        return maybe(result: value)
    } catch {
        return maybe(error: error)
    }
}

/// Executes an async throwing function and returns a tuple containing the error (if any) and the result (if successful).
///
/// This is a simplified version of the async `mightFail` function that doesn't include the success boolean.
///
/// - Parameter throwingFunction: An async function that might throw an error.
/// - Returns: A tuple containing the error (if any) and the result (if successful).
///
/// Example usage:
/// ```swift
/// func processData() async throws -> ProcessedData {
///     // Some async processing that might throw an error
///     try await Task.sleep(nanoseconds: 500_000_000) // Sleep for 0.5 seconds
///     if Bool.random() {
///         throw ProcessingError.invalidData
///     }
///     return ProcessedData()
/// }
///
/// let (error, data) = await mightFail {
///     try await processData()
/// }
///
/// if let data = data {
///     print("Data processed successfully: \(data)")
/// } else {
///     print("Data processing failed. Error: \(error)")
/// }
/// ```
@available(iOS 13.0.0, macOS 10.15, *)
@inlinable
public func mightFail<T>(_ throwingFunction: @Sendable () async throws -> T) async -> Maybe<T> {
    let (error, result, _) = await mightFail(throwingFunction)
    return (error, result)
}

// MARK: - Async All Settled

/// Executes multiple async throwing functions and returns an array of results.
///
/// This function allows you to execute multiple asynchronous operations that might throw errors and collect all their results,
/// regardless of whether they succeeded or failed.
///
/// - Parameter throwingFunctions: An array of async functions that might throw errors.
/// - Returns: An array of tuples, each containing the error (if any), the result (if successful), and a boolean indicating success for each function.
///
/// Example usage:
/// ```swift
/// func asyncOperation1() async throws -> Int { return 1 }
/// func asyncOperation2() async throws -> Int { throw NSError(domain: "TestError", code: 2, userInfo: nil) }
/// func asyncOperation3() async throws -> Int { return 3 }
///
/// let results = await mightFail([
///     { try await asyncOperation1() },
///     { try await asyncOperation2() },
///     { try await asyncOperation3() }
/// ])
///
/// for (index, (error, result, success)) in results.enumerated() {
///     if success {
///         print("Async operation \(index + 1) succeeded with result: \(result!)")
///     } else {
///         print("Async operation \(index + 1) failed with error: \(error)")
///     }
/// }
/// ```
@available(iOS 13.0.0, macOS 10.15, *)
@inlinable
public func mightFail<T>(_ throwingFunctions: [@Sendable () async throws -> T]) async -> [MaybeWithSuccess<T>] {
    var results: [MaybeWithSuccess<T>] = []
    for throwingFunction in throwingFunctions {
        let (error, result, success) = await mightFail(throwingFunction)
        results.append((error, result, success))
    }
    return results
}

/// Executes an async throwing function that returns an optional value and returns a tuple containing the error (if any), 
/// the result (if successful), and a boolean indicating success.
///
/// This function is the asynchronous version of `mightFail` for optional return types, allowing you to handle 
/// potentially throwing async operations that may return nil.
///
/// - Parameter throwingFunction: An async function that might throw an error and returns an optional value.
/// - Returns: A tuple containing the error (if any), the result (if successful), and a boolean indicating success.
///
/// Example:
/// ```swift
/// func fetchUserProfile(id: Int) async throws -> UserProfile? {
///     try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
///     if id < 0 {
///         throw FetchError.invalidId
///     }
///     return id == 0 ? nil : UserProfile(id: id, name: "User \(id)")
/// }
///
/// let (error, profile, success) = await mightFail {
///     try await fetchUserProfile(id: 1)
/// }
///
/// if success {
///     if let profile = profile {
///         print("Profile fetched successfully: \(profile)")
///     } else {
///         print("No profile found")
///     }
/// } else {
///     print("Failed to fetch profile. Error: \(error)")
/// }
/// }
/// ```
@available(iOS 13.0.0, macOS 10.15, *)
@inlinable
public func mightFail<T>(_ throwingFunction: @Sendable () async throws -> T?) async -> (error: Error?, result: T?, success: Bool) {
    do {
        let value = try await throwingFunction()
        return (error: nil, result: value, success: true)
    } catch {
        return (error: error, result: nil, success: false)
    }
}
