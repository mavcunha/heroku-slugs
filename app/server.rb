require 'webrick'

server = WEBrick::HTTPServer.new :Port => ENV["PORT"]

server.mount_proc '/' do |req, res|
  res.body = "Hello, I was built and deployed by Snap, my pipeline counter was XXSNAPPIPELINEXX\n"
end

trap 'INT' do
  server.shutdown
end

server.start
