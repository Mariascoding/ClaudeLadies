//
//  MoonResponse.swift
//  LadiesApp
//
//  Created by Marta Maria Ries on 12/15/25.
//


struct MoonResponse: Decodable {
    let daily: MoonDaily
}

struct MoonDaily: Decodable {
    let time: [String]
    let moon_phase: [Double]
}
