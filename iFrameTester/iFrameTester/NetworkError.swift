//
// Created by drain on 12/04/2017.
// Copyright (c) 2017 VoiceTube. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case jsonSerializationError
    case objectSerializationError
    case httpError(Error)
    case networkUnReachable

    public var isJsonSerializationError: Bool {
        switch self {
        case .jsonSerializationError:
            return true
        case .objectSerializationError:
            return false
        case .httpError:
            return false
        case .networkUnReachable:
            return false
        }
    }

    public var isObjectSerializationError: Bool {
        switch self {
        case .jsonSerializationError:
            return false
        case .objectSerializationError:
            return true
        case .httpError:
            return false
        case .networkUnReachable:
            return false
        }
    }

    public var isResponseError: Bool {
        switch self {
        case .jsonSerializationError:
            return false
        case .objectSerializationError:
            return false
        case .httpError:
            return false
        case .networkUnReachable:
            return false
        }
    }

    public var isHttpError: Bool {
        switch self {
        case .jsonSerializationError:
            return false
        case .objectSerializationError:
            return false
        case .httpError:
            return true
        case .networkUnReachable:
            return false
        }
    }

    public var isNetworkUnReachableError: Bool {
        switch self {
        case .jsonSerializationError:
            return false
        case .objectSerializationError:
            return false
        case .httpError:
            return false
        case .networkUnReachable:
            return true
        }
    }

    public var httpError: Error? {
        switch self {
        case .jsonSerializationError:
            return nil
        case .objectSerializationError:
            return nil
        case let .httpError(error):
            return error
        case .networkUnReachable:
            return nil
        }
    }
}
