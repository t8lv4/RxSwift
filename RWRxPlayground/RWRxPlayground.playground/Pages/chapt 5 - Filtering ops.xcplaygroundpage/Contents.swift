import Foundation
import RxSwift

// MARK: - ignoreElements

example(of: "ignoreElements") {
	let strikes = PublishSubject<String>()
	let disposeBag = DisposeBag()

	strikes
		.ignoreElements()
		.subscribe { _ in
			print("you're out!")
		}
		.disposed(by: disposeBag)

	strikes.onNext("X")
	strikes.onNext("X")
	strikes.onNext("X")

	strikes.onCompleted() // trigger print
}

example(of: "element(at:)") {
	let strikes = PublishSubject<String>()
	let disposeBag = DisposeBag()

	strikes
		.element(at: 2)
		.subscribe(onNext: { _ in
			print("you're out!")
		})
		.disposed(by: disposeBag)

	strikes.onNext("X")
	strikes.onNext("X")
	strikes.onNext("X") // trigger print
}

example(of: "filter") {
	let disposeBag = DisposeBag()

	Observable.of(1, 2, 3, 4, 5, 6)
		.filter { $0.isMultiple(of: 2) }
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

example(of: "skip") {
	let disposeBag = DisposeBag()

	Observable.of("A", "B", "C", "D", "E", "F")
		.skip(3)
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

example(of: "skip(while:)") {
	let disposeBag = DisposeBag()

	Observable.of(2, 2, 3, 4, 4)
		.skip(while: { $0.isMultiple(of: 2) })
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

example(of: "skip(until:)") {
	let disposeBag = DisposeBag()

	let subject = PublishSubject<String>()
	let trigger = PublishSubject<String>()

	subject
		.skip(until: trigger)
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)

	subject.onNext("a")
	subject.onNext("b")
	trigger.onNext("X")
	subject.onNext("c")
	subject.onNext("d")
}

example(of: "take") {
	let disposeBag = DisposeBag()

	Observable.of(1, 2, 3, 4, 5, 6)
		.take(3)
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

example(of: "take(while:) with the enumerated operator") {
	let disposeBag = DisposeBag()

	Observable.of(2, 2, 4, 4, 6, 6)
		.enumerated()
		.take(while: { index, element in
			element.isMultiple(of: 2) && index < 3
		})
		.map(\.element)
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

example(of: "take(until:, behavior:)") { // defaults to .exclusive
	let disposeBag = DisposeBag()

	Observable.of(1, 2, 3, 4, 5)
		.take(until: { $0.isMultiple(of: 4) }, behavior: .inclusive)
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

example(of: "skip(until:)") {
	let disposeBag = DisposeBag()

	let subject = PublishSubject<String>()
	let trigger = PublishSubject<String>()

	subject
		.take(until: trigger)
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)

	subject.onNext("1")
	subject.onNext("2")
	trigger.onNext("X")
	subject.onNext("4")
}

example(of: "distinctUntilChanged") {
	let disposeBag = DisposeBag()

	Observable.of("a", "a", "b", "b", "a")
		.distinctUntilChanged()
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
	let disposeBag = DisposeBag()

	let formatter = NumberFormatter()
	formatter.numberStyle = .spellOut

	Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
		.distinctUntilChanged { a, b in
			guard
				let aWords = formatter
					.string(from: a)?
					.components(separatedBy: " "),
				let bWords = formatter
					.string(from: b)?
					.components(separatedBy: " ")
			else {
				return false
			}

			var containsMatch = false

			for aWord in aWords where bWords.contains(aWord) {
				containsMatch = true
				break
			}

			return containsMatch
		}
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}
