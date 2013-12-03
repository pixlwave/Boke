#! /usr/bin/ruby

require 'open-uri'

ip, port = nil
open("http://digitalfx.me.uk/mypi/is") { |f|
	ip = f.readline.delete("\n")
	port = f.readline
}

# File.open("~/.ssh/known_hosts", a") { |f|
# 	f.puts "#{ip} ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw/GEeJIYTT06eD88GgfQ7zsO1v/7FgYu3TNqgEPBai/qJbm/3FwJeMSA7eJUAmD1WzaOb+NXYqhi8q9b37BjOc03brNZDu4PZIjZ330tsVGzggCOJuRPZUWZrsEu7IYTDJhbNUOyAQtVtKnkxhvlo+5AiwPd561pwWP5ilT2Vr8Lf9AErKk0mwrgXKba/Va+XKLfwYREDqxhvAZXQIJtp7ak2SLdDrjyI1+3DW8GY4atmhNCAVHkVC+fDV6LEK92TbUg1IJfIoQCvTrg4dPh08jxZ2ybvu8FfSQAzji0nKvB83qpQHS8aoxfFMpGAR2oi0k09GztmRGklk3UleKO5"
# end

# check if the i needs to go before or after the address?
exec "ssh -D 8888 pi@#{ip} -p #{port} -vv"
