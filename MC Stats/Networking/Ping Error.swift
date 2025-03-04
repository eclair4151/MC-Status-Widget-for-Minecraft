/// Describes all possible errors thrown within `SwiftyPing`
public enum PingError: Error, Equatable {
    // Response errors
    
    /// The response took longer to arrive than `configuration.timeoutInterval`
    case responseTimeout,
         // Response validation errors
         
         /// The response length was too short
         invalidLength(received: Int),
         
         /// The received checksum doesn't match the calculated one
         checksumMismatch(received: UInt16, calculated: UInt16),
         
         /// Response `type` was invalid
         invalidType(received: ICMPType.RawValue),
         
         /// Response `code` was invalid
         invalidCode(received: UInt8),
         
         /// Response `identifier` doesn't match what was sent
         identifierMismatch(received: UInt16, expected: UInt16),
         
         /// Response `sequenceNumber` doesn't match
         invalidSequenceIndex(received: UInt16, expected: UInt16),
         
         // Host resolve errors
         /// Unknown error occured within host lookup
         unknownHostError,
         
         /// Address lookup failed
         addressLookupError,
         
         /// Host was not found
         hostNotFound,
         
         /// Address data could not be converted to `sockaddr`
         addressMemoryError,
         
         // Request errors
         /// An error occured while sending the request
         requestError,
         
         /// The request send timed out. Note that this is not "the" timeout,
         /// that would be `responseTimeout`
         /// This timeout means that
         /// the ping request wasn't even sent within the timeout interval
         requestTimeout,
         
         // Internal errors
         /// Checksum is out-of-bounds for `UInt16` in `computeCheckSum`
         /// This shouldn't occur, but if it does, this error ensures that the app won't crash
         checksumOutOfBounds,
         
         /// Unexpected payload length
         unexpectedPayloadLength,
         
         /// Unspecified package creation error
         packageCreationFailed,
         
         /// For some reason, the socket is `nil`
         /// This shouldn't ever happen, but just in case...
         socketNil,
         
         /// The ICMP header offset couldn't be calculated
         invalidHeaderOffset,
         
         /// Failed to change socket options, in particular SIGPIPE
         socketOptionsSetError(err: Int32)
}
