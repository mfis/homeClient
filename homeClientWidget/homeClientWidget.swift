//
//  homeClientWidget.swift
//  homeClientWidget
//
//  Created by Matthias Fischer on 18.07.21.
//

import WidgetKit
import SwiftUI
import Foundation

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), model: nil)
    }
 
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), model: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        let now = Date()
        let reloadDate = Calendar.current.date(byAdding: .minute, value: 30, to: now)!
        
        func onError(msg : String, rc : Int){
            NSLog("getTimeline - onError: \(rc) - \(msg)")
            let timeline = Timeline(entries: entries, policy: .after(reloadDate))
            entries.append(SimpleEntry(date: now, model: nil))
            completion(timeline)
        }
        
        func onSuccess(response : String, newToken : String?){
            // NSLog("getTimeline - onSuccess")
            let decoder = JSONDecoder ()
            do{
            let newModel = try decoder.decode(HomeViewModel.self, from: response.data(using: .utf8)!)
                entries.append(SimpleEntry(date: now, model: newModel))
                // entries.append(SimpleEntry(date: now, model: nil)) // TODO
                let timeline = Timeline(entries: entries, policy: .after(reloadDate))
                completion(timeline)
            } catch let jsonError as NSError {
                onError(msg : "error parsing json document. \(jsonError.localizedDescription)", rc : -2)
            }
        }
        
        // NSLog("Widget calling model \(!loadRefreshState()): \(loadUserName()) Token: \(loadUserToken().prefix(20))")
        
        if(!loadUserToken().isEmpty && !loadRefreshState()){
            let authDict = ["appUserName": loadUserName(), "appUserToken": loadUserToken(), "appDevice" : "HomeClientAppWebView"]
            httpCall(urlString: loadUrl() + "getAppModel?viewTarget=widget", pin: nil, timeoutSeconds: 6.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let model: HomeViewModel?
}

struct homeClientWidgetEntryView : View {
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack() {
            WidgetTitleView(model: entry.model)
            if let model = entry.model{
                ForEach(model.places) { place in
                    if(showItem(id: place.id, widgetFamily: family)){
                        WidgetPlaceView(place: place)
                    }
                }
            } else{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color.gray)
                                .frame(height: 18)
                                .padding(.horizontal, 30)
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color.gray)
                                .frame(height: 18)
                                .padding(.horizontal, 10)
            }
            Spacer()
        }.background(colorScheme == .dark ? Color.init(hexString: "111111", defaultHexString: "") : Color.white)
    }
}

struct WidgetTitleView : View {
    var model : HomeViewModel?
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.init(hexString: "5cb85c", defaultHexString: ""))
                .frame(height: 36)
            HStack{
                Image("zuhause")
                    .resizable()
                        .frame(width: 24.0, height: 24.0)
                Text(model?.timestamp ?? "")
                    .fontWeight(.light)
                    .font(.caption)
                    .padding(.top, 5)
                    .foregroundColor(Color.black)
            }
        }.padding(.top, 0)
    }
}

struct WidgetPlaceView : View {
    var place : HomeViewPlaceModel
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Text(place.name)
            .font(.caption)
            .padding(.top, 1)
        HStack() {
            ForEach(place.values) { value in
                VStack{
                    if (family == .systemSmall) {
                        Text(value.key).font(.caption)
                    }
                    HStack {
                        if (family != .systemSmall) {
                            Text(value.key).font(.caption)
                        }
                        Text(value.value + String.init(tendency:value.tendency))
                            .padding(.horizontal, 0)
                            .font(.subheadline)
                            .foregroundColor(Color.init(hexString: value.accent, defaultHexString: (colorScheme == .dark ? "ffffff" : "000000")))
                    }
                }
            }
        }
    }
}

func showItem(id: String, widgetFamily: WidgetFamily) -> Bool {
    switch widgetFamily {
    case .systemSmall:
        return !id.contains("-notSmall")
    case .systemMedium:
        return !id.contains("-notMedium")
    case .systemLarge:
        return !id.contains("-notLarge")
    default:
        return true
    }
}

@main
struct homeClientWidget: Widget {
    let kind: String = "homeClientWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            homeClientWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Zuhause")
        .description("Zuhause")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct homeClientWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let valA1 = HomeViewValueModel(id:"va1", key: "Wärme", value: "23,0°C", tendency: "EQUAL")
        let valA2 = HomeViewValueModel(id:"va2", key: "Feuchte", value: "65%rH", tendency: "↑")
        
        let valB1 = HomeViewValueModel(id:"vb1", key: "Wärme", value: "20,0-21,5°C", accent: "5cb85c", tendency: "↓")
        
        let valC1 = HomeViewValueModel(id:"vc1", key: "Fenster", value: "geschlossen", tendency: "")
        let valC2 = HomeViewValueModel(id:"vc2", key: "Haustür", value: "verriegelt", tendency: "")
        
        let placeA = HomeViewPlaceModel(id: "a", name: "Draußen", values: [valA1, valA2], actions: [])
        let placeB = HomeViewPlaceModel(id: "b", name: "Obergeschoß", values: [valB1], actions: [])
        let placeC = HomeViewPlaceModel(id: "c-notSmall", name: "Fenster und Türen", values: [valC1, valC2], actions: [])
        
        let model: HomeViewModel = HomeViewModel(timestamp: "12:34", defaultAccent: "ffffff", places: [placeA, placeB, placeC])
        
        Group {
        homeClientWidgetEntryView(entry: SimpleEntry(date: Date(), model: model))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        homeClientWidgetEntryView(entry: SimpleEntry(date: Date(), model: model))
            .previewContext(WidgetPreviewContext(family: .systemMedium)).preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        homeClientWidgetEntryView(entry: SimpleEntry(date: Date(), model: nil))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
