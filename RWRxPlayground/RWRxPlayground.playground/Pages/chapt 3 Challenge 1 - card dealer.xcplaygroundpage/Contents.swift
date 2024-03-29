import Foundation
import RxRelay
import RxSwift

example(of: "PublishSubject") {

	let disposeBag = DisposeBag()
	let dealtHand = PublishSubject<[(String, Int)]>()

	func deal(_ cardCount: UInt) {
		var deck = cards
		var cardsRemaining = deck.count
		var hand = [(String, Int)]()

		for _ in 0..<cardCount {
			let randomIndex = Int.random(in: 0..<cardsRemaining)
			hand.append(deck[randomIndex])
			deck.remove(at: randomIndex)
			cardsRemaining -= 1
		}

		let points = points(for: hand)
		if points > 21 {
			dealtHand.onError(HandError.busted(points: points))
		} else {
			dealtHand.onNext(hand)
		}
	}

	dealtHand
		.subscribe(
			onNext: {
				print(cardString(for: $0), "for ", points(for: $0), " points")
			}, onError: {
				print($0)
			}
		)
	
	deal(3)
}
