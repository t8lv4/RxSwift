import Foundation
import RxSwift

// MARK: - startWith

example(of: "startWith") {
	let numbers = Observable.of(2, 3, 4)

	let observable = numbers.startWith(1)
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
}

// MARK: - Observable.concat

example(of: "Observable.concat") {
	let first = Observable.of(1, 2, 3)
	let second = Observable.of(4, 5, 6)

	let observable = Observable.concat([first, second])
	observable.subscribe(onNext: { print($0) })
}

// MARK: - concat

example(of: "concat") {
	let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
	let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")

	let observable = germanCities.concat(spanishCities)
	observable.subscribe(onNext: { print($0) })
}

// MARK: - concatMap

example(of: "concatMap") {
	let sequences = [
		"germanCities": Observable.of("Berlin", "Münich", "Frankfurt"),
		"spanishCities": Observable.of("Madrid", "Barcelona", "Valencia")
	]

	let observable = Observable.of("germanCities", "spanishCities")
		.concatMap { country in
			sequences[country] ?? .empty()
		}

	_ = observable.subscribe(onNext: { print($0) })
}

// MARK: - merge

example(of: "merge") {
	let left = PublishSubject<String>()
	let right = PublishSubject<String>()

	let source = Observable.of(left.asObservable(), right.asObservable())
	let observable = source.merge()
	_ = observable.subscribe(onNext: { print($0) })

	var leftValues = ["Berlin", "Münich", "Frankfurt"]
	var rightValues = ["Madrid", "Barcelona", "Valencia"]
	repeat {
		switch Bool.random() {
			case true where !leftValues.isEmpty:
				left.onNext("left: " + leftValues.removeFirst())
			case false where !rightValues.isEmpty:
				right.onNext("right: " + rightValues.removeFirst())
			default:
				break
		}
	} while !leftValues.isEmpty || !rightValues.isEmpty

	left.onCompleted()
	right.onCompleted()
}

// MARK: - combineLatest

example(of: "combineLatest") {
	let left = PublishSubject<String>()
	let right = PublishSubject<String>()

	// combineLatest using elements/sources
	let observable = Observable.combineLatest(left, right) { lastLeft, lastRight in
		"\(lastLeft) \(lastRight)"
	}

	// same result with combineLatest using Collection
	let observableAlt = Observable.combineLatest([left, right]) { strings in
		strings.joined(separator: " ")
	}

	_ = observable.subscribe(onNext: { print($0) })

	print("> Sending a value to Left")
	left.onNext("Hello,")
	print("> Sending a value to Right")
	right.onNext("world")
	print("> Sending another value to Right")
	right.onNext("RxSwift")
	print("> Sending another value to Left")
	left.onNext("Have a good day,")

	left.onCompleted()
	right.onCompleted()
}

// MARK: - combineLatest different types

example(of: "combine user choice and value") {
	let dateStyle: Observable<DateFormatter.Style> = Observable.of(.short, .long)
	let dates = Observable.of(Date())

//	let observable = Observable.combineLatest(dateStyle, dates) { dateStyle, date -> String in
//		let formatter = DateFormatter()
//		formatter.dateStyle = dateStyle
//		return formatter.string(from: date)
//	}

	let observable = Observable.combineLatest(dateStyle, dates) {
		let formatter = DateFormatter()
		formatter.dateStyle = $0
		return formatter.string(from: $1)
	}

	_ = observable.subscribe(onNext: { print($0) })
}

// MARK: - zip

example(of: "zip") {
	enum Weather {
		case cloudy, sunny
	}

	let left = Observable<Weather>.of(.sunny, .cloudy, .cloudy, .sunny)
	let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")

	let observable = Observable.zip(left, right) { weather, city in
		"it's \(weather) in \(city)"
	}

	_ = observable.subscribe(onNext: { print($0) })
}

// MARK: - withLatestFrom

example(of: "withLatestFrom") {
	let button = PublishSubject<Void>()
	let textField = PublishSubject<String>()

	let observable = button.withLatestFrom(textField)
	_ = observable.subscribe(onNext: { print($0) })

	textField.onNext("Par")
	textField.onNext("Pari")
	textField.onNext("Paris")
	button.onNext(())
	button.onNext(())
}

// MARK: - sample

example(of: "sample") {
	let button = PublishSubject<Void>()
	let textField = PublishSubject<String>()

	let observable = textField.sample(button)
	_ = observable.subscribe(onNext: { print($0) })

	textField.onNext("Par")
	textField.onNext("Pari")
	textField.onNext("Paris")
	button.onNext(())
	button.onNext(())
}

// MARK: - amb (ambiguous)

example(of: "amb") {
	let left = PublishSubject<String>()
	let right = PublishSubject<String>()

	let observable = left.amb(right)
	_ = observable.subscribe(onNext: { print($0) })

	left.onNext("Lisbon")
	right.onNext("Copenhagen")
	left.onNext("London")
	left.onNext("Madrid")
	right.onNext("Vienna")

	left.onCompleted()
	right.onCompleted()
}

// MARK: - switchLatest

example(of: "switchLatest") {
	let one = PublishSubject<String>()
	let two = PublishSubject<String>()
	let three = PublishSubject<String>()

	let source = PublishSubject<Observable<String>>()

	let observable = source.switchLatest()
	let disposable = observable.subscribe(onNext: { print($0) })

	source.onNext(one)
	one.onNext("Some text from sequence one")
	two.onNext("Some text from sequence two")

	source.onNext(two)
	two.onNext("More text from sequence two")
	one.onNext("and also from sequence one")

	source.onNext(three)
	two.onNext("Why don't you see me?")
	one.onNext("I'm alone, help me")
	three.onNext("Hey it's three. I win.")

	source.onNext(one)
	one.onNext("Nope. It's me, one!")

	disposable.dispose()
}

// MARK: - reduce

example(of: "reduce") {
	let source = Observable.of(1, 3, 5, 7, 9)

/*
 let observable = source.reduce(0, accumulator: +)

 is equivalent to:
 */

	let observable = source.reduce(0) { summary, newValue in
		summary + newValue
	}
	_ = observable.subscribe(onNext: { print($0) })
}

// MARK: - scan

example(of: "scan") {
	let source = Observable.of(1, 3, 5, 7, 9)
	
	let observable = source.scan(0, accumulator: +)
	
	// is equivalent to:
	/*
	 let observable = source.scan(0) { summary, newValue in
	 summary + newValue
	 }
	 */
	_ = observable.subscribe(onNext: { print($0) })
}
