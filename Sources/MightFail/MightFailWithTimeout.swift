// import Foundation

// public struct TimeoutError: Error {
//   public static let shared: TimeoutError = .init()
// }

// // public func mightFail<T>(
// //  isolation: isolated (any Actor)? = #isolation,
// //  withTimeout seconds: TimeInterval,
// //  body: () async throws -> sending T
// // ) async throws -> sending T {
// //  try await _withThrowingTimeout(isolation: isolation, body: body) {
// //    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
// //    throw TimeoutError("Task timed out before completion. Timeout: \(seconds) seconds.")
// //  }.value
// // }

// @available(iOS 13.0.0, macOS 10.15, *)
// @inlinable
// public func mightFail<T>(
//   isolation: isolated (any Actor)? = #isolation,
//   withTimeout seconds: TimeInterval,
//   _ throwingFunction: @Sendable () async throws -> sending T
// ) async -> sending MaybeWithSuccess<T> {
//   @Sendable func timeout() async throws -> Never {
//     try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
//     throw TimeoutError.shared
//   }
//   let result: MaybeWithSuccess<T> = await mightFail {
//     try await withoutActuallyEscaping(throwingFunction) { throwingFunction in
//       return try await withThrowingTaskGroup(of: T.self) { group in
//         // Add both tasks
//         group.addTask { try await throwingFunction() }
//         group.addTask { try await timeout() }

//         // Get just the first result
//         let firstResult = try await group.next()

//         // Cancel remaining task
//         group.cancelAll()

//         guard let result = result as? T else {
//           throw TimeoutError.shared
//         }

//         return result
//       }
//     }
//   }

//   return result
// }

// // @available(iOS 13.0.0, macOS 10.15, *)
// // @inlinable
// // public func mightFail<T>(
// //  isolation: isolated (any Actor)? = #isolation,
// //  withTimeout seconds: TimeInterval,
// //  _ throwingFunction: @Sendable () async throws -> T
// // ) async -> Maybe<T> {
// //  let (error, result, _) = await mightFail(throwingFunction)
// //  return (error, result)
// // }

// // @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
// // public func withThrowingTimeout<T, C: Clock>(
// //  isolation: isolated (any Actor)? = #isolation,
// //  after instant: C.Instant,
// //  tolerance: C.Instant.Duration? = nil,
// //  clock: C,
// //  body: () async throws -> sending T
// // ) async throws -> sending T {
// //  try await _withThrowingTimeout(isolation: isolation, body: body) {
// //    try await Task.sleep(until: instant, tolerance: tolerance, clock: clock)
// //    throw TimeoutError("Task timed out before completion. Deadline: \(instant).")
// //  }.value
// // }

// // @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
// // public func withThrowingTimeout<T>(
// //  isolation: isolated (any Actor)? = #isolation,
// //  after instant: ContinuousClock.Instant,
// //  tolerance: ContinuousClock.Instant.Duration? = nil,
// //  body: () async throws -> sending T
// // ) async throws -> sending T {
// //  try await _withThrowingTimeout(isolation: isolation, body: body) {
// //    try await Task.sleep(until: instant, tolerance: tolerance, clock: ContinuousClock())
// //    throw TimeoutError("Task timed out before completion. Deadline: \(instant).")
// //  }.value
// // }

// // private func _withThrowingTimeout<T>(
// //  isolation: isolated (any Actor)? = #isolation,
// //  throwingFunction: @Sendable () async throws -> T,
// //  timeout: @Sendable () async throws -> Never
// // ) async throws -> Transferring<T> {
// //  try await withoutActuallyEscaping(body) { escapingBody in
// //    let bodyTask = Task {
// //      defer { _ = isolation }
// //      return try await Transferring(escapingBody())
// //    }
// //    let timeoutTask = Task {
// //      defer { bodyTask.cancel() }
// //      try await timeout()
// //    }

// //    let bodyResult = await withTaskCancellationHandler {
// //      await bodyTask.result
// //    } onCancel: {
// //      bodyTask.cancel()
// //    }
// //    timeoutTask.cancel()

// //    if case .failure(let timeoutError) = await timeoutTask.result,
// //       timeoutError is TimeoutError
// //    {
// //      throw timeoutError
// //    } else {
// //      return try bodyResult.get()
// //    }
// //  }
// // }

// // private struct Transferring<Value>: Sendable {
// //  public nonisolated(unsafe) var value: Value
// //  init(_ value: Value) {
// //    self.value = value
// //  }
// // }
