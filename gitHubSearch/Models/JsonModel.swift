//
//  JsonModel.swift
//  gitHubSearch
//
//  Created by Zahidul Islam on 2022/08/30.
//

import Foundation

protocol JSONDecodable {
    init(JSON: JSONObject) throws
}

//object for getting some type of value from a JSON
enum JSONDecodeError: Error, CustomDebugStringConvertible {
    case missingRequiredKey(String)
    case unexpectedType(key: String, expected: Any.Type, actual: Any.Type)
    case unexpectedValue(key: String, value: Any, message: String?)
    
    var debugDescription: String {
        switch self {
        case .missingRequiredKey(let key):
            return "JSON Decode Error: Required key '\(key)' missing"
        case let .unexpectedType(key: key, expected: expected, actual: actual):
            return "JSON Decode Error: Unexpected type '\(actual)' was supplied for '\(key): \(expected)'"
        case let .unexpectedValue(key: key, value: value, message: message):
            return "JSON Decode Error: \(message ?? "Unexpected value") '\(value)' was supplied for '\(key)'"
        }
    }
}

//convert JSON value
protocol JSONValueConverter {
    associatedtype FromType
    associatedtype ToType
    
    func convert(key: String, value: FromType) throws -> ToType
}


struct DefaultConverter<T>: JSONValueConverter {
    typealias FromType = T
    typealias ToType = T
    
    func convert(key: String, value: FromType) -> DefaultConverter.ToType {
        return value
    }
}

//Convert a JSON object to some JSONDecodable type
struct ObjectConverter<T: JSONDecodable>: JSONValueConverter {
    typealias FromType = [String: AnyObject]
    typealias ToType = T
    
    func convert(key: String, value: FromType) throws -> ObjectConverter.ToType {
        return try T(JSON: JSONObject(JSON: value))
    }
}


struct ArrayConverter<T: JSONDecodable>: JSONValueConverter {
    typealias FromType = [[String: AnyObject]]
    typealias ToType = [T]
    
    func convert(key: String, value: FromType) throws -> ArrayConverter.ToType {
        return try value.map(JSONObject.init).map(T.init)
    }
}

//JSON primitive value
protocol JSONPrimitive {}

extension String: JSONPrimitive {}
extension Int: JSONPrimitive {}
extension Double: JSONPrimitive {}
extension Bool: JSONPrimitive {}


protocol JSONConvertible {
    associatedtype ConverterType: JSONValueConverter
    static var converter: ConverterType { get }
}


struct JSONObject {
    
    // A Dictionary of the original JSON objects
    let JSON: [String: AnyObject]
    
    init(JSON: [String: AnyObject]) {
        self.JSON = JSON
    }
    
    func get<Converter: JSONValueConverter>(_ key: String, converter: Converter) throws -> Converter.ToType {
        guard let value = JSON[key] else {
            throw JSONDecodeError.missingRequiredKey(key)
        }
        guard let typedValue = value as? Converter.FromType else {
            throw JSONDecodeError.unexpectedType(key: key, expected: Converter.FromType.self, actual: type(of: value))
        }
        return try converter.convert(key: key, value: typedValue)
    }
    
    func get<Converter: JSONValueConverter>(_ key: String, converter: Converter) throws -> Converter.ToType? {
        guard let value = JSON[key] else {
            return nil
        }
        if value is NSNull {
            return nil
        }
        guard let typedValue = value as? Converter.FromType else {
            throw JSONDecodeError.unexpectedType(key: key, expected: Converter.FromType.self, actual: type(of: value))
        }
        return try converter.convert(key: key, value: typedValue)
    }
    
    func get<T: JSONPrimitive>(_ key: String) throws -> T {
        return try get(key, converter: DefaultConverter())
    }
    
    func get<T: JSONPrimitive>(_ key: String) throws -> T? {
        return try get(key, converter: DefaultConverter())
    }
    
    func get<T: JSONConvertible>(_ key: String) throws -> T where T == T.ConverterType.ToType {
        return try get(key, converter: T.converter)
    }
    
    func get<T: JSONConvertible>(_ key: String) throws -> T? where T == T.ConverterType.ToType {
        return try get(key, converter: T.converter)
    }
    
    func get<T: JSONDecodable>(_ key: String) throws -> T {
        return try get(key, converter: ObjectConverter())
    }
    
    func get<T: JSONDecodable>(_ key: String) throws -> T? {
        return try get(key, converter: ObjectConverter())
    }
    
    func get<T: JSONDecodable>(_ key: String) throws -> [T] {
        return try get(key, converter: ArrayConverter())
    }
    
    func get<T: JSONDecodable>(_ key: String) throws -> [T]? {
        return try get(key, converter: ArrayConverter())
    }
    
}


extension URL: JSONConvertible {
    typealias ConverterType = URLConverter
    static var converter: ConverterType {
        return URLConverter()
    }
}

extension Date: JSONConvertible {
    typealias ConverterType = DateConverter
    static var converter: ConverterType {
        return DateConverter()
    }
}

// create NSURL and NSDate
struct URLConverter: JSONValueConverter {
    typealias FromType = String
    typealias ToType = URL
    
    func convert(key: String, value: FromType) throws -> URLConverter.ToType {
        guard let URL = URL(string: value) else {
            throw JSONDecodeError.unexpectedValue(key: key, value: value, message: "Invalid URL")
        }
        return URL
    }
}

struct DateConverter: JSONValueConverter {
    typealias FromType = TimeInterval
    typealias ToType = Date
    
    func convert(key: String, value: FromType) -> DateConverter.ToType {
        return Date(timeIntervalSince1970: value)
    }
}

