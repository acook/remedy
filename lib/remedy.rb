# Everything defined inside the `Remedy::` namespace so it doesn't get in your way.
# The Remedy ***module*** doesn't do much on its own, but you can include it to get access to all of Remedy's functionality at once.
#
# It is not necessary to include all of Remedy at once though, you can pick and choose the parts you need.
#
# For example, if you only need the ANSI commands instead of `require "remedy"` do `require "remedy/ansi"`
# and you are good to go with {ANSI} module.
#
# For more general information about Remedy the Rubygem check out the {file:README.markdown}.
module Remedy
  module_function

  # @return [Array<String>] a list of the core libraries that are `require`d with this file.
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
