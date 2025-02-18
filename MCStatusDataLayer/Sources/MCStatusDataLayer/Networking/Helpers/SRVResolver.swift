// THIS CODE WAS MODIFIED from https://github.com/jamf/NoMAD-2
import Foundation
import dnssd

public enum SRVResolverError: String, Error, Codable {
    case unableToComplete = "Unable to complete lookup"
}

public class SRVResolver {
    var continuation: CheckedContinuation<SRVResult, Error>?
    var continuationHasBeenCalled = false
    let continuationQueue = DispatchQueue(label: "continuationCallerQueue")
    
    private let queue = DispatchQueue.init(label: "SRVResolution")
    private var dispatchSourceRead: DispatchSourceRead?
    private var timeoutTimer: DispatchSourceTimer?
    private var serviceRef: DNSServiceRef?
    private var socket: dnssd_sock_t = -1
    private var query: String?
    
    // default to 3 sec lookups
    private let timeout = TimeInterval(3)
    
    var results = [SRVRecord]()
    
    func callContinuationResume(result: SRVResult) {
        continuationQueue.sync {
            guard !continuationHasBeenCalled else {
                return
            }
            stopQuery()
            continuationHasBeenCalled = true
            continuation?.resume(returning: result)
        }
    }
    
    func callContinuationError(error: SRVResolverError) {
        continuationQueue.sync {
            guard !continuationHasBeenCalled else {
                return
            }
            stopQuery()
            continuationHasBeenCalled = true
            continuation?.resume(throwing: error)
        }
    }
    
    // this processes any results from the system DNS resolver
    // we could parse all the things, but we don't really need the info...
    let queryCallback: DNSServiceQueryRecordReply = { (sdRef, flags, interfaceIndex, errorCode, fullname, rrtype, rrclass, rdlen, rdata, ttl, context) -> Void in
        // if this isnt an SRV record just ignore it.
        guard rrtype == kDNSServiceType_SRV else {
            return
        }
        
        guard let context = context else {
            return
        }
        
        let request: SRVResolver = SRVResolver.bridge(context)
        
        if let data = rdata?.assumingMemoryBound(to: UInt8.self),
           let record = SRVRecord(data: Data.init(bytes: data, count: Int(rdlen))) {
            request.results.append(record)
        }
        
        if (flags & kDNSServiceFlagsMoreComing) == 0 {
            request.success()
        }
    }
    
    // These allow for the ObjC -> Swift conversion of a pointer
    // The DNS APIs are a bit... unique
    static func bridge<T:AnyObject>(_ obj : T) -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(obj).toOpaque()
    }
    
    static func bridge<T:AnyObject>(_ ptr : UnsafeMutableRawPointer) -> T {
        Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
    }
    
    func fail() {
        stopQuery()
        callContinuationError(error: SRVResolverError.unableToComplete)
    }
    
    func success() {
        stopQuery()
        let result = SRVResult(SRVRecords: results, query: query ?? "Unknown Query")
        callContinuationResume(result: result)
    }
    
    private func stopQuery() {
        // be nice and clean things up
        self.timeoutTimer?.cancel()
        self.dispatchSourceRead?.cancel()
    }
    
    // this is also only support by java servers
    public static func lookupMinecraftSRVRecord(serverURL: String) async -> (String,Int)? {
        
        //if its a regular ip just return nil
        guard !SRVResolver.isValidIpAddress(ipToValidate: serverURL) else {
            print("SRVResolver - ignoring ip address request")
            return nil
        }
        
        do {
            let res = SRVResolver()
            let SRVResult = try await res.resolve(query: "_minecraft._tcp." + serverURL)
            
            let highestPrioritySRV = SRVResult.SRVRecords.min(by: { rec1, rec2 in
                rec1.priority < rec2.priority
            })
            
            guard
                let address = highestPrioritySRV?.target,
                let port = highestPrioritySRV?.port,
                address != "",
                port != 0
            else {
                return nil
            }
            
            return (address, port)
        } catch {
            return nil
        }
    }
    
    //checks is the server is an ip address, if so donteven bother trying to get a dns record since one wont exist
    static func isValidIpAddress(ipToValidate: String) -> Bool {
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            // IPv6 peer
            return true
        }
        
        else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            // IPv4 peer
            return true
        }
        
        return false
    }
    
    func resolve(query: String) async throws -> SRVResult {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.query = query
            let namec = query.cString(using: .utf8)
            
            let result = DNSServiceQueryRecord(
                &self.serviceRef,
                kDNSServiceFlagsReturnIntermediates,
                UInt32(0),
                namec,
                UInt16(kDNSServiceType_SRV),
                UInt16(kDNSServiceClass_IN),
                queryCallback,
                SRVResolver.bridge(self)
            )
            
            switch result {
            case DNSServiceErrorType(kDNSServiceErr_NoError):
                guard let sdRef = self.serviceRef else {
                    fail()
                    return
                }
                
                self.socket = DNSServiceRefSockFD(self.serviceRef)
                
                guard self.socket != -1 else {
                    fail()
                    return
                }
                
                self.dispatchSourceRead = DispatchSource.makeReadSource(fileDescriptor: self.socket, queue: self.queue)
                
                self.dispatchSourceRead?.setEventHandler {
                    let res = DNSServiceProcessResult(sdRef)
                    
                    if res != kDNSServiceErr_NoError {
                        self.fail()
                    }
                }
                
                self.dispatchSourceRead?.setCancelHandler {
                    DNSServiceRefDeallocate(self.serviceRef)
                }
                
                self.dispatchSourceRead?.resume()
                
                self.timeoutTimer = DispatchSource.makeTimerSource(flags: [], queue: self.queue)
                
                self.timeoutTimer?.setEventHandler {
                    self.fail()
                }
                
                let deadline = DispatchTime(
                    uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + UInt64(timeout * Double(NSEC_PER_SEC))
                )
                
                self.timeoutTimer?.schedule(
                    deadline: deadline,
                    repeating: .infinity,
                    leeway: DispatchTimeInterval.never
                )
                
                self.timeoutTimer?.resume()
                
            default:
                self.fail()
            }
        }
    }
}
