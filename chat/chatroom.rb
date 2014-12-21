require_relative 'chat_client.rb'

class Chatroom

attr_reader :clients, :room_ref
attr_writer :clients

	def initialize(name, room_ref)
		@name = name
		@room_ref = room_ref
		@clients = Hash.new
	end

	def add_client(client)
		@clients[client.name] = client
		client.socket.puts "JOINED_CHATROOM:#{@name}"
		client.socket.puts "SERVER_IP:0"
		client.socket.puts "PORT:0"
		client.socket.puts "ROOM_REF:#{@room_ref}"
		client.socket.puts "JOIN_ID:#{client.join_id}"
	end

	def remove_client(client)
		client.socket.puts "LEFT_CHATROOM:#{@name}"
		client.socket.puts "JOIN_ID:#{client.join_id}"
		@clients.delete(client)
	end

	def chat(message, client)
		@clients.each do |key, client|
			client.socket.puts "CHAT:#{room_ref}"
			client.socket.puts "CLIENT_NAME:#{client.name}"
			client.socket.puts "MESSAGE:#{message}"
		end
	end
end