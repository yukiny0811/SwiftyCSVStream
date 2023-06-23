# SwiftyCSVStream

## How to use
```.swift
struct MyDataStructure: CodableWithHeader {
    static let headers = ["name", "age", "title"]
    var name: String
    var age: Int
    var title: String
}

CSV<MyDataStructure>()
    .read(path: "path-to-your-csv")
    .filter { $0.age >= 25 }
    .write(path: "path-to-your-new-csv")
```
