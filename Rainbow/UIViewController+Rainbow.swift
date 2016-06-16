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

    var rainbow_prefersNavigationBarBackgroundViewHidden: Bool? {

        get {
            return objc_getAssociatedObject(self, &AssociatedKey.backgroundViewHidden) as? Bool
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.backgroundViewHidden, newValue,  .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var rainbow_transitionNavigationBar: UINavigationBar? {

        get {
            return objc_getAssociatedObject(self, &AssociatedKey.transitionNavigationBar) as? UINavigationBar
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.transitionNavigationBar, newValue,  .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    override public static func initialize() {

        struct Static {
            static var token: dispatch_once_t = 0;
        }

        dispatch_once(&Static.token) {
            exchangeMethods(self, originalSelector: #selector(UIViewController.viewWillLayoutSubviews), swizzledSelector: #selector(UIViewController.rainbow_viewWillLayoutSubviews))
            exchangeMethods(self, originalSelector: #selector(UIViewController.viewDidAppear(_:)), swizzledSelector: #selector(UIViewController.rainbow_viewDidAppear(_:)))
        }
    }

    func rainbow_viewDidAppear(animated: Bool) {


        if let transitionNavigationBar = rainbow_transitionNavigationBar {
            navigationController?.navigationBar.barTintColor = rainbow_transitionNavigationBar?.barTintColor
            navigationController?.navigationBar.setBackgroundImage(transitionNavigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
            navigationController?.navigationBar.shadowImage = transitionNavigationBar.shadowImage
//            if let transitionViewController = navigationController?.
        }


//        if (self.km_transitionNavigationBar) {
//
//            self.navigationController.navigationBar.barTintColor = self.km_transitionNavigationBar.barTintColor;
//
//            [self.navigationController.navigationBar setBackgroundImage:[self.km_transitionNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
//
//            [self.navigationController.navigationBar setShadowImage:self.km_transitionNavigationBar.shadowImage];
//
//            UIViewController *transitionViewController = self.navigationController.km_transitionContextToViewController;
//            if (!transitionViewController || [transitionViewController isEqual:self]) {
//                [self.km_transitionNavigationBar removeFromSuperview];
//                self.km_transitionNavigationBar = nil;
//                self.navigationController.km_transitionContextToViewController = nil;
//            }
//        }
//        self.km_prefersNavigationBarBackgroundViewHidden = NO;
//        [self km_viewDidAppear:animated];


        self.rainbow_viewDidAppear(animated)

    }

    func rainbow_viewWillLayoutSubviews() {

        if let navigationController = navigationController, transitionCoordinator = transitionCoordinator(), fromViewController = transitionCoordinator.viewControllerForKey(UITransitionContextFromViewControllerKey),
            toViewController = transitionCoordinator.viewControllerForKey(UITransitionContextToViewControllerKey), lastViewController = navigationController.viewControllers.last where self == lastViewController && toViewController == self {

            if navigationController.navigationBar.translucent {
                transitionCoordinator.containerView().backgroundColor = navigationController.rainbow_containerViewBackgroundColor
            }

            fromViewController.view.clipsToBounds = false
            toViewController.view.clipsToBounds = false

            if rainbow_transitionNavigationBar == nil {
                rainbow_addTransitionNavigationBarIfNeeded()
                rainbow_prefersNavigationBarBackgroundViewHidden = true
            }

            rainbow_resizeTransitionNavigationBarFrame()
        }

        if let transitionNavigationBar = rainbow_transitionNavigationBar {
            view.bringSubviewToFront(transitionNavigationBar)
        }

        rainbow_viewWillLayoutSubviews()
    }


    func rainbow_resizeTransitionNavigationBarFrame() {

        guard let navigationController = navigationController where view.window != nil else { return }

        guard let backgroundView = navigationController.navigationBar.valueForKey("_backgroundView") as? UIView, rect = backgroundView.superview?.convertRect(backgroundView.frame, toView: view)  else { return }

        rainbow_transitionNavigationBar?.frame = rect
    }

    func rainbow_addTransitionNavigationBarIfNeeded() {

        guard let navigationController = navigationController where view.window != nil else { return }

        let bar = UINavigationBar()

        bar.barStyle = navigationController.navigationBar.barStyle

        if (bar.translucent != navigationController.navigationBar.translucent) {
            bar.translucent = navigationController.navigationBar.translucent
        }

        bar.barTintColor = navigationController.navigationBar.barTintColor
        bar.setBackgroundImage(navigationController.navigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
        bar.shadowImage = navigationController.navigationBar.shadowImage

        rainbow_transitionNavigationBar?.removeFromSuperview()
        rainbow_transitionNavigationBar = bar

        rainbow_resizeTransitionNavigationBarFrame()

        if !navigationController.navigationBar.hidden && !navigationController.navigationBarHidden {
            view.addSubview(bar)
        }
    }

}

final class WeakObjectWrapper<T: AnyObject> {
    weak var value: T?
    init(_ v: T) {
        value = v
    }
}

private func wrap<T: AnyObject>(v: T) -> WeakObjectWrapper<T> {
    return WeakObjectWrapper(v)
}

private func setAssociatedObject<T: AnyObject>(object: AnyObject, associativeKey: UnsafePointer<Void>, value: T, policy: objc_AssociationPolicy) {

    objc_setAssociatedObject(object, associativeKey, wrap(value),  policy)
}

private func getAssociatedObject<T: AnyObject>(object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
    return (objc_getAssociatedObject(object, associativeKey) as? WeakObjectWrapper<T>)?.value
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


