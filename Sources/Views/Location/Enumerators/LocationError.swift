import struct CoreLocation.CLError

public enum LocationError: Error {
 case code(CLError.Code), error(Error)
}
