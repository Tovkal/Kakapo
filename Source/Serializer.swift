//
//  Serializer.swift
//  KakapoExample
//
//  Created by Alex Manzella on 31/03/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import Foundation

public protocol PropertyPolicy: CustomReflectable {
    var shouldSerialize: Bool { get }
}

struct KakapoIgnorableNilProperty<T>: PropertyPolicy {
    let obj: T?
    
    var shouldSerialize: Bool {
        return obj != nil
    }
    
    func customMirror() -> Mirror {
        return Mirror(reflecting: obj)
    }
}

protocol KakapoSerializable {
    func serializeChildren() -> Any
}

extension KakapoSerializable {
    func serializeChildren() -> Any {
        return serialize(self)
    }
}

extension Array: KakapoSerializable {
    func serializeChildren() -> Any {
        var array = [Any]()
        for obj in self {
            array.append(serializeObject(obj))
        }
        return array
    }
}
extension Dictionary: KakapoSerializable {
    func serializeChildren() -> Any {
        var dictionary = [Key: Any]()
        for (key, value) in self {
            dictionary[key] = serializeObject(value)
        }
        return dictionary
    }
}

func serializeObject(value: Any) -> Any {
    if let value = value as? KakapoSerializable {
        return value.serializeChildren()
    } else {
        assert(value is AnyObject) // TODO: throw
        return value
    }
}

func serialize(object: KakapoSerializable) -> [String: Any] {
    var dictionary = [String: Any]()
    let mirror = Mirror(reflecting: object)
    for child in mirror.children {
        if let label = child.label {
            if let value = child.value as? PropertyPolicy {
                if value.shouldSerialize {
                    dictionary[label] = serializeObject(value)
                }
            } else {
                dictionary[label] = serializeObject(child.value)
            }
        }
    }
    
    return dictionary
}
