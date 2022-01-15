//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension Observable {

    public func publishDifferences<Diff>(_ differentiator: @escaping (T, T) -> Diff) -> EventStream<Diff> {

        EventStream<Diff>(
            registerValues: { publish, _ in

                ObservableDifferencesSource(
                    source: self,
                    publish: publish,
                    differentiator: differentiator
                )
            },
            unregister: { source in

            }
        )
    }
}

class ObservableDifferencesSource<SourceObservable: Observable, Diff> {

    init(
        source: SourceObservable,
        publish: @escaping (Diff) -> Void,
        differentiator: @escaping (SourceObservable.T, SourceObservable.T) -> Diff
    ) {

        self.source = source
        self.differentiator = differentiator

        var currentValue = source.value

        self.sourceSubscription = source.subscribe { newValue in

            let difference = differentiator(newValue, currentValue)
            publish(difference)
            currentValue = newValue
        }
    }

    let source: SourceObservable
    let differentiator: (SourceObservable.T, SourceObservable.T) -> Diff

    let sourceSubscription: Subscription
}