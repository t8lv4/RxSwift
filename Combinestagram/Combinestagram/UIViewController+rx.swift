//
//  UIViewController+rx.swift
//  Combinestagram
//
//  Created by Morgan on 20/03/2024.
//  Copyright © 2024 Underplot ltd. All rights reserved.
//

import Foundation
import RxSwift

extension UIViewController {
	func alert(title: String, message: String?) -> Completable {
		return Completable.create { [weak self] completable in
			let alert = UIAlertController(title: title, message: self?.description, preferredStyle: .alert)
			alert.addAction(
				UIAlertAction(title: "Close", style: .default, handler: {  _ in completable(.completed) })
			)
			self?.present(alert, animated: true, completion: nil)
			return Disposables.create {
				self?.dismiss(animated: true, completion: nil)
			}
		}
	}
}
