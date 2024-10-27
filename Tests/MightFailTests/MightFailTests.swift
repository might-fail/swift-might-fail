import Testing

@testable import MightFail

// MARK: - Test Errors
enum TestError: Error, Equatable {
  case simple
  case withMessage(String)
}

// MARK: - Test Suite
@Suite struct MightFailTests {

  // MARK: - Synchronous Tests

  @Test("Successful synchronous operation returns correct result")
  func testSuccessfulSync() throws {
    let (error, result, success) = mightFail {
      return "Success"
    }

    #expect(success)
    #expect(result == "Success")
    #expect(error is NotAnError)
  }

  @Test("Failed synchronous operation returns error")
  func testFailedSync() throws {
    let (error, _, success) = mightFail {
      throw TestError.simple
    }

    #expect(!success)
    #expect(error as? TestError == .simple)
  }

  @Test("Simplified successful synchronous operation returns correct result")
  func testSimplifiedSuccessSync() throws {
    func returnInt() throws -> Int {
      return 42
    }
    let (error, result) = mightFail {
      try returnInt()
    }

    #expect(result == 42)
    #expect(error is NotAnError)
  }

  @Test("Simplified failed synchronous operation returns error")
  func testSimplifiedFailureSync() throws {
    let (error, result): (error: any Error, result: Any?) = mightFail {
      throw TestError.withMessage("Failed operation")
    }

    #expect(result == nil)
    #expect(error as? TestError == .withMessage("Failed operation"))
  }

  @Test("Multiple synchronous operations handle mixed results")
  func testMultipleSync() throws {
    let results = mightFail([
      { 1 },
      { throw TestError.simple },
      { 3 },
    ])

    #expect(results.count == 3)

    // First operation
    #expect(results[0].success)
    #expect(results[0].result == 1)
    #expect(results[0].error is NotAnError)

    // Second operation
    #expect(!results[1].success)
    #expect(results[1].result == nil)
    #expect(results[1].error as? TestError == .simple)

    // Third operation
    #expect(results[2].success)
    #expect(results[2].result == 3)
    #expect(results[2].error is NotAnError)
  }

  @Test("Switching error type")
  func testSwitchingErrorType() throws {
    let favoriteSnacks = [
      "Alice": "Chips",
      "Bob": "Licorice",
      "Eve": "Pretzels",
    ]
    func buyFavoriteSnack(person: String, vendingMachine: VendingMachine) throws {
      let snackName = favoriteSnacks[person] ?? "Candy Bar"
      try vendingMachine.vend(itemNamed: snackName)
    }

    let vendingMachine = VendingMachine()
    vendingMachine.coinsDeposited = 8
    let (error, _, success) = mightFail {
      try buyFavoriteSnack(person: "Alice", vendingMachine: vendingMachine)
    }
    guard success else {
      switch error {
      case VendingMachineError.invalidSelection:
        #expect(Bool(false), "The error should be vending machine error")
      case VendingMachineError.outOfStock:
        #expect(Bool(false), "The error should be vending machine error")
      case VendingMachineError.insufficientFunds(_):
        #expect(Bool(true))
      default:
        #expect(Bool(false), "The error should be vending machine error")
      }
      return
    }
    #expect(Bool(false), "The error should have been handled")
  }

  // MARK: - Asynchronous Tests

  @Test("Successful asynchronous operation returns correct result")
  func testSuccessfulAsync() async throws {

    @Sendable func returnString() async throws -> String {
      try await Task.sleep(nanoseconds: 1_000_000)
      return "Async Success"
    }
    let (error, result, success) = await mightFail {
      try await returnString()
    }

    #expect(success)
    #expect(result == "Async Success")
    #expect(error is NotAnError)
  }

  @Test("Failed asynchronous operation returns error")
  func testFailedAsync() async throws {
    let (error, result, success): (error: any Error, result: Any?, success: Bool) = await mightFail
    {
      try await Task.sleep(nanoseconds: 1_000_000)
      throw TestError.withMessage("Async failure")
    }

    #expect(!success)
    #expect(result == nil)
    #expect(error as? TestError == .withMessage("Async failure"))
  }

  @Test("Simplified successful asynchronous operation returns correct result")
  func testSimplifiedSuccessAsync() async throws {
    let (error, result) = await mightFail {
      try await Task.sleep(nanoseconds: 1_000_000)
      return 42
    }

    #expect(result == 42)
    #expect(error is NotAnError)
  }

  @Test("Simplified failed asynchronous operation returns error")
  func testSimplifiedFailureAsync() async throws {
    let (error, result): (error: any Error, result: Any?) = await mightFail {
      try await Task.sleep(nanoseconds: 1_000_000)
      throw TestError.simple
    }

    #expect(result == nil)
    #expect(error as? TestError == .simple)
  }

  @Test("Multiple asynchronous operations handle mixed results")
  func testMultipleAsync() async throws {
    @Sendable func func1() async throws -> Int {
      try await Task.sleep(nanoseconds: 1_000_000)
      return 1
    }
    @Sendable func func2() async throws -> Int {
      try await Task.sleep(nanoseconds: 1_000_000)
      throw TestError.simple
    }
    @Sendable func func3() async throws -> Int {
      try await Task.sleep(nanoseconds: 1_000_000)
      return 3
    }

    let results = await mightFail([
      { @Sendable in try await func1() },
      { @Sendable in try await func2() },
      { @Sendable in try await func3() },
    ])

    #expect(results.count == 3)

    // First operation
    #expect(results[0].success)
    #expect(results[0].result == 1)
    #expect(results[0].error is NotAnError)

    // Second operation
    #expect(!results[1].success)
    #expect(results[1].result == nil)
    #expect(results[1].error as? TestError == .simple)

    // Third operation
    #expect(results[2].success)
    #expect(results[2].result == 3)
    #expect(results[2].error is NotAnError)
  }

  // MARK: - When value is optional

  @Test("Handling nil values")
  func testNilValues() throws {
    func returnStringOptional() throws -> String? {
      return nil
    }
    let (error, result, success) = mightFail {
      try returnStringOptional()
    }

    #expect(success)
    #expect(result == nil)
    #expect(error == nil)
  }

  @Test("Handling optional values")
  func testOptionalValues() throws {
    func returnStringOptional() throws -> String? {
      return "Hello"
    }
    let (error, result, success) = mightFail {
      try returnStringOptional()
    }

    #expect(success)
    #expect(result == "Hello")
    #expect(error == nil)
  }

  // Add these tests in the "Asynchronous Tests" section
  @Test("Handling async nil values")
  func testAsyncNilValues() async throws {
    @Sendable func returnStringOptional() async throws -> String? {
      return nil
    }
    let (error, result, success) = await mightFail {
      try await returnStringOptional()
    }

    #expect(success)
    #expect(result == nil)
    #expect(error == nil)
  }

  @Test("Handling async optional values")
  func testAsyncOptionalValues() async throws {
    @Sendable func returnStringOptional() async throws -> String? {
      return "Hello"
    }
    let (error, result, success) = await mightFail {
      try await returnStringOptional()
    }

    #expect(success)
    #expect(result == "Hello")
    #expect(error == nil)
  }

}
