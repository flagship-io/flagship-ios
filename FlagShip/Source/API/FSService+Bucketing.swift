//
//  FSService+Bucketing.swift
//  Flagship
//
//  Created by Adel on 27/10/2021.
//

import Foundation

let FSLastModified = "Last-Modified"
let FSLastModified_Key = "FSLastModifiedScript"
let FS_If_ModifiedSince = "If-Modified-Since"

extension FSService {
    func getFSScript(onGetScript: @escaping (FSBucket?, FlagshipError?) -> Void) {
        print("============  FAKE DATA LOADED FOR BUCKET MODE - SEMVER ===================")
        do { // QASemver
            guard let path = Bundle.main.url(forResource: "QASemver", withExtension: "json") else {
                onGetScript(nil, FlagshipError(message: "Error to load fake data", type: .internalError, code: 400))
                return
            }

            let fakeData = try Data(contentsOf: path, options: .alwaysMapped)

            let scriptObject = try JSONDecoder().decode(FSBucket.self, from: fakeData)

            onGetScript(scriptObject, nil)

            /// Save bucket script
            FSStorageManager.saveBucketScriptInCache(fakeData)

        } catch {
            print("---------------- Failed to load fake data ----------")
        }
        onGetScript(nil, FlagshipError(message: "Error to load fake data", type: .internalError, code: 400))
    }

//    func getFSScript(onGetScript: @escaping (FSBucket?, FlagshipError?) -> Void) {
//        if let urlScript = URL(string: String(format: FSGetScript, envId)) {
//            var request = URLRequest(url: urlScript)
//
//            // Manage id last modified
//
//            let dateModified: String? = UserDefaults.standard.value(forKey: FSLastModified_Key) as? String
//
//            if dateModified != nil {
//                request.setValue(dateModified, forHTTPHeaderField: FS_If_ModifiedSince)
//            }
//
//            serviceSession.dataTask(with: request) { data, response, _ in
//
//                let httpResponse = response as? HTTPURLResponse
//
//                switch httpResponse?.statusCode {
//                case 200:
//                    /// Manage last modified
//                    self.manageLastModified(httpResponse)
//
//                    if let responseData = data {
//                        do {
//                            /// Display Json response
//                            FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: FSLogMessage.GET_SCRIPT_RESPONSE("\(responseData.prettyPrintedJSONString ?? "Error on display jsonString")"))
//
//                            let scriptObject = try JSONDecoder().decode(FSBucket.self, from: responseData)
//                            onGetScript(scriptObject, nil)
//
//                            /// Save bucket script
//                            FSStorageManager.saveBucketScriptInCache(data)
//
//                        } catch {
//                            FlagshipLogManager.Log(level: .ERROR, tag: .BUCKETING, messageToDisplay: FSLogMessage.ERROR_ON_DECODE_JSON)
//                            onGetScript(nil, FlagshipError(type: .internalError, code: 400))
//                        }
//                    }
//
//                case 304:
//                    /// Read the script from the cache
//                    FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: FSLogMessage.BUCKETING_CODE_304)
//                    onGetScript(nil, FlagshipError(type: .notModified, code: 304))
//
//                default:
//                    FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: FSLogMessage.ERROR_ON_GET_SCRIPT)
//                    onGetScript(nil, FlagshipError(type: .internalError, code: 400))
//                }
//            }.resume()
//        }
//    }

    private func manageLastModified(_ response: HTTPURLResponse?) {
        guard let lastModified = response?.allHeaderFields[FSLastModified] else {
            FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: FSLogMessage.ERROR_HEADER)
            return
        }

        // Save this date into userDefault
        UserDefaults.standard.set(lastModified, forKey: FSLastModified_Key)
    }
}
