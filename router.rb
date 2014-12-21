require 'socket'
require 'thread'

require_relative 'chat/chatroom_handler.rb'
require_relative 'dfs/dfs_handler.rb'

class Router

	def initialize()
		@chatroom   = ChatroomHandler.new
		@filesystem = DFSHandler.new
	end

	def route(client, request)

		case request.chomp
		when /\AKILL_SERVICE\z*/
			client.puts "Server shutdown"
			return false

		when /\AHELO:\s*(\w.*)\s*\z*/
			local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
			client.puts "#{$1}\nIP:#{local_ip}\nPort:#{@port_no}\nStudentID:11450212"
			return false

		# Cases for Chat module

		when /\AJOIN_CHATROOM:\s*(\w.*)\s*\z/
			@chatroom.join(client, $1)

		when /\ALEAVE_CHATROOM:\s*(\w.*)\s*\z/
			@chatroom.leave(client, $1)

		when /\ADISCONNECT:\s*(\w.*)\s*\z/
			@chatroom.disconnect(client)
			return false

		when /\ACHAT:\s*(\w.*)\s*\z/
			@chatroom.chat(client, $1)

		# Cases for DFS here

		when /\AGET_FILE:\s*(\w.*)\s*\z/
			@filesystem.get($1, client)

		when /\APUT_FILE:\s*(\w.*)\s*\z/
			@filesystem.put($1, client)

		else
			client.puts "ERROR_CODE:7"
			client.puts "ERROR_DESCRIPTION:Invalid request"
			return false
		end

		puts "Finished routing"
		return true
	end

end