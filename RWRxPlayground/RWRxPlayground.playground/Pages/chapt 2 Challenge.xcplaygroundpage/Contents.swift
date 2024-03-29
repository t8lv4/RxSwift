import Foundation
import RxSwift

// Challenge 1

example(of: "do") {
	let disposeBag = DisposeBag()
	let observable = Observable<Void>.never() // never terminates, express an infinite duration
	observable.do { thing in
		print(thing)
	} onCompleted: {
		print("completed")
	} onSubscribe: {
		print("onSubscribe")
	} onDispose: {
		print("onDispose")
	}
	.subscribe { element in
		print(element)
	} onCompleted: {
		print("completed")
	}
	.disposed(by: disposeBag)
}

// Challenge 2

example(of: "debug do") {
	let disposeBag = DisposeBag()
	let observable = Observable<Void>.never() // never terminates, express an infinite duration
	observable
		.debug("identifier: do")
		.do { thing in
			print(thing)
		} onCompleted: {
			print("completed")
		} onSubscribe: {
			print("onSubscribe")
		} onDispose: {
			print("onDispose")
		}
		.subscribe { element in
			print(element)
		} onCompleted: {
			print("completed")
		}
		.disposed(by: disposeBag)
}
