# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ProxyMenu'
  app.version = "1.0"
  app.identifier = "uk.me.digitalfx.ProxyMenu"
  app.icon = 'Icon.icns'
  app.info_plist['NSUIElement'] = 1
end