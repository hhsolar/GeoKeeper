//
//  AppDelegate.swift
//  GeoKeeper
//
//  Created by apple on 1/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        checkFirstLaunch()
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            let navigationController1 = tabBarViewControllers[0] as! UINavigationController
            let currentLocationViewController = navigationController1.viewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
            
            let navigationController2 = tabBarViewControllers[1] as! UINavigationController
            let categoriesViewController = navigationController2.viewControllers[0] as! CategoriesViewController
            categoriesViewController.managedObjectContext = managedObjectContext
            
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
            
            let _ = categoriesViewController.view
        }
        listenForFatalCoreDataNotifications()
        
        // setting for navigation bar
        UINavigationBar.appearance().tintColor = UIColor.white
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16.0)!], for: .normal)
        
        return true
    }
    
    
    func checkFirstLaunch() {
        let launchBefore = UserDefaults.standard.bool(forKey: "launchBefore")
        if launchBefore == false {
            UserDefaults.standard.set("Default", forKey: "Portrait")
            UserDefaults.standard.set(true, forKey: "launchBefore")
        
            let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedObjectContext)!
            for i in 0..<4 {
                let categoryObject = NSManagedObject(entity: entity, insertInto: managedObjectContext)
                categoryObject.setValue(icons[i], forKey: "category")
                categoryObject.setValue(colors[i], forKey: "color")
                categoryObject.setValue(icons[i], forKey: "iconName")
                categoryObject.setValue(i, forKey: "id")
            }
            saveToCoreData(managedObjectContext)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()

    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(forName: MyManagedObjectContextSaveDidFailNotification, object: nil, queue: OperationQueue.main, using: {notification in
            
            let alert = UIAlertController(
                title: "Internal Error",
                message:
                "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .alert)
            let action = UIAlertAction(title:"OK", style: .default) { _ in
                let exception = NSException(
                    name: NSExceptionName.internalInconsistencyException,
                    reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            self.viewControllerForShowingAlert().present(alert, animated: true, completion:nil)
        })
    }
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewcontroller = self.window!.rootViewController!
        if let presentViewController = rootViewcontroller.presentedViewController {
            return presentViewController
        } else {
            return rootViewcontroller
        }
    }
    
    
}

