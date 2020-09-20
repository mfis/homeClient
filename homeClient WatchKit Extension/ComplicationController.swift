//
//  ComplicationController.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 19.09.20.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Zuhause", supportedFamilies: CLKComplicationFamily.allCases)
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(createTimelineEntry(forComplication: complication, date: Date()))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        handler([createTimelineEntry(forComplication: complication, date: Date())])
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(createTemplate(forComplication: complication))
    }
    
    // MARK: - Complication implementation
    
    private func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
        let template = createTemplate(forComplication: complication)
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    private func createTemplate(forComplication complication: CLKComplication) -> CLKComplicationTemplate {
        switch complication.family {
        case .modularSmall:
            return createModularSmallTemplate()
        case .modularLarge:
            return createModularLargeTemplate()
        case .utilitarianSmall, .utilitarianSmallFlat:
            return createUtilitarianSmallFlatTemplate()
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate()
        case .circularSmall:
            return createCircularSmallTemplate()
        case .extraLarge:
            return createExtraLargeTemplate()
        case .graphicCorner:
            return createGraphicCornerTemplate()
        case .graphicCircular:
            return createGraphicCircleTemplate()
        case .graphicRectangular:
            return createGraphicRectangularTemplate()
        case .graphicBezel:
            return createGraphicBezelTemplate()
        case .graphicExtraLarge:
            return createGraphicExtraLargeTemplate()
        @unknown default:
            fatalError("*** Unknown Complication Family ***")
        }
    }
    
    private func imageProvider() -> CLKImageProvider {
        return CLKImageProvider(onePieceImage: UIImage(named: "zuhauseWithBackground")!)
    }
    
    private func imageProviderFullColor() -> CLKFullColorImageProvider {
        return CLKFullColorImageProvider(fullColorImage: UIImage(named: "zuhauseWithBackground")!)
    }
    
    private func imageProviderCircular() -> CLKComplicationTemplateGraphicCircularImage {
        return CLKComplicationTemplateGraphicCircularImage(imageProvider: imageProviderFullColor())
    }
    
    private func textProvider() -> CLKTextProvider {
        return CLKTextProvider(format: "Zuhause")
    }
    
    private func textProviderLineTwo() -> CLKTextProvider {
        return CLKTextProvider(format: "")
    }
    
    private func createModularSmallTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateModularSmallSimpleImage(imageProvider: imageProvider())
        // return CLKComplicationTemplateGraphicCircularView(CircularView())
    }
    
    private func createModularLargeTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: textProvider(), body1TextProvider: textProvider())
    }
    
    private func createUtilitarianSmallFlatTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: textProvider())
    }
    
    private func createUtilitarianLargeTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: textProvider())
    }
    
    private func createCircularSmallTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: imageProvider())
        // return CLKComplicationTemplateCircularSGraphicCircularView(CircularView())
    }
    
    private func createExtraLargeTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateExtraLargeSimpleImage(imageProvider: imageProvider())
    }
    
    private func createGraphicCornerTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicCornerTextImage(textProvider: textProvider(), imageProvider: imageProviderFullColor())
    }
    
    private func createGraphicCircleTemplate() -> CLKComplicationTemplate {
        // return CLKComplicationTemplateGraphicCircularImage(imageProvider: imageProviderFullColor())
        return CLKComplicationTemplateGraphicCircularView(CircularView())
    }
    
    private func createGraphicRectangularTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicRectangularFullImage(imageProvider: imageProviderFullColor())
    }
    
    private func createGraphicBezelTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: imageProviderCircular(), textProvider: textProvider())
    }
    
    private func createGraphicExtraLargeTemplate() -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicExtraLargeCircularImage(imageProvider: imageProviderFullColor())
    }
}

struct ComplicationController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
