//
//  CaptionTimeCollection.swift
//  VoiceTube_iOS
//
//  Created by drain on 20/07/2017.
//  Copyright © 2017 VoiceTube. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct CaptionTime {
    let startTime: CGFloat
    let endTime: CGFloat
}

class CaptionTimeCollection {

    public lazy var currentIndexAndTime: Variable<(Int, CaptionTime)> = {
        let indexAndTimeIndex: (Int, CaptionTime) = (0, self.captionTimes[0])
        return Variable<(Int, CaptionTime)>(indexAndTimeIndex)
    }()

    private let disposeBag = DisposeBag()

    private let captionTimes: [CaptionTime]

    init(withTimeDriver driver: Driver<CGFloat>, captionTimes: [CaptionTime]) {
        self.captionTimes = captionTimes
        driver
            .drive(onNext: { [weak self] time in
                guard let `self` = self else { return }
                let currentIndex = self.currentIndexAndTime.value.0
                let newIndex = self.findIndex(withTime: time, currentIndex: currentIndex)
                if currentIndex != newIndex {
                    self.currentIndexAndTime.value = (newIndex, self.captionTimes[newIndex])
                }
            }).disposed(by: disposeBag)
    }

    func findIndex(withTime time: CGFloat, currentIndex: Int) -> Int {

        if time >= captionTimes[currentIndex].startTime {
            if (currentIndex != captionTimes.count - 1) &&
                (time > captionTimes[currentIndex + 1].startTime) {
                return findIndex(withTime: time, currentIndex: currentIndex + 1)
            } else {
                return currentIndex
            }
        } else {
            if currentIndex == 0 {
                return currentIndex
            } else {
                return findIndex(withTime: time, currentIndex: currentIndex - 1)
            }
        }
    }
}
