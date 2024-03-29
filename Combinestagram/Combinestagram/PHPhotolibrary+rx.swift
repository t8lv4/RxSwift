//
//  PHPhotolibrary+rx.swift
//  Combinestagram
//
//  Created by Morgan on 20/03/2024.
//  Copyright © 2024 Underplot ltd. All rights reserved.
//

import Foundation
import Photos
import RxSwift

extension PHPhotoLibrary {
	static var authorized: Observable<Bool> {
		Observable.create { observer in
			if authorizationStatus() == .authorized {
				observer.onNext(true)
				observer.onCompleted()
			} else {
				observer.onNext(false)
				requestAuthorization { newStatus in
					observer.onNext(newStatus == .authorized)
					observer.onCompleted()
				}
			}

			return Disposables.create()
		}
	}
}
