import Foundation
import IOKit

class Idle {
    var masterPort: mach_port_t = 0
    var iter: io_iterator_t = 0
    var curObj: io_registry_entry_t = 0
    
    var time: Int? {
        // FIXME: check error code
        IOMasterPort(mach_port_t(MACH_PORT_NULL), &masterPort)
        IOServiceGetMatchingServices(masterPort, IOServiceMatching("IOHIDSystem"), &iter)
        let ioObject = IOIteratorNext(iter)
        guard ioObject != 0 else { return nil }
        
        var idleTime = UInt64()
        var unmanagedProperties: Unmanaged<CFMutableDictionary>?
        IORegistryEntryCreateCFProperties(ioObject, &unmanagedProperties, kCFAllocatorDefault, 0)
        if let unmanaged = unmanagedProperties {
            let properties = unmanaged.takeUnretainedValue() as NSDictionary
            if let idle = properties["HIDIdleTime"] {
                let type = CFGetTypeID(idle as CFTypeRef)
                if type == CFNumberGetTypeID() {
                    let idleNumber = idle as! CFNumber
                    idleTime = (idleNumber as NSNumber).uint64Value
                }
                
                return Int(idleTime / 1000000000)
            }
        }
        
        return nil
    }
}
