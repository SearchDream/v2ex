//
//  HomeViewModel.swift
//  V2EX
//
//  Created by darker on 2017/3/29.
//  Copyright © 2017年 darker. All rights reserved.
//

import RxSwift
import Moya

class HomeViewModel {
    let sections = Variable<[TopicListSection]>([])
    let defaultNodes = Variable<[Node]>([])
    var nodesNavigation: [(name: String, content: String)] = []
    let loadingActivityIndicator = ActivityIndicator()
    
    var nodeHref: String = ""
    private let disposeBag = DisposeBag()
    
    func fetchTopics() -> Observable<Bool> {
        return API.provider.request(API.topics(nodeHref: nodeHref)).flatMapLatest({response -> Observable<Bool> in
            if self.defaultNodes.value.isEmpty {
                let nodes = HTMLParser.shared.homeNodes(html: response.data)
                self.defaultNodes.value = nodes
            }
            if self.nodesNavigation.isEmpty {
                let navigation = HTMLParser.shared.nodesNavigation(html: response.data)
                self.nodesNavigation = navigation
            }
            let topics = HTMLParser.shared.homeTopics(html: response.data)
            self.sections.value = [TopicListSection(header: "home", topics: topics)]
            return Observable.just(topics.isEmpty)
        }).share(replay: 1).observeOn(MainScheduler.instance).trackActivity(loadingActivityIndicator)
    }
    
    func removeTopic(for id: String) {
        if sections.value.isEmpty {
            return
        }
        if let index = sections.value[0].topics.firstIndex(where: {$0.id == id}) {
            sections.value[0].topics.remove(at: index)
        }
    }
}
