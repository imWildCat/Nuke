// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import XCTest
import Nuke

// `Task.swift` is added directly to this target.
class TaskPerformanceTests: XCTestCase {
    func testSubscribe3(){
        measure {
            for _ in 0..<1000 {
            let url = URL(string: "https://example.com/\(arc4random()).jpeg")!
            let request = ImageRequest(url: url)
            }
        }
    }

    func testSubscribe2(){
//        let pool: TaskPool<ImageRequest.LoadKeyForProcessedImage, ImageResponse, Error>
//        measure {
//            for _ in 0..<100 {
//                let task =
//
//            }
//        }
    }

    func testSubscribe() {

        let loader = DataLoader()
        measure {
            for _ in 0..<100 {
                let url = URL(string: "https://example.com/\(arc4random()).jpeg")!
                let request = URLRequest(url: url)
                loader.loadData(with: request, didReceiveData: { _, _ in }, completion: { _ in })
//                let dataTask = URLSession.shared.dataTask(with: request)
//                dataTask.resume()
            }
        }
    }

    func testChangePriority() {
        let task = EmptyTask()
        var priority = TaskPriority.normal
        let subscription = task.publisher.subscribe { _ in }
        _ = task.publisher.subscribe { _ in }
        measure {
            for _ in 0..<100_000 {
                let newPriority: TaskPriority = priority == .high ? .normal : .high
                subscription?.setPriority(newPriority)
                priority = newPriority
            }
        }
    }

    func testUnsubscribe() {
        measure {
            for _ in 0..<100_000 {
                let task = EmptyTask()
                let subscription = task.publisher.subscribe { _ in }
                subscription?.unsubscribe()
            }
        }
    }

    func testAddManySubscriptions() {
        let task = EmptyTask()
        measure {
            for _ in 0..<100_000 {
                let subscription = task.publisher.subscribe { _ in }
                subscription?.unsubscribe()
            }
        }
    }
}

private struct MyError: Equatable {
    let raw: String
}

private final class SimpleTask: Task<Int, MyError> {
    override func start() {
        send(progress: TaskProgress(completed: 1, total: 2))
        send(value: 1)
        send(progress: TaskProgress(completed: 2, total: 2))
        send(value: 2, isCompleted: true)
    }
}

private final class EmptyTask: Task<Int, MyError> {
    override func start() {
    }
}
