import Foundation
import RxSwift

/*
 ### phone number lookup ###

 Phone numbers can’t begin with 0 — use skipWhile.
 Each input must be a single-digit number — use filter to only allow elements that are less than 10.
 Limiting this example to U.S. phone numbers, which are 10 digits, take only the first 10 numbers — use take and toArray.
 */

example(of: "challenge 1") {
	let disposeBag = DisposeBag()

	let contacts = [
		"603-555-1212": "Florent",
		"212-555-1212": "Shai",
		"408-555-1212": "Marin",
		"617-555-1212": "Scott"
	]

	func phoneNumber(from inputs: [Int]) -> String {
		var phone = inputs.map(String.init).joined()

		phone.insert("-", at: phone.index(
			phone.startIndex,
			offsetBy: 3)
		)

		phone.insert("-", at: phone.index(
			phone.startIndex,
			offsetBy: 7)
		)

		return phone
	}

	let input = PublishSubject<Int>()
	input
		.skip(while: { $0 == 0 })
		.filter { $0 < 10 }
		.take(10)
		.toArray()
		.subscribe {
			let phone = phoneNumber(from: $0)
			if let contact = contacts[phone] {
				print("phone number of: ", contact)
			} else {
				print("Contact not found")
			}
		}
		.disposed(by: disposeBag)

	input.onNext(0)
	input.onNext(603)

	input.onNext(2)
	input.onNext(1)
	input.onNext(2)

	"5551212".forEach {
		if let number = (Int("\($0)")) {
			input.onNext(number)
		}
	}

	input.onNext(9)
}
