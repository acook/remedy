%w{
  version ansi characters console resized_console content header footer
  interaction key keyboard partial view viewport
}.each do |lib|
  require "remedy/#{lib}"
end

module Remedy
end
