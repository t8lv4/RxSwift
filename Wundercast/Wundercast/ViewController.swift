import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
  @IBOutlet private var searchCityName: UITextField!
  @IBOutlet private var tempLabel: UILabel!
	@IBOutlet private var tempSwitch: UISwitch!
  @IBOutlet private var humidityLabel: UILabel!
  @IBOutlet private var iconLabel: UILabel!
  @IBOutlet private var cityNameLabel: UILabel!

	private let bag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    style()

		let textSearch = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
		let temperature = tempSwitch.rx.controlEvent(.valueChanged).asObservable()

		let search = Observable
			.merge(textSearch, temperature)
			.map { self.searchCityName.text ?? "" }
			.filter { !$0.isEmpty }
			.flatMapLatest { text in
				ApiController.shared
					.currentWeather(for: text)
					.catchErrorJustReturn(.empty)
			}
			.share(replay: 1)
			.asDriver(onErrorJustReturn: .empty)

		search.map {
			let celsius = $0.temperature
			let farenheit = Int(Double($0.temperature) * 1.8 + 32)
			return self.tempSwitch.isOn ? "\(celsius)° C" : "\(farenheit)° F"
		}
			.drive(tempLabel.rx.text)
			.disposed(by: bag)

		search.map(\.icon)
			.drive(iconLabel.rx.text)
			.disposed(by: bag)

		search.map { "\($0.humidity)%" }
			.drive(humidityLabel.rx.text)
			.disposed(by: bag)

		search.map(\.cityName)
			.drive(cityNameLabel.rx.text)
			.disposed(by: bag)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    Appearance.applyBottomLine(to: searchCityName)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Style

  private func style() {
    view.backgroundColor = UIColor.aztec
    searchCityName.attributedPlaceholder = NSAttributedString(string: "City's Name",
                                                              attributes: [.foregroundColor: UIColor.textGrey])
    searchCityName.textColor = UIColor.ufoGreen
    tempLabel.textColor = UIColor.cream
    humidityLabel.textColor = UIColor.cream
    iconLabel.textColor = UIColor.cream
    cityNameLabel.textColor = UIColor.cream
  }
}
