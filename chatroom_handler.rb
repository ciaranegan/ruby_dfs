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

		client_ip = client.gets
		client_ip =~ /\ACLIENT_IP:\s*(\w.*)\s*\z/
		client_ip = $1

		port = client.gets
		port =~ /\APORT:\s*(\w.*)\s*\z/
		port = $1

		client_name = client.gets
		client_name =~ /\ACLIENT_NAME:\s(\w.*)\s\z/
		client_name = $1

		if client_name.nil?
			client.puts "ERROR_CODE:1"
			client.puts "ERROR_DESCRIPTION:Invalid username"
			return
		end

		if !@clients.has_key?(client_name)
			@clients[client_name] = Client.new(client_name, @clients.size, client)
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

		join_id = client.gets
		join_id =~ /\AJOIN_ID:\s(\w.*)\s*\z/
		join_id = $1
		if join_id.nil?
			client.puts "ERROR_CODE:2"
			client.puts "ERROR_DESCRIPTION:Invalid join_id"
			return
		end

		client_name = client.gets
		client_name =~ /\ACLIENT_NAME:\s(\w.*)\s*\z/
		client_name = $1
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

		@chatrooms[room_name].remove_client(client)
	end

	def disconnect(client)
		port = client.gets
		port =~ /\APORT:\s*(\w.*)\s*\z/
		port = $1

		client_name = client.gets
		client_name =~ /\ACLIENT_NAME:\s(\w.*)\s*\z/
		client_name = $1
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
		join_id = client.gets
		join_id =~ /\AJOIN_ID:\s(\w.*)\s*\z/
		join_id = $1
		if join_id.nil?
			client.puts "ERROR_CODE:2"
			client.puts "ERROR_DESCRIPTION:Invalid join_id"
			return
		end

		client_name = client.gets
		client_name =~ /\ACLIENT_NAME:\s(\w.*)\s*\z/
		client_name = $1
		if client_name.nil? || !@clients.has_key?(client_name)
			client.puts "ERROR_CODE:1"
			client.puts "ERROR_DESCRIPTION:Invalid username"
			return
		end

		message = client.gets
		message =~ /\AMESSAGE:\s(.*)\s*\z/
		message = $1
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

		@chatrooms[room_name].chat(message, client)
	end

	def authenticate_user(client_name, join_id)
		if @client_list.has_key?(client_name)
			return @client_list[client_name].join_id == join_id
		else
			return false
		end
	end
end