//
//  AppDelegate.swift
//  Do Me
//
//  Created by Balaji Srinivas on 12/04/23.
//

import UIKit

import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        do{
             _ = try Realm()
        }catch {
            print("Error initializing realm, \(error)")
        }
        
        var navigationBarAppearace = UINavigationBar.appearance()

        return true
    }
    
}

    
