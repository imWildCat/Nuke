// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import XCTest
import Nuke

class ImageViewPerformanceTests: XCTestCase {
    private let dummyCacheRequest = ImageRequest(url: URL(string: "http://test.com/9999999)")!, processors: [ImageProcessors.Resize(size: CGSize(width: 2, height: 2))])

    override func setUp() {
        // Store something in memory cache to avoid going through an optimized empty Dictionary path
        ImagePipeline.shared.configuration.imageCache?[dummyCacheRequest] = ImageContainer(image: PlatformImage())
        ImagePipeline.shared.configuration.dataLoadingQueue.isSuspended = true
    }

    override func tearDown() {
        ImagePipeline.shared.configuration.imageCache?[dummyCacheRequest] = nil
    }

    // This is the primary use case that we are optimizing for - loading images
    // into target, the API that majoriy of the apps are going to use.
    func testImageViewMainThreadPerformance() {
        let view = _ImageView()

        let urls = (0..<1000).map { _ in return URL(string: "http://test.com/\(arc4random())")! }

        measure {
            for url in urls {
                let r = ImageRequest(url: url, processors: [ImageProcessors.Resize(width: CGFloat(arc4random()))])
                loadImage(with: r, into: view)
            }
        }
    }

    func testPrefetch() {

        let urls = (0..<10).map {  URL(string: "http://test.com/\($0)")! }
        let urls2 = (10..<20).map { URL(string: "http://test.com/\($0)")! }
        var index = 0
        let pr = ImagePreheater()
        measure {
            let startTime = CFAbsoluteTimeGetCurrent()
            for _ in 0..<100 {
                if index == 0 {
                    pr.stopPreheating(with: urls)
                    pr.startPreheating(with: urls2)
                } else {
                    pr.stopPreheating(with: urls2)
                    pr.startPreheating(with: urls)
                }

                if index == 0 { index = 1} else { index = 0 }

            }

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
             print("Time elapsed for  \(timeElapsed) s.")
        }
    }

    func testImageViewMainThreadPerformanceWithProcessor() {
        let view = _ImageView()

        let urls = (0..<20_000).map { _ in return URL(string: "http://test.com/1)")! }

        measure {
            for url in urls {
                let request = ImageRequest(url: url, processors: [ImageProcessors.Resize(size: CGSize(width: 1, height: 1))])
                loadImage(with: request, into: view)
            }
        }
    }

    func testImageViewMainThreadPerformanceWithProcessorAndSimilarImageInCache() {
        let view = _ImageView()

        let urls = (0..<20_000).map { _ in return URL(string: "http://test.com/9999999)")! }

        measure {
            for url in urls {
                let request = ImageRequest(url: url, processors: [ImageProcessors.Resize(size: CGSize(width: 1, height: 1))])
                loadImage(with: request, into: view)
            }
        }
    }
}
