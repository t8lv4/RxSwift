import Foundation
import RxSwift

// MARK: - toArray

example(of: "toArray") {
	let disposeBag = DisposeBag()

	Observable.of("a", "b", "c")
		.toArray()
		.subscribe { print($0) }
		.disposed(by: disposeBag)
}

// MARK: - map

example(of: "map") {
	let disposeBag = DisposeBag()

	let formatter = NumberFormatter()
	formatter.numberStyle = .spellOut

	Observable<Int>.of(123, 4, 56)
		.map {
			formatter.string(for: $0) ?? ""
		}
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

// MARK: - enumerated & map

example(of: "enumerated & map") {
	let disposeBag = DisposeBag()

	Observable.of(1, 2, 3, 4, 5, 6)
		.enumerated()
		.map { index, integer in
			index > 2 ? integer * 2 : integer
		}
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
}

// MARK: - compactMap

example(of: "compactMap") {
	let disposeBag = DisposeBag()

	Observable.of("to", "be", nil, "or", "not", "to", "be", nil)
		.compactMap { $0 }
		.toArray()
		.map { $0.joined(separator: " ") }
		.subscribe(onSuccess: { print($0) })
		.disposed(by: disposeBag)
}

// MARK: - flatMap

struct Student {
	let score: BehaviorSubject<Int>
}

example(of: "flatMap") {
	let disposeBag = DisposeBag()

	let laura = Student(score: BehaviorSubject(value: 80))
	let charlotte = Student(score: BehaviorSubject(value: 90))

	let student = PublishSubject<Student>()

	student
		.flatMap { $0.score }
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)

	student.onNext(laura)
	laura.score.onNext(85)
	student.onNext(charlotte)
	laura.score.onNext(95)
	charlotte.score.onNext(100)
}

// MARK: - flatMapLatest

example(of: "flatMapLatest") {
	let disposeBag = DisposeBag()

	let laura = Student(score: BehaviorSubject(value: 80))
	let charlotte = Student(score: BehaviorSubject(value: 90))

	let student = PublishSubject<Student>()

	student
		.flatMapLatest { $0.score }
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)

	student.onNext(laura)
	laura.score.onNext(85)
	student.onNext(charlotte) // subscription to laura is over
	laura.score.onNext(95)
	charlotte.score.onNext(100)
}

// MARK: - materialize & dematerialize

example(of: "materialize and dematerialize") {
	enum MyError: Error {
		case anError
	}

	let disposeBag = DisposeBag()

	let laura = Student(score: BehaviorSubject(value: 80))
	let charlotte = Student(score: BehaviorSubject(value: 100))

	let student = BehaviorSubject(value: laura)

	let studentScore = student
		.flatMapLatest {
			$0.score.materialize()
		}

	studentScore
		.filter {
			guard $0.error == nil else {
				print($0.error!)
				return false
			}

			return true
		}
		.dematerialize()
		.subscribe(onNext: {
			print($0)
		})
		.disposed(by: disposeBag)

	laura.score.onNext(85)
	laura.score.onError(MyError.anError)
	laura.score.onNext(90)

	student.onNext(charlotte)
}

