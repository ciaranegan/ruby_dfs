require_relative 'chatroom.rb'
require_relative 'chat_client.rb'

class ChatroomHandler

	def initialize()
		@chatrooms = Hash.new
		@clients   = Hash.new
	end

	def join(client, room_name)
		if room_name.nil?
			client.puts "ERROR_CODE:3"
			client.puts "ERROR_DESCRIPTION:Invalid room name"
			return
		end

		client_ip = regex_match(client, /\ACLIENT_IP:\s*(\w.*)\s*\z/)
		port = regex_match(client, /\APORT:\s*(\w.*)\s*\z/)
		client_name = regex_match(client, /\ACLIENT_NAME:\s*(\w.*)\s*\z/)

		if client_name.nil?
			client.puts "ERROR_CODE:1"
			client.puts "ERROR_DESCRIPTION:Invalid username"
			return
		end

		if !@clients.has_key?(client_name)
			@clients[client_name] = Client.new(client_name, @clients.length, client)
		end

		if !@chatrooms.has_key?(room_name)
			@chatrooms[room_name] = Chatroom.new(room_name, @chatrooms.length)
		end

		@chatrooms[room_name].add_client(@clients[client_name])
	end

	def leave(client, room_name)
		if room_name.nil? || !@chatrooms.has_key?(room_name)
			client.puts "ERROR_CODE:3"
			client.puts "ERROR_DESCRIPTION:Invalid room name"
			return
		end

		join_id = regex_match(client, /\AJOIN_ID:\s*(\w.*)\s*\z/)
		if join_id.nil?
			client.puts "ERROR_CODE:2"
			client.puts "ERROR_DESCRIPTION:Invalid join_id"
			return
		end

		client_name = regex_match(client, /\ACLIENT_NAME:\s*(\w.*)\s*\z/)
		if client_name.nil? || !@clients.has_key?(client_name)
			client.puts "ERROR_CODE:1"
			client.puts "ERROR_DESCRIPTION:Invalid username"
			return
		end

		if !authenticate_user(client_name, join_id)
			client.puts "ERROR_CODE:4"
			client.puts "ERROR_DESCRIPTION:Cannot authenticate user"
			return
		end

		@chatrooms[room_name].remove_client(@clients[client_name])
	end

	def disconnect(client)
		port = regex_match(client, /\APORT:\s*(\w.*)\s*\z/)

		client_name = regex_match(client, /\ACLIENT_NAME:\s*(\w.*)\s*\z/)
		if client_name.nil? || !@clients.has_key?(client_name)
			client.puts "ERROR_CODE:1"
			client.puts "ERROR_DESCRIPTION:Invalid username"
			return
		end

		@clients.delete(client)
		@chatrooms.each do |key, chatroom|
			if chatroom.clients.has_key?(client_name)
				chatroom.clients.delete(client_name)
			end
		end
	end

	def chat(client, room_ref)
		join_id = regex_match(client, /\AJOIN_ID:\s*(\w.*)\s*\z/)
		if join_id.nil?
			client.puts "ERROR_CODE:2"
			client.puts "ERROR_DESCRIPTION:Invalid join_id"
			return
		end

		client_name = regex_match(client, /\ACLIENT_NAME:\s*(\w.*)\s*\z/)

		if client_name.nil? || !@clients.has_key?(client_name)
			client.puts "ERROR_CODE:1"
			client.puts "ERROR_DESCRIPTION:Invalid username"
			return
		end

		message = regex_match(client, /\AMESSAGE:\s*(.*)\s*\z/)
		if message.nil?
			client.puts "ERROR_CODE:5"
			client.puts "ERROR_DESCRIPTION:No message provided"
			return
		end

		if !authenticate_user(client_name, join_id)
			client.puts "ERROR_CODE:4"
			client.puts "ERROR_DESCRIPTION:Cannot authenticate user"
			return
		end

		chat_exists = false
		@chatrooms.each do |key, chatroom|
			if chatroom.room_ref == room_ref.to_i
				chatroom.chat(message, @clients[client_name])
				chat_exists = true
			end
		end

		if !chat_exists
			client.puts "ERROR_CODE:6"
			client.puts "ERROR_DESCRIPTION:Invalid room_ref"
		end
	end

	def authenticate_user(client_name, join_id)
		if @clients.has_key?(client_name)
			return @clients[client_name].join_id.to_i == join_id.to_i
		else
			return false
		end
	end

	def regex_match(connection, regex)
		arg = connection.gets
		arg =~ regex
		return $1
	end
end