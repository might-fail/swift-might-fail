/// A utility for handling operations that might fail.
///
/// This package provides functions to execute throwing operations and handle their results
/// without using do-catch blocks. It simplifies error handling and makes it easier to work
/// with functions that might throw errors.
///
/// Example usage:
/// ```swift
/// func riskyOperation() throws -> String {
///     // Some operation that might throw an error
///     if someCondition {
///         throw SomeError.someCase
///     }
///     return "Success"
/// }
///
/// let (error, result, success) = mightFail {
///     try riskyOperation()
/// }
///
/// if success {
///     print("Operation succeeded with result: \(result!)")
/// } else {
///     print("Operation failed with error: \(error)")
/// }
/// ```
@usableFromInline final class NotAnError: Error, CustomStringConvertible {
    @usableFromInline static let shared = NotAnError()
    @usableFromInline let description = """
    This is not an error, always check the result value in a guard statement before checking the error value!
    let (error, result) = mightFail { try someFunc() }
    guard let result else {
      // handle error, for example
      switch error {
      }
      return 
    }
    // use the result
    """
    private init() {}
}
