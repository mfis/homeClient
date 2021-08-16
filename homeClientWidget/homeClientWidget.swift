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
            let decoder = JSONDecoder ()
            do{
            let newModel = try decoder.decode(HomeViewModel.self, from: response.data(using: .utf8)!)
                entries.append(SimpleEntry(date: now, model: newModel))
                let timeline = Timeline(entries: entries, policy: .after(reloadDate))
                completion(timeline)
            } catch let jsonError as NSError {
                onError(msg : "error parsing json document. \(jsonError.localizedDescription)", rc : -2)
            }
        }
        
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
                    if(showPlaceAsLabel(placeDirectives: place.placeDirectives, widgetFamily: family)){
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
                    .frame(width: 28.0, height: 28.0)
                    .padding(.leading, 10)
                Text(model?.timestamp ?? "")
                    .fontWeight(.light)
                    .font(.caption)
                    .padding(.top, 5)
                    .foregroundColor(Color.black)
                Spacer()
                
                if let model = model{
                    ForEach(model.places) { place in
                        if(showPlaceAsSymbol(placeDirectives: place.placeDirectives)){
                            ForEach(place.values) { value in
                                ZStack{
                                    Circle()
                                        .strokeBorder(Color.init(hexString: "285028", defaultHexString: ""), lineWidth: 1.5)
                                        .background(Circle().foregroundColor(Color.init(hexString: value.accent, defaultHexString: "", darker: true)))
                                        .frame(width: 24, height: 24)
                                    Image(systemName: value.symbol)
                                        .resizable()
                                        .foregroundColor(.black)
                                        .frame(height: 14)
                                        .scaledToFit()
                                }.padding(.trailing, 10)
                            }
                        }
                    }
                }
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
                            .foregroundColor(Color.init(hexString: value.accent, defaultHexString: (colorScheme == .dark ? "ffffff" : "000000"), darker: colorScheme == .light))
                    }
                }
            }
        }
    }
}

func showPlaceAsLabel(placeDirectives: [String], widgetFamily: WidgetFamily) -> Bool {
    
    switch widgetFamily {
    case .systemSmall:
        return placeDirectives.contains(CONST_PLACE_DIRECTIVE_WIDGET_LABEL_SMALL)
    case .systemMedium:
        return placeDirectives.contains(CONST_PLACE_DIRECTIVE_WIDGET_LABEL_MEDIUM)
    case .systemLarge:
        return placeDirectives.contains(CONST_PLACE_DIRECTIVE_WIDGET_LABEL_LARGE)
    default:
        return false
    }
}

func showPlaceAsSymbol(placeDirectives: [String]) -> Bool {
    
    return placeDirectives.contains(CONST_PLACE_DIRECTIVE_WIDGET_SYMBOL)
}

func showSymbol(valueDirectives: [String]) -> Bool {
    
    return !valueDirectives.contains(CONST_VALUE_DIRECTIVE_SYMBOL_SKIP)
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
        
        let WIDGET_LABEL_ALL = [CONST_PLACE_DIRECTIVE_WIDGET_LABEL_SMALL, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_MEDIUM, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_LARGE]
        
        let valA1 = HomeViewValueModel(id:"va1", key: "Wärme", value: "24,0°C", accent: "ffb84d", tendency: "EQUAL", valueDirectives: [])
        let valA2 = HomeViewValueModel(id:"va2", key: "Feuchte", value: "65%rH", tendency: "↑", valueDirectives: [])
        
        let valB1 = HomeViewValueModel(id:"vb1", key: "Wärme", value: "20,0-21,5°C", accent: "66ff66", tendency: "↓", valueDirectives: [])
        
        let valC1 = HomeViewValueModel(id:"vc1", key: "FensterUndTueren", symbol: "lock", value: "geschlossen", accent: "66ff66", tendency: "", valueDirectives: [])
        
        let placeA = HomeViewPlaceModel(id: "a", name: "Draußen", values: [valA1, valA2], actions: [], placeDirectives: WIDGET_LABEL_ALL)
        let placeB = HomeViewPlaceModel(id: "b", name: "Obergeschoß", values: [valB1], actions: [], placeDirectives: WIDGET_LABEL_ALL)
        let placeC = HomeViewPlaceModel(id: "c", name: "Fenster und Türen", values: [valC1], actions: [], placeDirectives: [CONST_PLACE_DIRECTIVE_WIDGET_SYMBOL])
        
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
