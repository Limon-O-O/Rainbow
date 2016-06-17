//
//  WeakObjectWrapper.swift
//  Rainy
//
//  Created by Limon on 6/17/16.
//  Copyright © 2016 Rainy. All rights reserved.
//

final class WeakObjectWrapper<T: AnyObject> {
    weak var value: T?
    init(_ v: T?) {
        value = v
    }
}