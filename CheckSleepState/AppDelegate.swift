//
//  AppDelegate.swift
//  CheckSleepState
//
//  Created by Guru Senthil on 11/10/16.
//  Copyright © 2016 Guru Senthil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    var menuItems:Array<NSMenuItem>!
    let menu:NSMenu! = NSMenu()


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "check-mark")
        }
        
        let topMenuItem = NSMenuItem(title: "No Apps Preventing Sleep", action: nil, keyEquivalent: "")
        menu.addItem(topMenuItem)
        
        statusItem.menu = menu
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("checkSleepStateAndUpdate"), userInfo: nil, repeats: true)
        timer.fire()
    }

    func checkSleepStateAndUpdate() -> Void {
        let shellInterface:ShellInterface = ShellInterface();
        let commandResult:String = shellInterface.runCommand("pmset -g assertions | grep .*SystemSleep | head -2 | cut -c 35-40");
        let oneResult = String(commandResult[commandResult.startIndex]);
        let secondResult = String(commandResult[commandResult.startIndex.advancedBy(2)]);
        
        let one = Int(oneResult)!;
        let two = Int(secondResult)!;
        
        print(one)
        print(two)
        
        if ((one == 1) || (two == 1)) {
            if let button = statusItem.button {
                button.image = NSImage(named: "x-mark")
            }
        }else {
            if let button = statusItem.button {
                button.image = NSImage(named: "check-mark")
            }
        }
        
        if((one == 1) || (two == 1)){
            var n = 1
            var itemsToAdd:Array<NSMenuItem> = Array();
            var continueLoop = true
            while continueLoop {
                let nextCommandResult:String = shellInterface.runCommand("pmset -g assertions | grep .*SystemSleep | sed -n "+String(2+n)+"p");
                //print("Command result number of characters: "+String(nextCommandResult.characters.count))
                if (nextCommandResult.characters.count != 0) {
                    let positionOfOpenBracket = nextCommandResult.characters.indexOf("(")!;
                    let positionOfEndBracket = nextCommandResult.characters.indexOf(")")!;
                    let name = nextCommandResult.substringWithRange(Range<String.Index>((positionOfOpenBracket.advancedBy(1))..<positionOfEndBracket))
                    itemsToAdd.append(NSMenuItem(title: "   "+name, action: nil, keyEquivalent: ""))
                    print("Name test: "+name)
                    n += 1;
                    
                }else{
                    continueLoop = false
                }
            }
            updateMenu(itemsToAdd, sleepPrevented: true)
        }else{
            updateMenu([], sleepPrevented: false)
        }
        
    }
    
    func updateMenu(menuItemsToAdd:Array<NSMenuItem>, sleepPrevented:Bool) -> Void {
        if menu.numberOfItems != 0 {
            menu.removeAllItems()
        }
        var topMenuItem:NSMenuItem = NSMenuItem();
        if menuItemsToAdd.count == 0 {
            if sleepPrevented {
                topMenuItem = NSMenuItem(title: "Unknown App Preventing Sleep", action: nil, keyEquivalent: "")
            }else{
                topMenuItem = NSMenuItem(title: "No Apps Preventing Sleep", action: nil, keyEquivalent: "")
            }
        }else {
            topMenuItem = NSMenuItem(title: "Apps Preventing Sleep:", action: nil, keyEquivalent: "")
        }
        menu.addItem(topMenuItem)
        
        for menuItem in menuItemsToAdd {
            menu.addItem(menuItem)
        }
        
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit CheckSleepState", action: Selector("terminate:"), keyEquivalent: "q"))
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

