//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension Observable {

    public func publishDifferences<Diff>(_ differentiator: @escaping (T, T) -> Diff) -> EventStream<Diff> {

        publishUpdates()
                .difference(
                    initialValue: wrappedValue,
                    differentiator
                )
    }
}
