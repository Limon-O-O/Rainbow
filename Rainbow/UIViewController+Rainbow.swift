//
//  UIViewController+Rainbow.swift
//  Rainy
//
//  Created by Limon on 6/16/16.
//  Copyright © 2016 Rainy. All rights reserved.
//

import Foundation

extension UIViewController {

    private struct AssociatedKey {
        static var backgroundViewHidden: UInt8    = 0
        static var transitionNavigationBar: UInt8 = 0
    }

    var rabinbow_prefersNavigationBarBackgroundViewHidden: Bool? {

        get {
            return getAssociatedObject(self, associativeKey: &AssociatedKey.backgroundViewHidden)
        }

        set {
            if let value = newValue {
                setAssociatedObject(self, value: value, associativeKey: &AssociatedKey.backgroundViewHidden, policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    var rabinbow_transitionNavigationBar: UINavigationBar? {

        get {
            return getAssociatedObject(self, associativeKey: &AssociatedKey.transitionNavigationBar)
        }

        set {
            if let value = newValue {
                setAssociatedObject(self, value: value, associativeKey: &AssociatedKey.transitionNavigationBar, policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    override public static func initialize() {

        struct Static {
            static var token: dispatch_once_t = 0;
        }

        dispatch_once(&Static.token) {
            exchangeMethods(self, originalSelector: #selector(UIViewController.viewWillLayoutSubviews), swizzledSelector: #selector(UIViewController.rabinbow_viewWillLayoutSubviews))
            exchangeMethods(self, originalSelector: #selector(UIViewController.viewDidAppear(_:)), swizzledSelector: #selector(UIViewController.rabinbow_viewDidAppear(_:)))
        }
    }

    func rabinbow_viewDidAppear(animated: Bool) {
        self.rabinbow_viewDidAppear(animated)

    }

    func rabinbow_viewWillLayoutSubviews() {


        guard let navigationController = navigationController, transitionCoordinator = transitionCoordinator() else { return }

        guard let fromViewController = transitionCoordinator.viewControllerForKey(UITransitionContextFromViewControllerKey),
                    toViewController = transitionCoordinator.viewControllerForKey(UITransitionContextToViewControllerKey) else { return }

        guard let lastViewController = navigationController.viewControllers.last where self == lastViewController && toViewController == self else { return }


        if navigationController.navigationBar.translucent {
//            transitionCoordinator.containerView().backgroundColor = navigationController
        }

//        if ([self isEqual:self.navigationController.viewControllers.lastObject] && [toViewController isEqual:self]) {
//
//            if (self.navigationController.navigationBar.translucent) {
//                [tc containerView].backgroundColor = [self.navigationController km_containerViewBackgroundColor];
//            }
//            fromViewController.view.clipsToBounds = NO;
//            toViewController.view.clipsToBounds = NO;
//            if (!self.km_transitionNavigationBar) {
//                [self km_addTransitionNavigationBarIfNeeded];
//
//                self.km_prefersNavigationBarBackgroundViewHidden = YES;
//            }
//            [self km_resizeTransitionNavigationBarFrame];
//        }
//        if (self.km_transitionNavigationBar) {
//            [self.view bringSubviewToFront:self.km_transitionNavigationBar];
//        }
//        [self km_viewWillLayoutSubviews];



        rabinbow_viewWillLayoutSubviews()

    }


    func rabinbow_resizeTransitionNavigationBarFrame() {

        guard let navigationController = navigationController where view.window != nil else { return }

        guard let backgroundView = navigationController.navigationBar.valueForKey("_backgroundView") as? UIView, rect = backgroundView.superview?.convertRect(backgroundView.frame, toView: view)  else { return }

        rabinbow_transitionNavigationBar?.frame = rect
    }

    func rabinbow_addTransitionNavigationBarIfNeeded() {

        guard let navigationController = navigationController where view.window != nil else { return }

        let bar = UINavigationBar()

        bar.barStyle = navigationController.navigationBar.barStyle

        if (bar.translucent != navigationController.navigationBar.translucent) {
            bar.translucent = navigationController.navigationBar.translucent
        }

        bar.barTintColor = navigationController.navigationBar.barTintColor
        bar.setBackgroundImage(navigationController.navigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
        bar.shadowImage = navigationController.navigationBar.shadowImage

        rabinbow_transitionNavigationBar?.removeFromSuperview()
        rabinbow_transitionNavigationBar = bar

        rabinbow_resizeTransitionNavigationBarFrame()

        if !navigationController.navigationBar.hidden && !navigationController.navigationBarHidden {
            view.addSubview(bar)
        }
    }

}

final class Lifted<T> {
    let value: T
    init(_ x: T) {
        value = x
    }
}

private func lift<T>(x: T) -> Lifted<T>  {
    return Lifted(x)
}

private func setAssociatedObject<T>(object: AnyObject, value: T, associativeKey: UnsafePointer<Void>, policy: objc_AssociationPolicy) {
    if let v: AnyObject = value as? AnyObject {
        objc_setAssociatedObject(object, associativeKey, v,  policy)
    }
    else {
        objc_setAssociatedObject(object, associativeKey, lift(value),  policy)
    }
}

private func getAssociatedObject<T>(object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
    if let v = objc_getAssociatedObject(object, associativeKey) as? T {
        return v
    }
    else if let v = objc_getAssociatedObject(object, associativeKey) as? Lifted<T> {
        return v.value
    }
    else {
        return nil
    }
}


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


