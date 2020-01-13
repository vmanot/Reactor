//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

extension UIViewController {
    var topMostPresentedViewController: UIViewController? {
        var topController = self
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        
        return topController
    }
    
    var topMostViewController: UIViewController {
        topMostPresentedViewController ?? self
    }
}

#endif
