//
//  HungryDev.swift
//
//
//  Created by marko on 26.01.20.
//

import Foundation
import Publish
import Plot

struct CaterpillarDev: Website {
    enum SectionID: String, WebsiteSectionID {
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        let date: Date
    }

    var url = URL(string: "caterpillarDev.github.io")!
    var name = "caterpillarDev"
    var description = "Personal blog."
    var language: Language { .english }
    var imagePath: Path? { nil }
}
