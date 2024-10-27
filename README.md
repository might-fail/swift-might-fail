


```swift
do {
    try <#expression#>
    <#statements#>
} catch <#pattern 1#> {
    <#statements#>
} catch <#pattern 2#> where <#condition#> {
    <#statements#>
} catch <#pattern 3#>, <#pattern 4#> where <#condition#> {
    <#statements#>
} catch {
    <#statements#>
}
```


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
// Prints "Insufficient funds. Please insert an additional 2 coins."
```


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
    // Prints "Insufficient funds. Please insert an additional 2 coins."
    print("Success! Yum.")
  ```


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
    ```


```swift 
func returnStringOptional() throws -> String? {
  return nil
}
let (error, result, success) = mightFail {
  try returnStringOptional()
}
// success is true
// result is nil
// error is nil
// We can't guard on result since nil is a valid return value
// Error might be nil in this case, unlike the non optional case
```
