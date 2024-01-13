import AppKit

struct ControllableApp {
    /// The app's process ID if running, otherwise `nil`.
    var processIdentifier: pid_t?
    /// A closure called to determine whether a particular instance of an app is this controllable app.
    let matchesRunningApplication: (NSRunningApplication) -> Bool
}
