//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension Observable {

    public func flatMap<ResultObservable: Observable>(_ transform: @escaping (T) -> ResultObservable) -> AnyObservable<ResultObservable.T> {

        self
            .map(transform)
            .flatten()
    }
}
