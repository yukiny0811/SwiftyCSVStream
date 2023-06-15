
import Foundation
import Algorithms
import CodableCSV

public protocol CodableWithHeader: Codable {
    static var headers: [String] { get }
}

public func loadCsv<T: CodableWithHeader>(filepath: String, type: T.Type, encoding: String.Encoding = .utf8) -> [T] {
    let fileURL = URL(string: "file://"+filepath)!
    let decoder = CSVDecoder {
        $0.headerStrategy = .firstLine
        $0.nilStrategy = .empty
        $0.dataStrategy = .base64
        $0.bufferingStrategy = .sequential
        $0.trimStrategy = .whitespaces
        $0.encoding = encoding
    }
    return try! decoder.decode([T].self, from: fileURL)
}

public func writeCsv<T: CodableWithHeader>(filepath: String, data: [T], encoding: String.Encoding = .utf8) {
    let fileURL = URL(string: "file://"+filepath)!
    let encoder = CSVEncoder {
        $0.headers = T.headers
        $0.encoding = encoding
    }
    try! encoder.encode(data, into: fileURL)
}

public typealias CSV = ReadableCSVStream

public class ReadableCSVStream<T: CodableWithHeader> {
    private var processedCsv: [T] = []
    public init() {}
    public func read(path: String, encoding: String.Encoding = .utf8) -> CSVStream<T> {
        return CSVStream<T>().read(path: path, encoding: encoding)
    }
}

public class CSVStream<T: CodableWithHeader> {
    private var processedCsv: [T]
    init(_ processedCsv: [T]) {
        self.processedCsv = processedCsv
    }
    convenience init() {
        self.init([])
    }
    func read(path: String, encoding: String.Encoding = .utf8) -> Self {
        processedCsv = loadCsv(filepath: path, type: T.self, encoding: encoding)
        return self
    }
    public func write(path: String, encoding: String.Encoding = .utf8) {
        writeCsv(filepath: path, data: processedCsv, encoding: encoding)
    }
    public func filter(_ f: (T) throws -> Bool) -> Self {
        processedCsv = try! processedCsv.filter(f)
        return self
    }
    public func chunked(by chunkFunc: (T, T) throws -> Bool) -> ChunkedCSVStream<T> {
        return ChunkedCSVStream<T>(
            try! processedCsv.chunked(by: chunkFunc).map { Array($0) }
        )
    }
}

public class ChunkedCSVStream<T: CodableWithHeader> {
    private var processedCsvChunks: [[T]] = []
    init(_ processedCsvChunks: [[T]]) {
        self.processedCsvChunks = processedCsvChunks
    }
    public var chunkCount: Int {
        processedCsvChunks.count
    }
    public func get(_ index: Int) -> CSVStream<T> {
        return CSVStream<T>(self.processedCsvChunks[index])
    }
    public func filter(where f: (T) throws -> Bool) -> ChunkedCSVStream<T> {
        return ChunkedCSVStream<T>(
            self.processedCsvChunks.filter { try! f($0[0]) }
        )
    }
    public func getFirst(where f: (T) throws -> Bool) -> CSVStream<T> {
        return CSVStream<T>(
            self.processedCsvChunks.first { try! f($0[0]) }!
        )
    }
    public func merged() -> CSVStream<T> {
        return CSVStream<T> (
            self.processedCsvChunks.reduce([], +)
        )
    }
}
