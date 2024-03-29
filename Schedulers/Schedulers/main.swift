import Foundation
import RxSwift

print("\n===== Schedulers =====\n")

let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
let bag = DisposeBag()
let animal = BehaviorSubject(value: "[dog]")

let fruit = Observable<String>.create { observer in
	observer.onNext("[apple]")
	sleep(2)
	observer.onNext("[pineapple]")
	sleep(2)
	observer.onNext("[strawberry]")
	return Disposables.create()
}

let animalsThread = Thread() {
	sleep(3)
	animal.onNext("[cat]")
	sleep(3)
	animal.onNext("[tiger]")
	sleep(3)
	animal.onNext("[fox]")
	sleep(3)
	animal.onNext("[leopard]")
}

animalsThread.name = "Animals thread"
animalsThread.start()

fruit
	.subscribeOn(globalScheduler)
	.dump()
	.observeOn(MainScheduler.instance)
	.dumpingSubscription()
	.disposed(by: bag)

animal
	.subscribeOn(MainScheduler.instance)
	.dump()
	.observeOn(globalScheduler)
	.dumpingSubscription()
	.disposed(by: bag)

RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))


