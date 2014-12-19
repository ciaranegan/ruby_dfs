require 'socket'
require 'thread'

require_relative 'chatroon_handler.rb'

class Router

	def initialize()
		@chatroom = ChatroomHandler.new
	end

	def route(client, request)

		case request.chomp
		when "KILL_SERVICE\n"
			client.puts "Server shutdown"

		when /\AHELO\s*(\w.*)\s*\z*/
			message = $1
			local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
			client.puts "#{message}IP:#{local_ip}\nPort:#{@port_no}\nStudentID:11450212"
			client.close

		when /\AJOIN_CHATROOM:\s*(\w.*)\s*\z/
			@chatroom.join(client, $1)

		when /\ALEAVE_CHATROOM:\s*(\w.*)\s*\z/
			@chatroom.leave(client, $1)

		when /\ADISCONNECT:\s*(\w.*)\s*\z/
			@chatroom.disconnect(client)

		when /\ACHAT:\s*(\w.*)\s*\z/
			@chatrooms.chat(client, $1)

	end

end