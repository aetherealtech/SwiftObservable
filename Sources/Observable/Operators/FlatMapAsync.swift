//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Observable {

    public func flatMapAsync<InnerValue, ResultObservable: Observable>(
        initialValue: InnerValue,
        _ transform: @escaping (T) -> ResultObservable
    ) -> AnyObservable<InnerValue> where ResultObservable.T == Task<InnerValue, Never> {

        self
                .flatMap(transform)
                .await(initialValue: initialValue)
    }

    public func flatMapAsync<InnerValue, ResultObservable: Observable>(
        initialValue: InnerValue,
        _ transform: @escaping (T) -> ResultObservable
    ) -> AnyObservable<Result<InnerValue, Error>> where ResultObservable.T == Task<InnerValue, Error> {

        self
                .flatMap(transform)
                .await(initialValue: initialValue)
    }

    public func flatMapAsync<ResultObservable: Observable, InitialObservable: Observable>(
        initialValue: InitialObservable,
        _ transform: @escaping (T) async -> ResultObservable
    ) -> AnyObservable<ResultObservable.T> where InitialObservable.T == ResultObservable.T {

        self
            .mapAsync(initialValue: initialValue.erase(), { value in await transform(value).erase() })
            .flatten()
    }

    public func flatMapAsync<ResultObservable: Observable>(
        initialValue: ResultObservable.T,
        _ transform: @escaping (T) async -> ResultObservable
    ) -> AnyObservable<ResultObservable.T> {

        self
                .flatMapAsync(initialValue: StoredObservable(wrappedValue: initialValue), transform)
    }

    public func flatMapAsync<ResultObservable: Observable, InitialObservable: Observable>(
        initialValue: InitialObservable,
        _ transform: @escaping (T) async throws -> ResultObservable
    ) -> AnyObservable<Result<ResultObservable.T, Error>> where InitialObservable.T == Result<ResultObservable.T, Error> {

        self
                .mapAsync(initialValue: initialValue.erase(), { value in

                    try await transform(value)
                            .map { innerValue in .success(innerValue) }
                })
                .map { result -> AnyObservable<Result<ResultObservable.T, Error>> in

                    switch result {

                    case .success(let innerObservable):
                        return innerObservable

                    case .failure(let error):
                        return StoredObservable(wrappedValue: Result<ResultObservable.T, Error>.failure(error)).erase()
                    }
                }
                .flatten()
    }

    public func flatMapAsync<ResultObservable: Observable>(
        initialValue: ResultObservable.T,
        _ transform: @escaping (T) async throws -> ResultObservable
    ) -> AnyObservable<Result<ResultObservable.T, Error>> {

        self
                .flatMapAsync(initialValue: StoredObservable(wrappedValue: Result<ResultObservable.T, Error>.success(initialValue)), transform)
    }

    public func flatMapAsync<InnerValue, ResultObservable: Observable>(
        initialValue: InnerValue,
        _ transform: @escaping (T) async -> ResultObservable
    ) -> AnyObservable<InnerValue> where ResultObservable.T == Task<InnerValue, Never> {

        self
                .flatMapAsync(initialValue: Task { initialValue }, transform)
                .await(initialValue: initialValue)
    }

    public func flatMapAsync<InnerValue, ResultObservable: Observable>(
        initialValue: InnerValue,
        _ transform: @escaping (T) async -> ResultObservable
    ) -> AnyObservable<Result<InnerValue, Error>> where ResultObservable.T == Task<InnerValue, Error> {

        self
                .flatMapAsync(initialValue: Task { initialValue }, transform)
                .await(initialValue: initialValue)
    }

    public func flatMapAsync<InnerValue, ResultObservable: Observable>(
        initialValue: InnerValue,
        _ transform: @escaping (T) async throws -> ResultObservable
    ) -> AnyObservable<Result<InnerValue, Error>> where ResultObservable.T == Task<InnerValue, Never> {

        self
                .flatMapAsync(initialValue: Task<InnerValue, Never> { initialValue }, transform)
                .map { result -> Task<InnerValue, Error> in

                    switch result {

                    case .success(let task):
                        return Task<InnerValue, Error> { await task.value }

                    case .failure(let error):
                        return Task<InnerValue, Error> { throw error }
                    }
                }
                .await(initialValue: initialValue)
    }

    public func flatMapAsync<InnerValue, ResultObservable: Observable>(
        initialValue: InnerValue,
        _ transform: @escaping (T) async throws -> ResultObservable
    ) -> AnyObservable<Result<InnerValue, Error>> where ResultObservable.T == Task<InnerValue, Error> {

        self
                .flatMapAsync(initialValue: Task<InnerValue, Error> { initialValue }, transform)
                .map { result -> Task<InnerValue, Error> in

                    switch result {

                    case .success(let task):
                        return task

                    case .failure(let error):
                        return Task<InnerValue, Error> { throw error }
                    }
                }
                .await(initialValue: initialValue)
    }
}
