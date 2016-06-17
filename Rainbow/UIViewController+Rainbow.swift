//
//  UIViewController+Rainbow.swift
//  Rainy
//
//  Created by Limon on 6/16/16.
//  Copyright © 2016 Rainy. All rights reserved.
//

import Foundation


// MARK: Properties

extension UIViewController {

    private struct Rainbow_AssociatedKey {
        static var backgroundViewHidden: UInt8    = 0
        static var transitionNavigationBar: UInt8 = 0
    }

    var rainbow_prefersNavigationBarBackgroundViewHidden: Bool {

        get {
            return (objc_getAssociatedObject(self, &Rainbow_AssociatedKey.backgroundViewHidden) as? Bool) ?? false
        }

        set {

            (navigationController?.navigationBar.valueForKey("_backgroundView") as? UIView)?.hidden = newValue

            objc_setAssociatedObject(self, &Rainbow_AssociatedKey.backgroundViewHidden, newValue,  .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var rainbow_transitionNavigationBar: UINavigationBar? {

        get {
            return objc_getAssociatedObject(self, &Rainbow_AssociatedKey.transitionNavigationBar) as? UINavigationBar
        }

        set {
            objc_setAssociatedObject(self, &Rainbow_AssociatedKey.transitionNavigationBar, newValue,  .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


// MARK: Initializer

extension UIViewController {

    override public class func initialize() {

        struct Static {
            static var token: dispatch_once_t = 0;
        }

        dispatch_once(&Static.token) {
            exchangeMethods(self, originalSelector: #selector(UIViewController.viewWillLayoutSubviews), swizzledSelector: #selector(UIViewController.rainbow_viewWillLayoutSubviews))
            exchangeMethods(self, originalSelector: #selector(UIViewController.viewDidAppear(_:)), swizzledSelector: #selector(UIViewController.rainbow_viewDidAppear(_:)))
        }
    }
}


// MARK: Life Cycle Methods

extension UIViewController {

    func rainbow_viewDidAppear(animated: Bool) {

        if let transitionNavigationBar = rainbow_transitionNavigationBar, navigationController = navigationController {

            navigationController.navigationBar.barTintColor = rainbow_transitionNavigationBar?.barTintColor
            navigationController.navigationBar.setBackgroundImage(transitionNavigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
            navigationController.navigationBar.shadowImage = transitionNavigationBar.shadowImage

            if navigationController.rainbow_transitionContextToViewController == nil || navigationController.rainbow_transitionContextToViewController == .Some(self) {
                transitionNavigationBar.removeFromSuperview()
                rainbow_transitionNavigationBar = nil
                navigationController.rainbow_transitionContextToViewController = nil
            }

        }

        rainbow_prefersNavigationBarBackgroundViewHidden = false

        rainbow_viewDidAppear(animated)
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

}


// MARK: Hepler

extension UIViewController {

    func rainbow_resizeTransitionNavigationBarFrame() {

        guard let navigationController = navigationController where view.window != nil else { return }

        guard let backgroundView = navigationController.navigationBar.valueForKey("_backgroundView") as? UIView, rect = backgroundView.superview?.convertRect(backgroundView.frame, toView: view)  else { return }

        rainbow_transitionNavigationBar?.frame = rect
    }

    func rainbow_addTransitionNavigationBarIfNeeded() {

        guard let navigationController = navigationController where view.window != nil else { return }

        let navigationBar: UINavigationBar = {

            $0.barStyle = navigationController.navigationBar.barStyle

            if $0.translucent != navigationController.navigationBar.translucent {
                $0.translucent = navigationController.navigationBar.translucent
            }

            $0.barTintColor = navigationController.navigationBar.barTintColor
            $0.setBackgroundImage(navigationController.navigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
            $0.shadowImage = navigationController.navigationBar.shadowImage

            return $0
        }(UINavigationBar())

        rainbow_transitionNavigationBar?.removeFromSuperview()
        rainbow_transitionNavigationBar = navigationBar

        rainbow_resizeTransitionNavigationBarFrame()

        if !navigationController.navigationBar.hidden && !navigationController.navigationBarHidden {
            view.addSubview(navigationBar)
        }
    }
}
