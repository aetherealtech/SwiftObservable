//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension EventStream {

    public func accumulate<Result>(initialValue: Result, _ accumulator: @escaping (Result, Value) -> Result) -> AnyObservable<Result> {

        self
                .accumulate(initialValue: initialValue, accumulator)
                .cacheLatest(initialValue: initialValue)
    }
}
