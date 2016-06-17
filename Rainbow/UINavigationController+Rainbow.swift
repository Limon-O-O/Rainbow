//
//  UINavigationController+Rainbow.swift
//  Rainy
//
//  Created by Limon on 2016/6/16.
//  Copyright © 2016年 Rainy. All rights reserved.
//

import Foundation

// MARK: Properties

extension UINavigationController {

    private struct Rainbow_AssociatedKey {
        static var transitionContextToViewController: UInt8 = 0
    }

    var rainbow_transitionContextToViewController: UIViewController? {

        get {
            return getAssociatedObject(self, associativeKey: &Rainbow_AssociatedKey.transitionContextToViewController)
        }

        set {
            setAssociatedObject(self, associativeKey: &Rainbow_AssociatedKey.transitionContextToViewController, value: newValue,  policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// By default this is white, it is related to issue with transparent navigationBar
    public var rainbow_containerViewBackgroundColor: UIColor {
        return UIColor.whiteColor()
    }
}


// MARK: Initializer

extension UINavigationController {

    override public class func initialize() {

        struct Static {
            static var token: dispatch_once_t = 0;
        }

        dispatch_once(&Static.token) {

            exchangeMethods(self, originalSelector: #selector(UINavigationController.pushViewController(_:animated:)), swizzledSelector: #selector(UINavigationController.rainbow_pushViewController(_:animated:)))

            exchangeMethods(self, originalSelector: #selector(UINavigationController.popViewControllerAnimated(_:)), swizzledSelector: #selector(UINavigationController.rainbow_popViewControllerAnimated(_:)))

            exchangeMethods(self, originalSelector: #selector(UINavigationController.popToViewController(_:animated:)), swizzledSelector: #selector(UINavigationController.rainbow_popToViewController(_:animated:)))

            exchangeMethods(self, originalSelector: #selector(UINavigationController.popToRootViewControllerAnimated(_:)), swizzledSelector: #selector(UINavigationController.rainbow_popToRootViewControllerAnimated(_:)))
        }

    }
}


// MARK: Life Cycle Methods

extension UINavigationController {

    func rainbow_pushViewController(viewController: UIViewController, animated: Bool) {

        let disappearingViewController = viewControllers.last

        if disappearingViewController == nil {
            return rainbow_pushViewController(viewController, animated: animated)
        }

        if rainbow_transitionContextToViewController == nil || disappearingViewController!.rainbow_transitionNavigationBar == nil {
            disappearingViewController?.rainbow_addTransitionNavigationBarIfNeeded()
        }

        if animated {
            rainbow_transitionContextToViewController = viewController
            disappearingViewController?.rainbow_prefersNavigationBarBackgroundViewHidden = true
        }

        return rainbow_pushViewController(viewController, animated: animated)
    }

    func rainbow_popViewControllerAnimated(animated: Bool) -> UIViewController? {

        if viewControllers.count < 2 {
            return rainbow_popViewControllerAnimated(animated)
        }

        let disappearingViewController = viewControllers.last
        disappearingViewController?.rainbow_addTransitionNavigationBarIfNeeded()

        let appearingViewController = viewControllers[viewControllers.count - 2]

        if let appearingNavigationBar = appearingViewController.rainbow_transitionNavigationBar {
            navigationBar.barTintColor = appearingNavigationBar.barTintColor
            navigationBar.setBackgroundImage(appearingNavigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
            navigationBar.shadowImage = appearingNavigationBar.shadowImage
        }

        if animated {
            disappearingViewController?.rainbow_prefersNavigationBarBackgroundViewHidden = true
        }

        return rainbow_popViewControllerAnimated(animated)
    }

    func rainbow_popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]? {

        if !viewControllers.contains(viewController) || viewControllers.count < 2 {
            return rainbow_popToViewController(viewController, animated: animated)
        }

        let disappearingViewController = viewControllers.last
        disappearingViewController?.rainbow_addTransitionNavigationBarIfNeeded()

        if let appearingNavigationBar = viewController.rainbow_transitionNavigationBar {
            navigationBar.barTintColor = appearingNavigationBar.barTintColor
            navigationBar.setBackgroundImage(appearingNavigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
            navigationBar.shadowImage = appearingNavigationBar.shadowImage
        }

        if animated {
            disappearingViewController?.rainbow_prefersNavigationBarBackgroundViewHidden = true
        }

        return rainbow_popToViewController(viewController, animated: animated)
    }

    func rainbow_popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {

        if self.viewControllers.count < 2 {
            return rainbow_popToRootViewControllerAnimated(animated)
        }

        let disappearingViewController = viewControllers.last
        disappearingViewController?.rainbow_addTransitionNavigationBarIfNeeded()

        let rootViewController = viewControllers.first!

        if let appearingNavigationBar = rootViewController.rainbow_transitionNavigationBar {
            navigationBar.barTintColor = appearingNavigationBar.barTintColor
            navigationBar.setBackgroundImage(appearingNavigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
            navigationBar.shadowImage = appearingNavigationBar.shadowImage
        }

        if animated {
            disappearingViewController?.rainbow_prefersNavigationBarBackgroundViewHidden = true
        }

        return rainbow_popToRootViewControllerAnimated(animated)
    }

}

