//
//  ComplicationController.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 19.09.20.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    lazy var data = ComplicationData.shared
    var didReloadFromController = false

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Zuhause", supportedFamilies: CLKComplicationFamily.allCases)
        ]
        
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
    }

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        if(data.valueModel == nil && didReloadFromController == false){
            didReloadFromController = true
            loadComplicationData()
            scheduleComplicationBackgroundRefresh()
        }else{
            didReloadFromController = false
        }
        handler(createTimelineEntry(forComplication: complication, date: Date()))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        handler([])
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(createTemplate(forComplication: complication))
    }
    
    private func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
        let template = createTemplate(forComplication: complication)
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    private func createTemplate(forComplication complication: CLKComplication) -> CLKComplicationTemplate {
        
        // NSLog("Complication: " + complication.family.rawValue.description)
        switch complication.family {
        case .modularSmall:
            return createModularSmallTemplate()
        case .modularLarge:
            return createModularLargeTemplate(complicationData : data)
        case .utilitarianSmall, .utilitarianSmallFlat:
            return createUtilitarianSmallFlatTemplate(complicationData : data)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(complicationData : data)
        case .circularSmall:
            return createCircularSmallTemplate()
        case .extraLarge:
            return createExtraLargeTemplate()
        case .graphicCorner:
            return createGraphicCornerTemplate(complicationData : data)
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularView(CircularView(complicationData: data))
        case .graphicRectangular:
            return createGraphicRectangularTemplate()
        case .graphicBezel:
            return createGraphicBezelTemplate(complicationData : data)
        case .graphicExtraLarge:
            return createGraphicExtraLargeTemplate()
        @unknown default:
            print("unknown complication family:" + complication.family.rawValue.description)
            fatalError("*** Unknown Complication Family ***")
        }
    }
    
    private func imageProvider() -> CLKImageProvider {
        return CLKImageProvider(onePieceImage: UIImage(named: "zuhauseWhite")!)
    }
    
    private func imageProviderFullColor() -> CLKFullColorImageProvider {
        return CLKFullColorImageProvider(fullColorImage: UIImage(named: "zuhauseWithBackground")!)
    }
    
    private func imageProviderCircular() -> CLKComplicationTemplateGraphicCircularImage {
        return CLKComplicationTemplateGraphicCircularImage(imageProvider: imageProviderFullColor())
    }
    
    private func textProvider(complicationData: ComplicationData, short: Bool) -> CLKTextProvider {
        if let cd = complicationData.valueModel{
            if(short){
                return CLKTextProvider(format: cd.value + String.init(tendency:cd.tendency))
            }else{
                return CLKTextProvider(format: cd.value + String.init(tendency:cd.tendency) + " Zuhause")
            }
        }else{
            return CLKTextProvider(format: "Zuhause")
        }
        
    }
    
    private func textProviderLineTwo() -> CLKTextProvider {
        return CLKTextProvider(format: "")
    }
    
    private func createModularSmallTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateModularSmallSimpleImage(imageProvider: imageProvider())
    }
    
    fileprivate func createModularLargeTemplate(complicationData: ComplicationData) -> CLKComplicationTemplate {
        return CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: textProvider(complicationData: complicationData, short: false), body1TextProvider: textProvider(complicationData : complicationData, short: false))
    }
    
    private func createUtilitarianSmallFlatTemplate(complicationData: ComplicationData) -> CLKComplicationTemplate {
        return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: textProvider(complicationData: complicationData, short: true))
    }
    
    private func createUtilitarianLargeTemplate(complicationData: ComplicationData) -> CLKComplicationTemplate {
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: textProvider(complicationData: complicationData, short: false))
    }
    
    private func createCircularSmallTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: imageProvider())
    }
    
    private func createExtraLargeTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateExtraLargeSimpleImage(imageProvider: imageProvider())
    }
    
    private func createGraphicCornerTemplate(complicationData: ComplicationData) -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicCornerTextImage(textProvider: textProvider(complicationData: complicationData, short: false), imageProvider: imageProviderFullColor())
    }
    
    private func createGraphicRectangularTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicRectangularFullImage(imageProvider: imageProviderFullColor())
    }
    
    private func createGraphicBezelTemplate(complicationData: ComplicationData) -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: imageProviderCircular(), textProvider: textProvider(complicationData: complicationData, short: true))
    }
    
    private func createGraphicExtraLargeTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicExtraLargeCircularImage(imageProvider: imageProviderFullColor())
    }
}
