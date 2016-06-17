//
//  Utilities.swift
//  Rainy
//
//  Created by Limon on 6/17/16.
//  Copyright © 2016 Rainy. All rights reserved.
//

func exchangeMethods(classType: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {

    let originalMethod = class_getInstanceMethod(classType, originalSelector)
    let swizzledMethod = class_getInstanceMethod(classType, swizzledSelector)

    let didAddMethod = class_addMethod(classType, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

    if didAddMethod {

        class_replaceMethod(classType, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))

    } else {

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

}

func setAssociatedObject<T: AnyObject>(object: AnyObject, associativeKey: UnsafePointer<Void>, value: T?, policy: objc_AssociationPolicy) {
    objc_setAssociatedObject(object, associativeKey, WeakObjectWrapper(value),  policy)
}

func getAssociatedObject<T: AnyObject>(object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
    return (objc_getAssociatedObject(object, associativeKey) as? WeakObjectWrapper<T>)?.value
}

