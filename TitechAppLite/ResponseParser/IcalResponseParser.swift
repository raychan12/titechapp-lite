//
//  IcalResponseParser.swift
//  TitechAppLite
//
//  Created by 柳田 涼華 on 2020/09/06.
//  Copyright © 2020 Lei. All rights reserved.
//

import Foundation

struct IcalResponseParser {
    static func parse(data: Data) -> [IcalLecture] {
        let icalString = String(data: data, encoding: .utf8) ?? ""
        let setLectures = icalString.components(separatedBy: "\nBEGIN:VEVENT")
        var result: [IcalLecture] = []
        for setLecture in setLectures {
            let lines = setLecture.components(separatedBy: "\n")
            if lines[0] == "BEGIN:VCALENDAR" {
                continue
            }
            if lines.count < 8 {
                continue
            }
            
            var id: String = ""
            var name: String = ""
            var startTime: String = ""
            var finishTime: String = ""
            var explain: String = ""
            var place: String = ""
            
            for i in 0...lines.count-1 {
                if lines[i].hasPrefix("UID") {
                    id = lines[i].replacingOccurrences(of: "UID:", with: "")
                } else if lines[i].hasPrefix("SUMMARY") {
                    name = lines[i].replacingOccurrences(of: "SUMMARY:", with: "")
                } else if lines[i].hasPrefix("DTSTART") {
                    startTime = lines[i].replacingOccurrences(of: "DTSTART;TZID=Asia/Tokyo:", with: "")
                } else if lines[i].hasPrefix("DTEND") {
                    finishTime = lines[i].replacingOccurrences(of: "DTEND;TZID=Asia/Tokyo:", with: "")
                } else if lines[i].hasPrefix("DESCRIPTION") {
                    explain = lines[i].replacingOccurrences(of: "DESCRIPTION:", with: "")
                } else if lines[i].hasPrefix("LOCATION") {
                    place = lines[i].replacingOccurrences(of: "LOCATION:", with: "")
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
            guard let startDate = dateFormatter.date(from: startTime) else {
                continue
            }
            guard let finishDate = dateFormatter.date(from: finishTime) else {
                continue
            }
            
            result += [IcalLecture(id: id, name: name, startDate: startDate, finishDate: finishDate, explain: explain, place: place)]
            
        }
        
        return result
        
    }
}
