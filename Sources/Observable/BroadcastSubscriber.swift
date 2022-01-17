//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import CoreExtensions
import EventStreams
import Observer

class BroadcastSubsciber<Event> {

    init(sourceSubscriptionProvider: @escaping (@escaping (Event) -> Void) -> Subscription) {

        self.sourceSubscriptionProvider = sourceSubscriptionProvider
    }

    func subscribe(_ handler: @escaping (Event) -> Void) -> Subscription {

        self.sourceSubscription = subscriptionsQueue.sync {

            return self.sourceSubscription ??= self.sourceSubscriptionProvider(self.receive)
        }

        return BroadcastSubscription(
            subscriber: self,
            handler: handler
        )
    }

    private class BroadcastSubscription : Subscription {

        init(
            subscriber: BroadcastSubsciber<Event>,
            handler: @escaping (Event) -> Void
        ) {

            self.subscriber = subscriber
            self.handler = handler

            super.init()
            
            subscriber.subscriptionsQueue.async {

                subscriber.subscriptions.insert(self)
            }
        }
        
        func receive(_ event: Event) {
            
            handler(event)
        }

        deinit {

            guard let subscriber = self.subscriber else { return }

            subscriber.subscriptionsQueue.async {

                subscriber.subscriptions.remove(self)

                if subscriber.subscriptions.isEmpty {
                    subscriber.sourceSubscription = nil
                }
            }
        }

        private weak var subscriber: BroadcastSubsciber<Event>?
        private let handler: (Event) -> Void
    }
    
    private func receive(_ event: Event) {
        
        let subscriptions = subscriptionsQueue.sync {

            self.subscriptions
        }
        
        subscriptions.forEach { subscription in subscription.receive(event) }
    }

    private let sourceSubscriptionProvider: (@escaping (Event) -> Void) -> Subscription

    private var subscriptions = Set<BroadcastSubscription>()
    private var sourceSubscription: Subscription?

    private let subscriptionsQueue = DispatchQueue(label: "com.devcraft.observable.lazyeventstream.subscriptionsqueue")
}
