//
//  Completable.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import Combine

protocol Completable {
    var didComplete: PassthroughSubject<Self, Never> { get }
}
