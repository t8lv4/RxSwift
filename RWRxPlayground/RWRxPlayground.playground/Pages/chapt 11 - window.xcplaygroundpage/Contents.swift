import UIKit
import RxSwift
import RxCocoa

let elementsPerSecond = 3
let windowTimeSpan: RxTimeInterval = .seconds(4)
let windowMaxCount = 10
let sourceObservable = PublishSubject<String>()

let sourceTimeline = TimelineView<String>.make()

let stack = UIStackView.makeVertical([
	UILabel.makeTitle("window"),
	UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
	sourceTimeline,
	UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec):")])

let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
	sourceObservable.onNext("🐱")
}

_ = sourceObservable.subscribe(sourceTimeline)

//_ = sourceObservable
//	.window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
//	.flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in

// 		##### ###### ####### ###### ##### ##### #####

// 		side effect: a new TimeLineView is created
// 		where only a transformation should occur

// 		##### ###### ####### ###### ##### ##### #####

//		let timeline = TimelineView<Int>.make()
//		stack.insert(timeline, at: 4)
//		stack.keep(atMost: 8)
//		return windowedObservable
//			.map { value in (timeline, value) }
//			.concat(Observable.just((timeline, nil)))
//	}
//	.subscribe(onNext: { tuple in
//		let (timeline, value) = tuple
//		if let value = value {
//			timeline.add(.next(value))
//		} else {
//			timeline.add(.completed(true))
//		}
//	})

// extract the windowed observable itself
let windowedObservable = sourceObservable
	.window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)

// the timeline observable produces a new timeline every time
// windowObservable produces a new observable
let timelineObservable = windowedObservable
	.do(onNext: { _ in
		let timeline = TimelineView<Int>.make()
		stack.insert(timeline, at: 4)
		stack.keep(atMost: 8)
	})
	.map { _ in
		stack.arrangedSubviews[4] as! TimelineView<Int>
	}

// take one of each, guaranteeing that we get the observable
// produced by window AND the latest timeline view creating
_ = Observable
	.zip(windowedObservable, timelineObservable) { obs, timeline in
		(obs, timeline)
	}
	.flatMap { tuple -> Observable<(TimelineView<Int>, String?)> in
		let obs = tuple.0
		let timeline = tuple.1
		return obs
			.map { value in (timeline, value) }
			.concat(Observable.just((timeline, nil)))
	}
	.subscribe(onNext: { tuple in
		let (timeline, value) = tuple
		if let value = value {
			timeline.add(.next(value))
		} else {
			timeline.add(.completed(true))
		}
	})

let hostView = setupHostView()
hostView.addSubview(stack)
hostView

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
	static func make() -> TimelineView<E> {
		let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
		view.setup()
		return view
	}
	public func on(_ event: Event<E>) {
		switch event {
			case .next(let value):
				add(.next(String(describing: value)))
			case .completed:
				add(.completed())
			case .error(_):
				add(.error())
		}
	}
}

