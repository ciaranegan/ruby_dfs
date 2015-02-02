require 'socket'
require 'thread'

# require_relative '../../chat/chatroom_handler.rb'
require_relative './dir_handler.rb'

class Router

	def initialize()
		# @chatroom  = ChatroomHandler.new
		@directory = DirectoryHandler.new
	end

	def route(client, request)

		puts request
		puts request.chomp
		case request.chomp
		when /\AKILL_SERVICE\z*/
			client.puts "Server shutdown"
			return false

		when /\AHELO:\s*(\w.*)\s*\z*/
			local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
			client.puts "#{$1}\nIP:#{local_ip}\nPort:#{@port_no}\nStudentID:11450212"
			return false

		# Cases for Chat module

		# when /\AJOIN_CHATROOM:\s*(\w.*)\s*\z/
		# 	@chatroom.join(client, $1)

		# when /\ALEAVE_CHATROOM:\s*(\w.*)\s*\z/
		# 	@chatroom.leave(client, $1)

		# when /\ADISCONNECT:\s*(\w.*)\s*\z/
		# 	@chatroom.disconnect(client)
		# 	return false

		# when /\ACHAT:\s*(\w.*)\s*\z/
		# 	@chatroom.chat(client, $1)

		# Cases for DFS here

		# when /\AGET_FILE:\s*(\w.*)\s*\z/
		# 	@filesystem.get($1, client)

		# when /\APUT_FILE:\s*(\w.*)\s*\z/
		# 	@filesystem.put($1, client)

		when /\AJOIN:\s*(\w.*)\s*\z/
			@directory.join_network($1, client)
			return false

		# when /\AUPDATE_FILES:\s*(\w.*)\s*\z/
		# 	@directory.update_files($1, client)

		when /\AGET_FILE:\s*(\w.*)\s*\z/
			puts "routed"
			@directory.get_file_server($1, client)
			return false

		else
			client.puts "ERROR_CODE:7"
			client.puts "ERROR_DESCRIPTION:Invalid request"
			return false
		end

		return true
	end

end