%w{
  version ansi characters console console_resized content header footer
  interaction key keyboard partial view viewport
}.each do |lib|
  require "remedy/#{lib}"
end

module Remedy
end
