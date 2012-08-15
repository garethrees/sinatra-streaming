require 'rubygems'
require 'sinatra'

set server: 'thin', connections: []

cmd = 'ls'

get '/' do
  stream do |out|
    IO.popen(cmd, 'r') do |io|
      while line = io.gets
        puts line
        out << line
      end
    end
  end
end