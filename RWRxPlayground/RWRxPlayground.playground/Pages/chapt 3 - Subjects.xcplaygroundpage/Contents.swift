import Foundation
import RxSwift
import RxRelay

// MARK: - PublishSubject

example(of: "PublishSubject") {
	let subject = PublishSubject<String>()
	subject.on(.next("is anyone listening?")) // does not print because nothing subscribed to subject yet

	let subscriptionOne = subject
		.subscribe { print($0) } // prints event

	subject.on(.next("1"))
	subject.onNext("2") // short for .on(.next(:))

	let subscriptionTwo = subject
		.subscribe { event in
			print("2)", event.element ?? event)
		}

	subscriptionOne.dispose() // sub 1 stops receiving events
	subject.onNext("3")
	subject.onNext("4")

	subject.onCompleted()
	subject.onNext("5")

	subscriptionTwo.dispose()

	let disposeBag = DisposeBag()
	subject
		.subscribe {
			print("3)", $0.element ?? $0) // sub 3 will receive "completed" event because subject stops emitting values
		}

	subject.onNext("?")
}

// MARK: - BehaviorSubject

enum MyError: Error {
	case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
	print(label, (event.element ?? event.error) ?? event)
}

example(of: "BehaviorSubject") {
	let subject = BehaviorSubject(value: "initial value")
	let disposeBag = DisposeBag()

	subject.onNext("X")
	subject
		.subscribe { print(label: "1)", event: $0) } // event is X because it's the latest value *before* subscription
		.disposed(by: disposeBag)

	subject.onError(MyError.anError)
	subject
		.subscribe { print(label: "2)", event: $0) }
		.disposed(by: disposeBag)
}

// MARK: - Replay

example(of: "ReplaySubject") {
	let subject = ReplaySubject<String>.create(bufferSize: 2)
	let disposeBag = DisposeBag()

	subject.onNext("1")
	subject.onNext("2")
	subject.onNext("3")

	subject
		.subscribe { print(label: "1)", event: $0) }
		.disposed(by: disposeBag)

	subject
		.subscribe { print(label: "2)", event: $0) }
		.disposed(by: disposeBag)

	subject.onNext("4")
	subject.onError(MyError.anError)
//	subject.dispose() // next subscriber would receive an error message: Object `RxSwift....ReplayMany<Swift.String>` was already disposed.

	subject
		.subscribe { print(label: "3)", event: $0) }
		.disposed(by: disposeBag)
}

// MARK: - Relay

example(of: "PublishRelay") {
	let relay = PublishRelay<String>()
	let disposeBag = DisposeBag()

	relay.accept("knock knock, anyone home?")
	relay
		.subscribe(onNext: { element in
			print(element)
		})
		.disposed(by: disposeBag)
	relay.accept("1")
}

example(of: "BehaviorRelay") {
	let relay = BehaviorRelay<String>(value: "initial value")
	let disposeBag = DisposeBag()

	relay.accept("new initial value")
	relay
		.subscribe { print(label: "1)", event: $0)}
		.disposed(by: disposeBag)

	relay.accept("1")
	relay
		.subscribe { print(label: "2)", event: $0) }
		.disposed(by: disposeBag)

	relay.accept("2")
	print(relay.value) // prints latest value
}





