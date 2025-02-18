import Foundation
import Network


// This code could def use come cleanup, but overall does the job pretty well
public class JavaServerStatusChecker: ServerStatusCheckerProtocol {
    let serverAddress: String
    let port: Int
    
    // calling a contination twice will cause the app to crash. This ensures incase an error is called twice, ect that nothing happens.
    // This feels like a hack, but i cant think of a better way due to the enherint unknowns of how the error system works in iOS,
    // i dont think there is a way to ensure that any part of these errors are not called twice.
    // we also need to use a task dispatch queue since the response are being called from many threads, so cant ensure atomic operations on the continuationHasBeenCalled variable
    var continuationHasBeenCalled = false
    let queue = DispatchQueue(label: "continuationCallerQueue")
    var continuation: CheckedContinuation<String, Error>?
    var timeoutTask: Task<(), Error>?
    var recievedData = false
    
    public required init(serverAddress: String, port: Int) {
        self.serverAddress = serverAddress
        self.port = port
    }
    
    public func checkServer() async throws -> String {
        continuationHasBeenCalled = false
        recievedData = false
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let dataToSend = getJavaStatusQueryData(address: self.serverAddress, port: self.port)
            startTCPConnection(dataToSend: Data(dataToSend))
        }
    }
    
    public func getParser() -> ServerStatusParserProtocol.Type {
        JavaServerStatusParser.self
    }
    
    func callContinuationResume(result: String) {
        queue.sync {
            guard !continuationHasBeenCalled else {
                return
            }
            timeoutTask?.cancel()
            continuationHasBeenCalled = true
            continuation?.resume(returning: result)
        }
    }
    
    func callContinuationError(error: ServerStatusCheckerError) {
        queue.sync {
            guard !continuationHasBeenCalled else {
                return
            }
            
            timeoutTask?.cancel()
            continuationHasBeenCalled = true
            continuation?.resume(throwing: error)
        }
    }
    
    func startTCPConnection(dataToSend: Data) {
        print("Going to start TCP Connection to \(self.serverAddress):\(self.port)")
        
        guard self.port <= 65535, self.port >= 0, let port = NWEndpoint.Port(rawValue: UInt16(self.port)) else {
            print("Invalid Port... canceling")
            self.callContinuationError(error: ServerStatusCheckerError.InvalidPort)
            return
        }
        
        let connection = NWConnection(host: NWEndpoint.Host(self.serverAddress), port: port, using: .tcp)
        
        // set a 5 second timeout to receive the data
        self.timeoutTask = Task {
            
            try await Task.sleep(nanoseconds: UInt64(5) * NSEC_PER_SEC)
            
            // see if we got any data so far, if we did wait 3 more seconds
            if self.recievedData {
                print("Waited 3 seconds but got data so waiting 3 more")
                try await Task.sleep(nanoseconds: UInt64(3) * NSEC_PER_SEC)
            }
            
            print("Timed out after connecting to \(self.serverAddress):\(self.port)")
            // ok now it took too long. timeout!
            self.callContinuationError(error: ServerStatusCheckerError.ServerUnreachable)
            connection.cancel()
        }
        
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connection established.")
                connection.send(content: dataToSend, completion: .contentProcessed { error in
                    if let error = error {
                        print("Error sending data: \(error)")
                        self.callContinuationError(error: ServerStatusCheckerError.ServerUnreachable)
                        connection.cancel()
                    } else {
                        // nothing to do now, just wait for the response in the other listener
                        print("Data sent successfully.")
                    }
                })
                
            case .failed(let error):
                print("Connection failed with error: \(error)" + "   -   server: " + self.serverAddress)
                self.callContinuationError(error: ServerStatusCheckerError.ServerUnreachable)
                connection.cancel()
                
                //                case .preparing, .setup:
                //                    print("Connection preparing or setup.")
                //
                //                case .waiting(let error):
                //                    print("Connection waiting with error: \(error)" + "   -   server: " + self.serverAddress)
                
            default:
                break
            }
        }
        
        // setup recursive data receiver
        receiveConnectionData(connection: connection)
        
        connection.start(queue: DispatchQueue.global(qos: .background))
    }
    
    // this is a recursive function that will read data from a given connection recurisvely, until the expected data has been read.
    // and once finished, sends the result to the continuation
    // i would have prefered to not make his recursive, but since connection.receive sends the data back in a callback, there is basiaclaly no other way without making the code wayyy more complicated. you would need to extract this section out into it own class with withCheckedThrowingContinuation. Then you could use an async await to download the data with a while loop instead of recurisve function. Not worth it at the moment.
    func receiveConnectionData( connection: NWConnection, dataParts: [UInt8] = [], expectedSize: Int = -1) {
        
        // i have implemented TCP paging logic since the response may be sent over multitple packets
        // i would prefer to use connection.receiveMessage like in UDP for the bedrock server, but in my testing, java minecraft servers do not automatically close the connection after the message is finished sending, so you need to manually keep track of the incoming data packets and close the connection once you have received all the expected data
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [self] data, _, isComplete, error in
            if let error {
                print("Error receiving data: \(error)" + "  -  address: " + self.serverAddress)
                self.callContinuationError(error: ServerStatusCheckerError.ServerUnreachable)
                connection.cancel()
                
            } else if let data {
                print("Data: \(data)")
                
                // when we get here, the server has returned a chunk of data. we need to dynamaically store the chunks of data in an array to we can reconstruct it whole once we are finished downloading.
                var dataArr = dataParts + convertDataToUInt8Array(data: data)
                var messageComplete = false
                var expectedMessageSize = -1
                
                // set car so timeout knows to wait longer if we got any data
                if dataArr.count > 0 {
                    self.recievedData = true
                }
                
                // we need to make sure we have enough data downloaded from the server to read the expected message length.
                // We actually don't have any idea how much mean to read so I just guess that it won't be more than 64 bites.
                if dataArr.count >= 64 {
                    // here we are checking if this is the first check of data we are requesting, and if so, the first bit of data we need to read is the expected length of the message which is sent first. But once we have that size, we need to continue passing it recursivly so the child calls know when to stop asking for data
                    expectedMessageSize = if expectedSize == -1 {
                        readVariableSizedInt(bytes: &dataArr)
                    } else {
                        expectedSize
                    }
                    
                    //this should be exactly equal, and is in testing, but i'm using >= just to be extra safe we arent left hanging
                    messageComplete = expectedMessageSize > 0 && dataArr.count >= expectedMessageSize
                }
                
                // if we have the expected message length already, we can continue with parsing, if not, recursivly call this function to download the next chunk of data
                if messageComplete {
                    print("Data received successfully.")
                    // just in case...
                    guard dataArr.count > 0 else {
                        self.callContinuationError(error: ServerStatusCheckerError.StatusUnparsable)
                        return
                    }
                    
                    // remove session id we dont care about
                    dataArr.removeFirst()
                    
                    //then read in the json length the api provides, which we dont care about since we are reading the rest of the response anyway
                    _ = readVariableSizedInt(bytes: &dataArr)
                    
                    // now the remaining data should just be a json string. First make sure this is a valid string
                    guard let response = String(bytes: dataArr, encoding: .utf8) else {
                        self.callContinuationError(error: ServerStatusCheckerError.StatusUnparsable)
                        return
                    }
                    
                    //if we got to this point we should have a fully formed response string from the server. Time to send it back for parsing
                    self.callContinuationResume(result: response)
                    connection.cancel()
                } else {
                    print("Received partial data. redownloading...")
                    receiveConnectionData(connection: connection, dataParts: dataArr, expectedSize: expectedMessageSize)
                }
            }
        }
    }
    
    // convert the Data object into a byte array, so we can store and append all the data chunks, and recontruct a string from the final data array
    func convertDataToUInt8Array(data: Data) -> [UInt8] {
        data.withUnsafeBytes { rawBufferPointer in
            // Access the raw bytes through the buffer pointer
            let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            return Array(bufferPointer)
        }
    }
    
    // This is an implementation of a way to read a variable length integer. It reads in the arbtrary data, and parses out the variable length integer, removes the data from the incoming data array, and then return the number that was read from the data array
    // This is the way the Minecraft server sends the data back, and i cant seem to find a better way to parse it.
    // Im open to any sugestions of better ways to do this not so manually.
    // https://en.wikipedia.org/wiki/Variable-length_quantity
    private func readVariableSizedInt(bytes: inout [UInt8]) -> Int {
        var result = 0
        var shift = 0
        
        for _ in 0...bytes.count {
            if bytes.count == 0 {
                return 0
            }
            
            let byte = bytes.removeFirst()
            result |= (Int(byte) & 0b1111111) << shift
            shift += 7
            
            if (Int(byte) & 0b10000000) == 0 {
                return result
            }
        }
        
        return result
    }
    
    // This is a function to generate the data that we sent to the minecraft server, in order to tell it we want to request the query data
    /** Minecraft protocol can be found here: https://wiki.vg/Protocol#Clientbound
     * sends a request directly to the minecraft server for a ping request.
     1. Client sends:
     1a. \x00 (handshake packet containing the fields specified below)
     1b. \x00 (request)
     The handshake packet contains the following fields respectively:
     1. protocol version as a varint (\x00 suffices)
     2. remote address as a string
     3. remote port as an unsigned short
     4. state as a varint (should be 1 for status)
     2. Server responds with:
     2a. \x00 (JSON response)
     An example JSON string contains:
     {'players': {'max': 20, 'online': 0},
     'version': {'protocol': 404, 'name': '1.13.2'},
     'description': {'text': 'A Minecraft Server'}}
     */
    private func getJavaStatusQueryData(address: String, port: Int) -> [UInt8] {
        var data: [UInt8] = []
        let addressBytes:[UInt8] = Array(address.utf8)
        
        data.append(0x00) //packet id (always 0)
        data.append(0x00) //protocol version (0-752, we can use 0 since this api was here since the start)
        
        // this is for the url of the length and string of the server
        let addressLengthByte = withUnsafeBytes(of: addressBytes.count) {
            $0[0]
        }
        data.append(addressLengthByte) //lenth of url we are about to send
        data += addressBytes //the address of the server
        
        
        // now for the server port. We gotta switch endians and make it a short (only 2 bytes)
        let portBytes = withUnsafeBytes(of: port) {
            [$0[1], $0[0]]
        }
        
        data += portBytes //the bytes for the server port
        
        data.append(0x01) //request type (status_handshake = 1)
        
        // calculate length of whole message
        // for the sake of code simplicity, i have made a bad descision of locking the request size to 255 by only allowing a single byte of length
        // but this is fine for now since i limit the url input in the app to 200 characters and the rest of the request is only around 10 bytes
        let handshakeLengthByte = withUnsafeBytes(of: data.count) {
            $0[0]
        }
        
        //insert the message length at the begining
        data.insert(handshakeLengthByte, at: 0)
        
        //now append the second message which is a hardcoded 0 to ask for the status. since it is tcp we can write both requests in the same call
        data.append(0x01) //length of following status packet (always 1)
        data.append(0x00) //status packet (always 0)
        
        return data
    }
}
