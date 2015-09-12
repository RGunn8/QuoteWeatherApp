//
//  ContainerViewController.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 9/11/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

enum SlideOutState {
    case RightCollapsed
    case RightPanelExpanded
}

class ContainerViewController: UIViewController, CLLocationManagerDelegate {
    var centerNavigationController:UINavigationController!
    var centerViewController:ViewController!
    var currentState: SlideOutState = .RightCollapsed {
        didSet {
            let shouldShowShadow = currentState != .RightCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    let centerPanelExpandedOffset: CGFloat = 100
    var rightViewController: YourCitiesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self


        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)

        centerNavigationController.didMoveToParentViewController(self)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification:", name:"plusButtonPressed", object: nil)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

        // Do any additional setup after loading the view.

    }

    func methodOfReceivedNotification(notification: NSNotification){
        let searchTVC = UIStoryboard.searchController()
        searchTVC?.delegate = centerViewController
        self.centerNavigationController.pushViewController(searchTVC!, animated: true)
        println("tapped")
    }


}

extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer

    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)

        switch(recognizer.state) {
        case .Began:
            if (currentState == .RightCollapsed) {
                if (!gestureIsDraggingFromLeftToRight) {
                    addRightPanelViewController()
                }
                showShadowForCenterViewController(true)
            }
        case .Changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if (rightViewController != nil) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }

    
}


    private extension UIStoryboard {
        class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }

      
        class func rightViewController() -> YourCitiesTableViewController? {
            return mainStoryboard().instantiateViewControllerWithIdentifier("YourCities") as? YourCitiesTableViewController
        }

        class func centerViewController() -> ViewController? {
            return mainStoryboard().instantiateViewControllerWithIdentifier("ContentViewController") as? ViewController
        }

        class func searchController() -> SearchTableViewController? {
            return mainStoryboard().instantiateViewControllerWithIdentifier("SearchTableViewController") as? SearchTableViewController
        }
        
    }

extension ContainerViewController: CenterViewControllerDelegate {


    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .RightPanelExpanded)

        if notAlreadyExpanded {
            addRightPanelViewController()
        }

        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }


    func addRightPanelViewController() {
        if (rightViewController == nil) {
            rightViewController = UIStoryboard.rightViewController()
            // rightViewController!.animals = Animal.allDogs()

            addChildSidePanelController(rightViewController!)
        }

    }
    func collapseSidePanels() {
        switch (currentState) {
        case .RightPanelExpanded:
            toggleRightPanel()

        default:
            break
        }
    }


    

    func animateRightPanel(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .RightPanelExpanded

            animateCenterPanelXPosition(targetPosition: -CGRectGetWidth(centerNavigationController.view.frame) + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .RightCollapsed

                self.rightViewController!.view.removeFromSuperview()
                self.rightViewController = nil;
            }
        }

    }

    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }



    func addChildSidePanelController(sidePanelController: YourCitiesTableViewController) {
        sidePanelController.delegate = centerViewController

        view.insertSubview(sidePanelController.view, atIndex: 0)

        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }



    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    

    
}


