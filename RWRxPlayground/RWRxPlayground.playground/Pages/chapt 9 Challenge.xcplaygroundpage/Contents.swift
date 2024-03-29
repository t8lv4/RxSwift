import Foundation
import RxSwift

/*
 Take the code from the scan(_:accumulator:) example
 display both the current value and the running total at the same time.”
 */

example(of: "challenge using zip") {
	let source = Observable.of(1, 3, 5, 7, 9)
	let scan = source.scan(0, accumulator: +)

	let observable = Observable.zip(source, scan)
	_ = observable.subscribe(onNext: { tuple in
		print("value: \(tuple.0) - running sum: \(tuple.1)")
	})
}

example(of: "challenge using scan & a tuple") {
	let source = Observable.of(1, 3, 5, 7, 9)
	let observable = source.scan((0, 0)) { acc, current in
		(current, acc.1 + current)
	}

	_ = observable.subscribe(onNext: { tuple in
		print("value: \(tuple.0) - running sum: \(tuple.1)")
	})
}
