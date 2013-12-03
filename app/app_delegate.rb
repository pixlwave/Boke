class AppDelegate

  def applicationDidFinishLaunching(notification)

    buildMenu
    updateProxyState
    updateFirewallState

  end

  def buildMenu

    # set up menubar item
    @statusBar = NSStatusBar.systemStatusBar
    @statusItem = @statusBar.statusItemWithLength(NSVariableStatusItemLength)
    @statusItem.setImage(NSImage.imageNamed("unknown.png"))
    # @statusItem.retain
    @statusItem.highlightMode = true

    
    # set up menu
    menu = NSMenu.new
    menu.initWithTitle("Proxy")

    @proxyMenuItem = NSMenuItem.new
    @proxyMenuItem.title = "Toggle Proxy"
    @proxyMenuItem.action = "toggleProxy:"
    menu.addItem(@proxyMenuItem)

    @firewallMenuItem = NSMenuItem.new
    @firewallMenuItem.title = "Firewall State"
    @firewallMenuItem.action = "toggleFirewall:"
    menu.addItem(@firewallMenuItem)

    menuItem = NSMenuItem.new
    menuItem.title = "Quit"
    menuItem.action = "terminate:"
    menu.addItem(menuItem)

    
    # add menu to menubar item
    @statusItem.setMenu(menu)

  end

  def toggleProxy(sender)

    if @proxyEnabled
      system "networksetup -setsocksfirewallproxystate Wi-Fi off"
    else
      system "networksetup -setsocksfirewallproxystate Wi-Fi on"
    end

    updateProxyState

  end

  def updateProxyState

    path = "/usr/sbin/networksetup"
    arguments = ["-getsocksfirewallproxy", "Wi-Fi"]
    result = launchTask(path, arguments)

    # get first line with 'Enabled: Yes' and then read after 'Enabled: '
    if result.split("\n")[0].split(": ")[1] == "Yes"
      @proxyEnabled = true
      @proxyMenuItem.title = "Disable Proxy"
    else
      @proxyEnabled = false
      @proxyMenuItem.title = "Enable Proxy"
    end

    updateIcon

  end

  def toggleFirewall(sender)

    # sudo ./socketfilterfw --setblockall on
    # sudo ./socketfilterfw --setblockall off

    if @blockAllEnabled
      system 'osascript -e "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off\" with administrator privileges"'
    else
      system 'osascript -e "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on\" with administrator privileges"'
    end

    updateFirewallState
    puts @blockAllEnabled

  end

  def updateFirewallState

    path = "/usr/libexec/ApplicationFirewall/socketfilterfw"
    arguments = ["--getblockall"]
    result = launchTask(path, arguments)

    # check if the result includes the word 'DISABLED!'
    if result.include? "DISABLED!"
      @blockAllEnabled = false
      @firewallMenuItem.title = "Enable Firewall"
    else
      @blockAllEnabled = true
      @firewallMenuItem.title = "Disable Firewall"
    end

    updateIcon

  end

  def updateIcon

    if @proxyEnabled
      if @blockAllEnabled
        @statusItem.setImage(NSImage.imageNamed("prfw.png"))
      else
        @statusItem.setImage(NSImage.imageNamed("pr.png"))
      end
    else
      if @blockAllEnabled
        @statusItem.setImage(NSImage.imageNamed("fw.png"))
      else
        @statusItem.setImage(NSImage.imageNamed("off.png"))
      end
    end

  end

  def launchTask(path, arguments)

    task = NSTask.new
    task.launchPath = path
    task.arguments = arguments

    outputPipe = NSPipe.pipe
    task.standardOutput = outputPipe

    task.launch
    task.waitUntilExit

    outputData = outputPipe.fileHandleForReading.readDataToEndOfFile
    outputString = NSString.alloc.initWithData(outputData, encoding:NSUTF8StringEncoding)

    outputString

  end

end