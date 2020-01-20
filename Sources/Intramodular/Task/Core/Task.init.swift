//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension Task where Success == Void {
    public static func action(_ action: @escaping () -> Void) -> Task {
        MutableTask(action: action)
    }
}
