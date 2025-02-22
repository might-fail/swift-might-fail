/// A utility for handling operations that might fail.
///
/// This package provides functions to execute throwing operations and handle their results
/// without using do-catch blocks. It simplifies error handling and makes it easier to work
/// with functions that might throw errors.
///
public typealias MaybeWithSuccess<T> = (error: Error, result: T?, success: Bool)

/// A utility for handling operations that might fail.
///
/// This package provides functions to execute throwing operations and handle their results
/// without using do-catch blocks. It simplifies error handling and makes it easier to work
/// with functions that might throw errors.
///
public typealias Maybe<T> = (error: Error, result: T?)


@inlinable
public func maybe<T>(result: T) -> MaybeWithSuccess<T> {
  return (error: NotAnError.shared, result: result, success: true)
}

@inlinable
public func maybe<T>(error: Error) -> MaybeWithSuccess<T> {
  return (error: error, result: nil, success: false)
}


@inlinable
public func maybe<T>(result: T) -> Maybe<T> {
  return (error: NotAnError.shared, result: result)
}

@inlinable
public func maybe<T>(error: Error) -> Maybe<T> {
  return (error: error, result: nil)
}
