//
//  ContentView.swift
//  
//
//  Created by lemin on 10/11/23.
//

import Foundation
import SwiftUI
let USER_DEFAULTS_PATH = "/var/mobile/Library/Preferences/com.leemin.helium.plist"
// MARK: Root View
struct RootView: View {
    var body: some View {
        TabView {
            // Home Page
            HomePageView()
                .tabItem {
                    Label(NSLocalizedString("Home", comment: ""), systemImage: "house")
                }
            
            // Settings
//           ContentView()
//                .tabItem {
//                    Label(NSLocalizedString("Settings", comment: ""), systemImage: "gear")
//                }
        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
           if #available(iOS 14.0, *) {
              if #available(iOS 15.0, *) {
                 UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
              } else {
                 // Fallback on earlier versions
              }
            } else {
                // Fallback on earlier versions
            }
            
            do {
                try FileManager.default.contentsOfDirectory(atPath: "/var/mobile")
//                 warn to turn on developer mode if iOS 16+
               
             
//               if #available(iOS 16.0, *), !UserDefaults.standard.bool(forKey: "hasWarnedOfDevMode", forPath: USER_DEFAULTS_PATH) {
//                   UIApplication.shared.confirmAlert(title: NSLocalizedString("Info", comment: ""), body: NSLocalizedString("使用前请确保开启开发者模式！ 否则这将不起作用。", comment: ""), onOK: {
//                       UserDefaults.standard.setValue(true, forKey: "hasWarnedOfDevMode", forPath: USER_DEFAULTS_PATH)
//                   }, noCancel: true)
//               }
//               return
            } catch {
                UIApplication.shared.alert(title: NSLocalizedString("Not Supported", comment: ""), body: NSLocalizedString("This app must be installed with TrollStore.", comment: ""))
            }
        }
    }
}

// MARK: Objc Bridging
@objc
open class ContentInterface: NSObject {
    @objc
    open func createUI() -> UIViewController {
        let contents = RootView()
        return HostingController(rootView: contents)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

class HostingController<Content>: UIHostingController<Content> where Content: View {
    @objc override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
