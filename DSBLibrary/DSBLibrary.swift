//
//  DSBLibrary.swift
//  DSBLibrary
//
//  Created by Nils Bergmann on 03.09.17.
//  Copyright © 2017 Noim. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import Gzip


class DSB {
    
    // Constanten
    private let UserAgent: String = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.32 Safari/537.36";
    
    // Variable Constanten
    let username: String;
    let password: String;
    private let urls: [String: String];
    private let debug: Bool;
    
    // Variablen
    var sessionCookies: [HTTPCookie];
    
    init(with username: String, and password: String, and optionalSessionCookie: [HTTPCookie]?, enableDebug: Bool?) {
        self.username = username;
        self.password = password;
        self.urls = [
            "login": "https://mobile.dsbcontrol.de/dsbmobilepage.aspx",
            "main": "https://www.dsbmobile.de/",
            "Data": "http://www.dsbmobile.de/JsonHandlerWeb.ashx/GetData",
            "default": "https://www.dsbmobile.de/default.aspx",
            "loginV1": "https://iphone.dsbcontrol.de/iPhoneService.svc/DSB/authid/\(self.username)/\(self.password)"
        ];
        
        if let sessionCookie = optionalSessionCookie {
            self.sessionCookies = sessionCookie;
        } else {
            self.sessionCookies = [];
        }
        if let debug = enableDebug {
            self.debug = debug;
        } else {
            self.debug = false;
        }
    }
    
    func login() -> Promise<[HTTPCookie]> {
        //print("Login");
        return Alamofire.request(
            self.urls["login"]!,
            method: .post,
            parameters: [
                "user": self.username,
                "password": self.password
            ],
            headers: [
                "User-Agent": self.UserAgent
            ]
        ).validate(statusCode: 200..<301).response().then {response -> [HTTPCookie] in
            //print("Response: \(response)");
            if let cookies = Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.cookies {
                if cookies.count > 1 {
                    self.self.sessionCookies = cookies;
                    return self.self.sessionCookies;
                } else {
                    throw NSError(domain: "Not enough cookies", code: 3, userInfo: nil);
                }
            } else {
                throw NSError(domain: "No cookies returned", code: 2, userInfo: nil);
            }
        }
    }
    
    func smartFetch() -> Promise<String> {
        if self.sessionCookies.count > 1 {
            return self.justFetch().recover(execute: { (error) -> Promise<String> in
                self.print(message: "Recover justFetch()");
                return self.login().then { _ -> Promise<String> in
                    self.self.print(message: "Login successfully after recover.");
                    return self.justFetch();
                };
            });
        } else {
            self.print(message: "Login")
            return self.login().then { _ -> Promise<String> in
                return self.justFetch();
            };
        }
    }
    
    /*
     A function to just fetch without checking
     */
    private func justFetch() -> Promise<String> {
        return Alamofire.request(
            self.urls["Data"]!,
            method: .post,
            parameters: self.buildData(),
            encoding: JSONEncoding.default,
            headers: [
                "User-Agent": self.UserAgent,
                "Bundle_ID": "de.heinekingmedia.inhouse.dsbmobile.web",
                "Referer": self.urls["main"]!,
                "X-Request-With": "XMLHttpRequest",
                "Cookie": self.sessionCookies.toString()
            ]
        ).responseJSON().then { response -> String in
            let json: Dictionary<String, AnyObject> = response as! Dictionary<String, AnyObject>;
            guard let d: String = json["d"] as? String else {
                throw NSError(domain: "No d in response json", code: 20, userInfo: nil);
            }
            let uncompressedJSON: String = try! self.decodeDSBData(data: d);
            guard let parsedJSON: Dictionary<String, AnyObject> = uncompressedJSON.toJSON() as? Dictionary<String, AnyObject> else {
                throw NSError(domain: "Failed to parse json", code: 21, userInfo: nil);
            }
            guard let ResultCode: Int = parsedJSON["Resultcode"] as? Int else {
                throw NSError(domain: "Failed to get resultcode from json", code: 22, userInfo: nil);
            }
            self.print(message: "justFetch: \(uncompressedJSON)");
            if ResultCode != 0 {
                if let ResultStatusInfo: String = parsedJSON["ResultStatusInfo"] as? String {
                    throw NSError(domain: "Resultcode isn't 0. Code: \(ResultCode) ResultStatusInfo: \(ResultStatusInfo)", code: 24, userInfo: nil);
                } else {
                    throw NSError(domain: "Resultcode isn't 0. Code: \(ResultCode) ResultStatusInfo: nil", code: 24, userInfo: nil);
                }
            }
            return uncompressedJSON;
        };
    }
    
    private func buildData() -> Dictionary<String, Any> {
        let data: String = String(data: try! JSONSerialization.data(withJSONObject: [
            "UserId": "",
            "UserPw": "",
            "Abos": [],
            "AppVersion": "2.3",
            "Language": "de",
            "AppId": "",
            "Device": "WebApp",
            "PushId": "",
            "BundleId": "de.heinekingmedia.inhouse.dsbmobile.web",
            "Date": Date().iso8601,
            "LastUpdate": Date().iso8601,
            "OsVersion": self.UserAgent
            ], options: JSONSerialization.WritingOptions(rawValue: 0)), encoding: .utf8)!;
        return [
            "req": [
                "Data": try! self.encodeDSBData(data: data),
                "DataType": 1
            ]
        ];
    }
    
    func fetch() -> Promise<String> {
        return self.validateLogin(with: self.sessionCookies).then {validate -> Promise<[HTTPCookie]> in
            self.print(message: "Login validation: \(validate)")
            if validate {
                return Promise<[HTTPCookie]> {resolve, reject in
                    resolve(self.sessionCookies);
                };
            } else {
                return self.login();
            }
        }.then {_ -> Promise<String> in
            return self.justFetch();
        };
    }
    
    private func validateLogin(with sessionCookies: [HTTPCookie]?) -> Promise<Bool> {
        var sc: [HTTPCookie];
        if let sessioncookies = sessionCookies {
            sc = sessioncookies;
        } else {
            sc = self.sessionCookies;
        }
        return Alamofire.request(
            self.urls["default"]!,
            method: .get,
            headers: [
                "User-Agent": self.UserAgent,
                "Cookie": sc.toString()
            ]
        ).validate(statusCode: 0..<600).response().then { response -> Bool in
            guard let path = response.1.url?.path else {
                return false;
            }
            self.print(message: path);
            return response.1.statusCode == 200 && path == "/default.aspx";
        }
    }
    
    func decodeDSBData(data: String) throws -> String {
        guard let StringViewBytes: [UInt8] = base64ToByteArray(base64String: data) else {
            throw NSError(domain: "Failed to convert base64 to byte array", code: 10, userInfo: nil);
        }
        let compressedData: Data = Data(StringViewBytes);
        let decompressed: Data = try compressedData.gunzipped()
        guard let decompressedString: String = String(data: decompressed, encoding: .utf8) else {
            throw NSError(domain: "Failed to create string from uncompressed data", code: 12, userInfo: nil);
        }
        return decompressedString;
    }
    
    func encodeDSBData(data: String) throws -> String {
        let StringViewBytes: [UInt8] = Array(data.utf8);
        let StringData: Data = Data(StringViewBytes);
        let compressedData: Data = try StringData.gzipped();
        let base64String: String = compressedData.base64EncodedString();
        return base64String;
    }

    private func base64ToByteArray(base64String: String) -> [UInt8]? {
        guard let data: Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            return nil;
        }
        return [UInt8](data);
    }
    
    private func print(message: String) {
        if self.debug {
            Swift.print(message);
        }
    }
    
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

extension HTTPCookie {
    func toString() -> String {
        return "\(self.name)=\(self.value); "
    }
}

extension Array where Element : HTTPCookie {
    func toString() -> String {
        var cookies: String = "";
        for c in self {
            cookies += c.toString();
        }
        return cookies;
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
