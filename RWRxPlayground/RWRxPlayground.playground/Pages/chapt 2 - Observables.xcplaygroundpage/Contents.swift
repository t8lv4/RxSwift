import Foundation
import RxSwift

// MARK: - just, of, from

example(of: "just, of, from") {
	let one = 1
	let two = 2
	let three = 3

	let observable1 = Observable.just(one)
	let observable2 = Observable.of(one, two, three)
	let observable3 = Observable.of([one, two, three])
	let observable4 = Observable.from([one, two, three])

	observable1.subscribe { event in
		print("just: \(event)")
	}

	observable2.subscribe { event in
		print("of: \(event)")
	}

	observable3.subscribe { event in
		print("of array: \(event)")
	}

	observable4.subscribe { event in
		print("from collection: \(event)")
	}
}

// MARK: - subscribe

example(of: "subscribe") {
	let one = 1
	let two = 2
	let three = 3

	let observable = Observable.from([one, two, three])
	observable.subscribe { event in
		print(event) // prints "event" aka next(element) then completed
	}

	observable.subscribe { event in
		if let element = event.element {
			print(element) // prints element's value
		}
	}

	observable.subscribe(onNext: { element in // subscribe(onNext:) prints element's value
		print(element)
	})
}

// MARK: - emty

example(of: "empty") { // only prints "completed"
	let observable = Observable<Void>.empty() // terminates immediately
	observable.subscribe { element in
		print(element)
	} onCompleted: {
		print("completed")
	}
}

// MARK: - never

example(of: "never") {
	let observable = Observable<Void>.never() // never terminates, express an infinite duration
	observable.subscribe { element in
		print(element)
	} onCompleted: {
		print("completed")
	}
}

// MARK: - range

example(of: "range") {
	let observable = Observable<Int>.range(start: 1, count: 10)
	observable.subscribe { index in
		let n = Double(index)
		let fibonacci = Int(
			(pow(1.61803, n) - pow(0.61803, n)) / 2.23606.rounded()
		)
		print(fibonacci)
	} onCompleted: {
		print("completed")
	}
}

// MARK: - dispose

example(of: "dispose") {
	let observable = Observable.of("A", "B", "C")
	let subscription = observable.subscribe { event in
		print(event)
	}
	subscription.dispose() // manually cancel the subscription
}

// MARK: - DisposeBag

example(of: "DisposeBag") {
	let disposeBag = DisposeBag()
	Observable.of("A", "B", "C")
		.subscribe {
			print($0)
		}
		.disposed(by: disposeBag)
}

// MARK: - create

enum MyError: Error {
	case anError
}

example(of: "create") {
	let disposeBag = DisposeBag()

	Observable<String>.create { observer in
		observer.onNext("1")
//		observer.onError(MyError.anError)
		observer.onCompleted()
		observer.onNext("?")
		return Disposables.create()
	}
	.subscribe(
		onNext: { print($0)},
		onError: { print($0)},
		onCompleted: { print("completed")},
		onDisposed: { print("Disposed")}
	)
	.disposed(by: disposeBag)
}

example(of: "deferred") {
	let disposedBag = DisposeBag()
	var flip = false

	let factory = Observable.deferred {
		flip.toggle()

		if flip {
			return Observable.of(1, 2, 3)
		} else {
			return Observable.of(4, 5, 6)
		}
	}

	for _ in 0...3 {
		factory.subscribe(onNext: {
			print($0, terminator: "")
		})
		.disposed(by: disposedBag)
		print()
	}
}

// MARK: - Single

example(of: "Single") {
	let disposeBag = DisposeBag()

	enum FileReadError: Error {
		case fileNotFound, unreadable, encodingFailed
	}

	func loadText(from name: String) -> Single<String> {
		return Single.create { single in
			let disposable = Disposables.create()

			guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
				single(.failure(FileReadError.fileNotFound))
				return disposable
			}

			guard let data = FileManager.default.contents(atPath: path) else {
				single(.failure(FileReadError.unreadable))
				return disposable
			}

			guard let contents = String(data: data, encoding: .utf8) else {
				single(.failure(FileReadError.encodingFailed))
				return disposable
			}

			single(.success(contents))
			return disposable
		}
	}

	loadText(from: "Copyright")
		.subscribe {
			switch $0 {
				case .success(let string): print(string)
				case .failure(let error): print(error)
			}
		}
		.disposed(by: disposeBag)

//	loadText(from: "toto") // prints file not found
//		.subscribe {
//			switch $0 {
//				case .success(let string): print(string)
//				case .failure(let error): print(error)
//			}
//		}
//		.disposed(by: disposeBag)
}
