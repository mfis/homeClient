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
            let authDict = ["appUserName": loadUserName(), "appUserToken": loadUserToken(), "appDevice" : CONST_WEBVIEW_USERAGENT]
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
    
    fileprivate func getLockscreenCircularValue(model : HomeViewModel) -> HomeViewValueModel?{
        for place in model.places{
            if(place.placeDirectives.contains(CONST_PLACE_DIRECTIVE_WIDGET_LOCKSCREEN_CIRCULAR)){
                for value in place.values{
                    if(!value.valueDirectives.contains(CONST_VALUE_DIRECTIVE_LOCKSCREEN_SKIP)){
                        return value
                    }
                }
            }
        }
        return nil
    }
    
    fileprivate func HomeScreenWidget() -> some View {
        
        var columns = [
            GridItem(.flexible())
        ]
        if(family != .systemSmall){
            columns.append(GridItem(.flexible()))
        }
        
        return VStack(spacing: 0) {
            WidgetTitleView(model: entry.model)
            if let model = entry.model{
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(model.places) { place in
                        if(showPlaceAsLabel(placeDirectives: place.placeDirectives, widgetFamily: family)){
                            WidgetPlaceView(place: place)
                        }
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
        }.background(Color.init(hexOrName: ".black"))
    }
    
    fileprivate func LockScreenWidget() -> some View {
        return ZStack{
            Color.black
            if let model = entry.model, let data = getLockscreenCircularValue(model: model) {
                Image("zuhause").resizable()
                    .frame(width: 20.0, height: 20.0)
                    .offset(y: -12).brightness(1)
                HStack(spacing: 2){
                    Text(data.valueShort)
                        .font(.subheadline.weight(.medium))
                        .offset(y: 8)
                        .dynamicTypeSize(.medium)
                    if(data.symbol.isEmpty){
                        Text(String.init(shortTendency: data.tendency))
                            .font(.subheadline.weight(.medium))
                            .offset(y: 8)
                            .dynamicTypeSize(.medium)
                    } else {
                        Image(systemName: data.symbol)
                            .resizable()
                            .scaledToFit()
                            .offset(y: 8)
                            .frame(width: 14, height: 14)
                            .padding(0)
                    }
                }
            }else{
                Image("zuhause").resizable()
                    .frame(width: 28.0, height: 28.0).brightness(1)
            }
        }
    }
    
    var body: some View {
        if(family == .accessoryCircular || family == .accessoryInline || family == .accessoryRectangular){
            LockScreenWidget()
        }else{
            HomeScreenWidget()
        }
    }
}

struct WidgetTitleView : View {
    var model : HomeViewModel?
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.init(hexOrName: ".green", darker: true))
                .frame(height: 28)
            HStack{
                Image("zuhause")
                    .resizable()
                    .frame(width: 22.0, height: 22.0)
                    .padding(.leading, 10).padding(.trailing, 0)
                Text(model?.timestamp ?? "")
                    .fontWeight(.light)
                    .font(.caption)
                    .padding(.top, 5).padding(.leading, 0)
                    .foregroundColor(Color.black)
                    .dynamicTypeSize(.medium)
                Spacer()
                
                if let model = model{
                    ForEach(model.places) { place in
                        if(showPlaceAsSymbol(placeDirectives: place.placeDirectives)){
                            ForEach(place.values) { value in
                                if(showSymbol(valueDirectives: value.valueDirectives) && !value.symbol.isEmpty){
                                    ZStack{
                                        Image(systemName: value.symbol)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color.init(hexOrName: "", defaultHexOrName: ".black", darker: true))
                                            .frame(width: 14, height: 14)
                                    }.padding(.top, 2)
                                }
                            }
                            Text("")
                                .font(.caption)
                                .padding(.leading, 5)
                                .dynamicTypeSize(.medium)
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
    var body: some View {
        Link(destination: URL(string: "homeclient://linkX_" + place.id)!) {
            VStack(spacing: 0) {
                Text(place.name)
                    .font(.subheadline)
                    .padding(.top, 5).padding(.bottom, 0)
                    .foregroundColor(Color.white)
                    .dynamicTypeSize(.medium)
                HStack() {
                    ForEach(place.values) { value in
                        if(showValueAsLabel(valueDirectives: value.valueDirectives)){
                            VStack(spacing: 0){
                                Text(value.key).font(.caption).foregroundColor(Color.white)
                                    .padding(0)
                                    .dynamicTypeSize(.medium)
                                HStack(spacing: 4){
                                    Text(value.value)
                                        .font(.subheadline)
                                        .foregroundColor(Color.init(hexOrName: value.accent, defaultHexOrName: ".white"))
                                        .dynamicTypeSize(.medium)
                                    if(value.symbol.isEmpty){
                                        Text(String.init(tendency:value.tendency))
                                            .font(.subheadline)
                                            .foregroundColor(Color.init(hexOrName: value.accent, defaultHexOrName: ".white"))
                                            .dynamicTypeSize(.medium)
                                    } else {
                                        Image(systemName: value.symbol)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color.init(hexOrName: value.accent, defaultHexOrName: ".white"))
                                            .frame(width: 14, height: 14)
                                            .padding(0)
                                    }
                                }.padding(0)
                            }.padding(.top, 0).padding(.bottom, 5).padding(.leading, 4).padding(.trailing, 4) //.background(Color.purple)
                        }
                    }
                }
            }.padding(0)
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

func showValueAsLabel(valueDirectives: [String]) -> Bool {
     
    return !valueDirectives.contains(CONST_VALUE_DIRECTIVE_WIDGET_SKIP)
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
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

struct homeClientWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let WIDGET_LABEL_ALL = [CONST_PLACE_DIRECTIVE_WIDGET_LABEL_SMALL, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_MEDIUM, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_LARGE]
        
        let valA1 = HomeViewValueModel(id:"va1", key: "Wärme", symbol: "arrow.forward.circle", value: "24°C", valueShort: "24,5°", accent: ".orange", tendency: "RISE", valueDirectives: [])
        let valA2 = HomeViewValueModel(id:"va2", key: "2-Tage", symbol: "cloud.rain", value: "3-6....°C", valueDirectives: [])
         
        let valB1 = HomeViewValueModel(id:"vb1", key: "Wärme", value: "20,0-21,5°C", valueShort: "20,0-21,5°C", accent: "66ff66", tendency: "↓", valueDirectives: [])
        
        let valC1 = HomeViewValueModel(id:"vc1", key: "FensterUndTueren", symbol: "lock.fill", value: "geschlossen", accent: ".orange", tendency: "", valueDirectives: [])
        let valC2 = HomeViewValueModel(id:"vc2", key: "Licht", symbol: "sun.max", value: "geschlossen", accent: ".orange", tendency: "", valueDirectives: [])
        let valE1 = HomeViewValueModel(id:"ve1", key: "Netz", value: "12 kW/h", accent: "66ff66", tendency: "", valueDirectives: [])
        let valE2 = HomeViewValueModel(id:"ve2", key: "Last", value: "3 kW", accent: "66ff66", tendency: "", valueDirectives: [])
        
        let placeA = HomeViewPlaceModel(id: "a", name: "Draußen", values: [valA1, valA2], actions: [], placeDirectives: [CONST_PLACE_DIRECTIVE_WIDGET_LABEL_SMALL, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_MEDIUM, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_LARGE, CONST_PLACE_DIRECTIVE_WIDGET_LOCKSCREEN_CIRCULAR])
        let placeB = HomeViewPlaceModel(id: "b", name: "Obergeschoß", values: [valB1], actions: [], placeDirectives: WIDGET_LABEL_ALL)
        let placeC = HomeViewPlaceModel(id: "c", name: "Fenster und Türen", values: [valC1, valC2], actions: [], placeDirectives: [CONST_PLACE_DIRECTIVE_WIDGET_SYMBOL])
        let placeE = HomeViewPlaceModel(id: "e", name: "Strom", values: [valE1, valE2], actions: [], placeDirectives: [CONST_PLACE_DIRECTIVE_WIDGET_LABEL_MEDIUM, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_LARGE])
        
        let modelA: HomeViewModel = HomeViewModel(timestamp: "12:34", defaultAccent: "ffffff", places: [placeA, placeB, placeC, placeE])

        let valD1 = HomeViewValueModel(id:"vd1", key: "Wärme", symbol: "arrow.forward.circle", value: "5°", valueShort: "-15°", accent: ".blue", tendency: "RISE", valueDirectives: [])
        let placeD = HomeViewPlaceModel(id: "d", name: "Draußen", values: [valD1], actions: [], placeDirectives: [CONST_PLACE_DIRECTIVE_WIDGET_LABEL_SMALL, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_MEDIUM, CONST_PLACE_DIRECTIVE_WIDGET_LABEL_LARGE, CONST_PLACE_DIRECTIVE_WIDGET_LOCKSCREEN_CIRCULAR])
        
        let modelB: HomeViewModel = HomeViewModel(timestamp: "12:34", defaultAccent: "ffffff", places: [placeD])
        
        Group {
            homeClientWidgetEntryView(entry: SimpleEntry(date: Date(), model: modelA))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            homeClientWidgetEntryView(entry: SimpleEntry(date: Date(), model: modelA))
                .previewContext(WidgetPreviewContext(family: .systemMedium)).preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
            homeClientWidgetEntryView(entry: SimpleEntry(date: Date(), model: nil))
                    .previewContext(WidgetPreviewContext(family: .systemMedium))
            homeClientWidgetEntryView(entry: SimpleEntry(date: Date(), model: modelA))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            homeClientWidgetEntryView(entry: SimpleEntry(date: Date(), model: modelB))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        }
    }
}
