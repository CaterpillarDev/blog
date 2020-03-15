//
//  CaterpillarTheme.swift
//  
//
//  Created by Nikola Matijevic on 15.02.20.
//

import Foundation
import Publish
import Plot

public extension Theme {
    static var caterpillar: Self {
        Theme(
            htmlFactory: CaterpillarHTMLFactory(), resourcePaths: [
                "Resources/CaterpillarTheme/primer.css",
                "Resources/Splash/highlight.css"
            ]
        )
    }
    
}
private struct CaterpillarHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                           context: PublishingContext<Site>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: index, on: context.site, stylesheetPaths: [R.primerPath]),
                .body(
                    .header(for: context, selectedSection: nil),
                    .container(
                        .h4(.text(R.headerTitle)),
                        .h2(.text(R.posts)),
                        .itemList(
                            for: context.allItems(sortedBy: \.date, order: .descending),
                            on: context.site
                        )
                    ),
                    .footer(for: context.site)
                )
            )
        }
    

        func makeSectionHTML(for section: Section<Site>,
                             context: PublishingContext<Site>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: section, on: context.site, stylesheetPaths: [R.primerPath]),
                .body(
                    .footer(for: context.site)
                )
            )
        }

        func makeItemHTML(for item: Item<Site>,
                          context: PublishingContext<Site>) throws -> HTML {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = R.usDateFormat

            return HTML(
                .lang(context.site.language),
                .head(for: item, on: context.site, stylesheetPaths: [R.primerPath, R.highlighPath]),
                .body(
                    .header(for: context, selectedSection: nil),
                    .container(
                        .p(
                            .class("text-small text-gray"),
                            .text(dateFormatter.string(from: item.date))
                        ),
                        .p(
                            .class("text-small text-gray"),
                            .text("Reading time: \((item.metadata as! CaterpillarDev.ItemMetadata).readingTime)mins")
                        ),
                        .contentBody(item.body)
                    ),
                    .footer(for: context.site)
                )
            )
        }

        func makePageHTML(for page: Page,
                          context: PublishingContext<Site>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body(
                    .header(for: context, selectedSection: nil),
                    .container(.contentBody(page.body)),
                    .footer(for: context.site)
                )
            )
        }

        func makeTagListHTML(for page: TagListPage,
                             context: PublishingContext<Site>) throws -> HTML? {
            return nil
        }

        func makeTagDetailsHTML(for page: TagDetailsPage,
                                context: PublishingContext<Site>) throws -> HTML? {
            return nil
        }
    }

    private extension Node where Context == HTML.BodyContext {
        static func container(_ nodes: Node..., marginY: Int = 5) -> Node {
            .div(.class("container-md px-3 my-\(marginY) markdown-body"), .group(nodes))
        }

        static func header<T: Website>(
            for context: PublishingContext<T>,
            selectedSection: T.SectionID?
        ) -> Node {
            .header(
                .div(
                    .class("border-bottom border-gray-light"),
                    .container(
                        .h3(.a(
                            .class("text-gray-dark no-underline"),
                            .text("caterpillar.dev"),
                            .href("/")
                            )
                        ),
                        marginY: 3
                    ),
                    .container(
                        .class("d-flex flex-justify-center"),
                      .p(
                            .class("text-small text-gray v-align-middle"),
                            .text("Reach me on "),
                            .a(
                                .text("LinkedIn"),
                                .href("https://www.linkedin.com/in/nikolamatijevic")
                            ),
                            .text(" or "),
                            .a(
                                .text("Twitter"),
                                .href("https://twitter.com/nmatijevic1")
                            )
                        ),
                        marginY: 3
                    )
                )
            )
        }

        static func itemList<T: Website>(for items: [Item<T>], on site: T) -> Node {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"

            let itemsPerYear: [Int: [Item<T>]] = items.reduce(into: [:]) { result, item in
                result[item.date.year, default: []].append(item)
            }

            return .forEach(itemsPerYear) {
                .div(
                    .h3("\($0.key)"),
                    .forEach($0.value) { item in
                        .div(
                            .class("d-flex flex-justify-between flex-items-center"),
                            .div(.a(
                                .text(item.title),
                                .href(item.path)
                                )
                            ),
                            .div(
                                .class("text-small text-gray"),
                                .text(dateFormatter.string(from: item.date))
                            )
                        )
                    }
                )
            }
        }

        static func footer<T: Website>(for site: T) -> Node {
            return .footer(
                .container(
                    .div(
                        .class("d-flex flex-justify-center"),
                        .p(
                            .class("text-small text-gray v-align-middle"),
                            .text("Styled with "),
                            .a(
                                .text("Primer"),
                                .href("https://primer.style")
                            ),
                            .text(" | Generated using "),
                            .a(
                                .text("Publish"),
                                .href("https://github.com/johnsundell/publish")
                            ),
                            .text(" | Hosted on "),
                            .a(
                                .text("GitHub Pages"),
                                .href("https://pages.github.com")
                            )
                        )
                    )
                )
            )
        }
    }

    private extension Date {
        var year: Int {
            return Calendar.current.component(.year, from: self)
        }
    }

