//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Observable {

    public func mapAsync<T2>(
        initialValue: T2,
        _ transform: @escaping (T) async -> T2
    ) -> AnyObservable<T2> {

        self
                .map { value in Task { await transform(value) } }
                .await(initialValue: initialValue)
    }

    public func mapAsync<T2>(
        initialValue: T2,
        _ transform: @escaping (T) async throws -> T2
    ) -> AnyObservable<Result<T2, Error>> {

        self
                .map { value in Task { try await transform(value) } }
                .await(initialValue: initialValue)
    }
}
