module Remedy
  module_function

  def libs
    %w{
      version ansi characters console console_resize
      interaction key keyboard partial view viewport
    }
  end
end

Remedy.libs.each do |lib|
  require "remedy/#{lib}"
end
