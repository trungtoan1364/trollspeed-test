//
//  WidgetPreviewsView.swift
//  Helium UI
//
//  Created by lemin on 10/16/23.
//

import Foundation
import SwiftUI

struct WidgetPreviewsView: View {
    @Binding var widget: WidgetIDStruct
    @State var text: String = ""
    @State var image: Image?
    @State var previewColor: Color = .primary
    
    var body: some View {
        HStack {
            ZStack {
                Image(uiImage: UIImage(named: "wallpaper")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(1.5)
                    .frame(width: 125, height: 50)
                    .cornerRadius(12)
                    .clipped()
                ZStack {
                    if image == nil {
                        Text(text)
                            .padding(.vertical, 5)
                            .foregroundColor(previewColor)
                            .minimumScaleFactor(0.01)
                    } else {
                        Text(image!)
                            .padding(.vertical, 5)
                            .foregroundColor(previewColor)
                            .minimumScaleFactor(0.01)
                    }
                }
                .frame(width: 125, height: 50)
            }
            .padding(.trailing, 5)
        }
        .onAppear {
            updatePreview()
        }
        .onChange(of: widget.modified) { nv in
            if nv {
                updatePreview()
            }
        }
    }
    
    func updatePreview() {
        switch (widget.module) {
        case .dateWidget, .timeWidget:
            let dateFormat: String = widget.config["dateFormat"] as? String ?? (widget.module == .dateWidget ? NSLocalizedString("E MMM dd", comment:"") : "hh:mm")
            let dateFormatter = DateFormatter()
            let newDateFormat = LunarDate.getChineseCalendar(with: Date(), format: dateFormat)
            dateFormatter.dateFormat = newDateFormat
            let locale = UserDefaults.standard.string(forKey: "dateLocale", forPath: USER_DEFAULTS_PATH) ?? "en_US"
            dateFormatter.locale = Locale(identifier: locale)
            text = dateFormatter.string(from: Date())
            // SAFEGUARD
            if (text == "") {
                text = NSLocalizedString("ERROR", comment:"")
            }
        case .network:
            let isUp: Bool = widget.config["isUp"] as? Bool ?? false
            let speedIcon: Int = widget.config["speedIcon"] as? Int ?? 0
            text = "\(isUp ? (speedIcon == 0 ? "▲" : "↑") : (speedIcon == 0 ? "▼" : "↓")) 30 KB/s"
        case .temperature:
            text = widget.config["useFahrenheit"] as? Bool ?? false ? "78.84ºF" : "26.02ºC"
        case .battery:
            let batteryValue: Int = widget.config["batteryValueType"] as? Int ?? 0
            switch (batteryValue) {
            case 0:
                text = "0 W"
            case 1:
                text = "0 mA"
            case 2:
                text = "0 mA"
            case 3:
                text = "25"
            default:
                text = "???"
            }
        case .textWidget:
            text = widget.config["text"] as? String ?? NSLocalizedString("Unknown", comment:"")
            break;
        case .weather:
            text = NSLocalizedString("Weather Preview", comment:"")
            break;
        case .currentCapacity:
            text = "50\(widget.config["showPercentage"] as? Bool ?? true ? "%" : "")"
        case .chargeSymbol:
            image = widget.config["filled"] as? Bool ?? true ? Image(systemName: "bolt.fill") : Image(systemName: "bolt")
        }
        widget.modified = false
    }
}
