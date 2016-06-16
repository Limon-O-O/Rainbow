//
//  MainViewController.swift
//  Rainy
//
//  Created by Limon on 6/16/16.
//  Copyright © 2016 Rainy. All rights reserved.
//

import UIKit

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

func setAssociatedObject<T>(object: AnyObject, value: T, associativeKey: UnsafePointer<Void>, policy: objc_AssociationPolicy) {
    if let v: AnyObject = value as? AnyObject {
        objc_setAssociatedObject(object, associativeKey, v,  policy)
    }
    else {
        objc_setAssociatedObject(object, associativeKey, lift(value),  policy)
    }
}

func getAssociatedObject<T>(object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
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

class MainViewController: UITableViewController {

    // MARK: Constants

    struct Constants {
        struct Segue {
            static let ShowNextIdentifier = "Show Next"
            static let SetStyleIdentifier = "Set Style"
        }
    }

    // MARK: Properties

    var currentNavigationBarData: NavigationBarData!
    var nextNavigationBarData: NavigationBarData!

    @IBOutlet weak var nextNavigationBarTintColorText: UILabel!
    @IBOutlet weak var nextNavigatioBarBackgroundImageColorText: UILabel!
    @IBOutlet weak var nextNavigationBarPrefersHiddenSwitch: UISwitch!
    @IBOutlet weak var nextNavigationBarPrefersShadowImageHiddenSwitch: UISwitch!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if currentNavigationBarData == nil {
            currentNavigationBarData = NavigationBarData()
        }

        rabinbow_prefersNavigationBarBackgroundViewHidden = true

//        print(rabinbow_prefersNavigationBarBackgroundViewHidden)

        navigationController?.navigationBar.hidden = true

//        navigationController?.navigationBarHidden = false

        print(navigationController?.navigationBarHidden)

        nextNavigationBarData = currentNavigationBarData

        nextNavigationBarTintColorText.text = nextNavigationBarData.barTintColor.rawValue
        nextNavigatioBarBackgroundImageColorText.text = nextNavigationBarData.backgroundImageColor.rawValue
        nextNavigationBarPrefersHiddenSwitch.on = nextNavigationBarData.prefersHidden
        nextNavigationBarPrefersShadowImageHiddenSwitch.on = nextNavigationBarData.prefersShadowImageHidden

        navigationController?.navigationBar.barTintColor = currentNavigationBarData.barTintColor.toUIColor
        navigationController?.navigationBar.setBackgroundImage(currentNavigationBarData.backgroundImageColor.toUIImage, forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = (currentNavigationBarData.prefersShadowImageHidden) ? UIImage() : nil

        title = "Title " + "\(navigationController!.viewControllers.count)"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(currentNavigationBarData.prefersHidden, animated: animated)
    }

}

// MARK: - Target Action

extension MainViewController {

    @IBAction func nextNavigationBarPrefersShadowImageHidden(sender: UISwitch) {
        nextNavigationBarData.prefersShadowImageHidden = sender.on
    }

    @IBAction func nextNavigationBarPrefersHidden(sender: UISwitch) {
        nextNavigationBarData.prefersHidden = sender.on
    }

    @IBAction func navigationBarTranslucent(sender: UISwitch) {
        navigationController?.navigationBar.translucent = sender.on
    }

}

// MARK: - Table view data source

extension  MainViewController {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return navigationController?.viewControllers.first == self ? 2 : 1
    }

}

// MARK: - Table view delegate

extension  MainViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0), (0, 1):
            performSegueWithIdentifier(Constants.Segue.SetStyleIdentifier, sender: self)
        default:
            break
        }
    }
}

// MARK: - Navigation

extension MainViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.Segue.SetStyleIdentifier:
                guard let settingsViewController = segue.destinationViewController as? SettingsViewController else {
                    return
                }
                guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
                    return
                }

                var colorsArray = [NavigationBarBackgroundViewColor]()
                var selectedIndex: Int?
                var block: ((color: NavigationBarBackgroundViewColor) -> Void)?

                switch (selectedIndexPath.section, selectedIndexPath.row) {
                case (0, 0):
                    colorsArray = NavigationBarData.BarTintColorArray
                    selectedIndex = colorsArray.indexOf(NavigationBarBackgroundViewColor(rawValue: nextNavigationBarTintColorText.text!)!)
                    block = {
                        self.nextNavigationBarData.barTintColor = $0
                        self.nextNavigationBarTintColorText.text = $0.rawValue
                    }
                case (0, 1):
                    colorsArray = NavigationBarData.BackgroundImageColorArray
                    selectedIndex = colorsArray.indexOf(NavigationBarBackgroundViewColor(rawValue: nextNavigatioBarBackgroundImageColorText.text!)!)
                    block = {
                        self.nextNavigationBarData.backgroundImageColor = $0
                        self.nextNavigatioBarBackgroundImageColorText.text = $0.rawValue
                    }
                default:
                    break
                }
                settingsViewController.colorsData = (colorsArray, selectedIndex)
                settingsViewController.configurationBlock = block
                settingsViewController.titleText = tableView.cellForRowAtIndexPath(selectedIndexPath)?.textLabel?.text ?? ""

            case Constants.Segue.ShowNextIdentifier:
                guard let viewController = segue.destinationViewController as? MainViewController else {
                    return
                }
                viewController.currentNavigationBarData = nextNavigationBarData
                break
            default:
                break
            }
        }
    }

}

