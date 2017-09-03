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
import DeflateSwift

class DSB {
    
    // Constanten
    let UserAgent: String = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.32 Safari/537.36";
    
    // Variable Constanten
    let username: String;
    let password: String;
    let urls: [String: String];
    
    // Variablen
    var sessionCookie: [HTTPCookie];
    
    init(with username: String, and password: String, and optionalSessionCookie: [HTTPCookie]?) {
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
            self.sessionCookie = sessionCookie;
        } else {
            self.sessionCookie = [];
        }
    }
    
    func login() -> Promise<[HTTPCookie]> {
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
            if let cookies = HTTPCookieStorage.shared.cookies {
                if cookies.count > 1 {
                    self.self.sessionCookie = cookies;
                    return self.self.sessionCookie;
                } else {
                    throw NSError(domain: "Not enough cookies", code: 3, userInfo: nil);
                }
            } else {
                throw NSError(domain: "No cookies returned", code: 2, userInfo: nil);
            }
        }
    }
    
    func decodeDSBData(data: String) throws -> String {
        guard let StringViewBytes: [UInt8] = base64ToByteArray(base64String: data) else {
            throw NSError(domain: "Failed to convert base64 to byte array", code: 10, userInfo: nil);
        }
        
        var inflater = InflateStream()
        var (inflated, err) = inflater.write(bytes: StringViewBytes, flush: true)
        
        if err != nil{
            throw NSError(domain: "An error occurred: \(err)", code: 11, userInfo: nil);
        }
        
        return "";
    }
    
    // Src: https://stackoverflow.com/questions/28902455/convert-base64-string-to-byte-array-like-c-sharp-method-convert-frombase64string
    private func base64ToByteArray(base64String: String) -> [UInt8]? {
        if let nsdata = NSData(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            var bytes = [UInt8](repeating: 0, count: nsdata.length)
            nsdata.getBytes(&bytes)
            return bytes
        }
        return nil;
    }
    
}

extension String {
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
