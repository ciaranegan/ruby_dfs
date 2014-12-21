require 'socket'

	if ARGV.empty?
		message = "HELO text\n"
	else
		message = ARGV[0]
	end

# Open a tcp socket to localhost
socket = TCPSocket.open 'localhost', 8000

socket.puts "JOIN_CHATROOM:ciarans_chat"
socket.puts "CLIENT_IP:0"
socket.puts "PORT:0"
socket.puts "CLIENT_NAME:ciaranegan"

# Read the returned data
for i in 0..4
	line = socket.gets
	puts line.chomp
end

puts "Done receiving"

socket.puts "CHAT:0"
socket.puts "JOIN_ID:0"
socket.puts "CLIENT_NAME:ciaranegan"
socket.puts "MESSAGE:hello, world"

for i in 0..2
	line = socket.gets
	puts line.chomp
end

socket.puts "LEAVE_CHATROOM:ciarans_chat"
socket.puts "JOIN_ID:0"
socket.puts "CLIENT_NAME:ciaranegan"

for i in 0..1
	line = socket.gets
	puts line.chomp
end

puts "Done receiving"


socket.puts "DISCONNECT:0"
socket.puts "PORT:0"
socket.puts "CLIENT_NAME:ciaranegan"

while line = socket.gets
	puts line.chomp
end

# socket.puts "KILL_SERVICE\n"

# while line = socket.gets
# 	puts line.chomp
# end
#socket.close