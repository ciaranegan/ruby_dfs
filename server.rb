require 'socket'
require 'thread'

require_relative 'router.rb'

class ThreadPoolServer

	def initialize(size, port_no)
		
		chatroom_new = Chatroom.new("hello", 1)

		@size = size # Number of threads in the thread pool
		@jobs = Queue.new # Queue of tasks for the threads to execute
		@port_no = port_no
		@router = Router.new

		@pool = Array.new(@size) do |i| # Create an array of threads
			Thread.new do
				Thread.abort_on_exception = true
				Thread.current[:id] = i # Give each thread an ID for easy access later
				loop do
					client, message = @jobs.pop # Get a job from the queue
					@router.route(client, message)
					# self.handle_client(client, message)
					#client.close
				end
			end
		end
		# Set up TCPServer and start
		@server = TCPServer.new port_no
		@server_running = true
		self.run
	end

	def schedule(client, message)
		# Enqueues a client along with its message for the thread pool to handle
		@jobs << [client, message]
	end

	# def handle_client(client, message)
	# 	puts message.chomp
	# 	keep_connection_open = true

	# 	case message.chomp
	# 	when "KILL_SERVICE\n"
	# 		client.puts "Server shutdown"

	# 	when /^HELO\s.*/
	# 		# Get the incoming sockets info and send it back
	# 		local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
	# 		client.puts "#{message}IP:#{local_ip}\nPort:#{@port_no}\nStudentID:11450212"
	# 		client.close

	# 	# /\AJOIN_CHATROOM:(\S+)\\nCLIENT_IP:0\\nPORT:0\\nCLIENT_NAME:(\S+)/
	# 	when /\AJOIN_CHATROOM:\s*(\w.*)\s*\z/

	# 		puts "inside join_chatroom"
	# 		room_name = $1
	# 		message = client.gets
	# 		message = client.gets
	# 		message = client.gets
	# 		message =~ /\ACLIENT_NAME:\s(\w+)\s*\z/
	# 		puts "message: '#{message}'"
	# 		puts $1
	# 		client_name = $1
	# 		if !@chatrooms.has_key?(room_name)
	# 			new_chat = Chatroom.new(room_name, @chatrooms.length)
	# 			@chatrooms[room_name] = new_chat
	# 		end

	# 		if !@client_list.has_key?(client_name)
	# 			@client_list[client_name] = Client.new(client_name, client_name+room_name, client)
	# 		end
	# 		@client_list[client_name].socket = client
	# 		@chatrooms[room_name].add_client(@client_list[client_name])
	# 		#client.close

	# 	when /\ALEAVE_CHATROOM:(\S+)\\nJOIN_ID:(\S+)\\nCLIENT_NAME:(\S+)/
	# 		chatroom_name = $1
	# 		join_id = $2
	# 		client_name = $3
	# 		if authenticate_user(client_name, join_id)
	# 			@client_list[client_name].socket = client
	# 			if @chatrooms.has_key?(chatroom_name)
	# 				@chatrooms[chatroom_name].remove_client(@client_list[client_name])

	# 			else
	# 				client.puts "ERROR_CODE:3\nERROR_DESCRIPTION:Invalid chatroom"
	# 			end
	# 		else
	# 			client.puts "ERROR_CODE:2\nERROR_DESCRIPTION:Cannot authenticate user"
	# 		end

	# 		# client.close

	# 	when /\ADISCONNECT:0\\nPORT:0\\nCLIENT_NAME:(\S+)/
	# 		self.disconnect($1)
	# 		keep_connection_open = false
	# 		client.puts "Disconnecting"
	# 		client.close

	# 	when /\ACHAT:(\S+)\\nJOIN_ID:(\S+)\\nCLIENT_NAME:(\S+)\\nMESSAGE:(.*)/
	# 		chat_id = $1
	# 		join_id = $2
	# 		client_name = $3
	# 		message = $4

	# 		if authenticate_user(client_name, join_id)
	# 			@client_list[client_name].socket = client
	# 			@chatrooms.each do |key, chatroom|
	# 				if chatroom.room_ref == chat_id.to_i
	# 					chatroom.chat(message, @client_list[client_name])
	# 				end
	# 			end
	# 		else
	# 			client.puts "ERROR_CODE:2\nERROR_DESCRIPTION:Cannot authenticate user"
	# 		end


	# 	else
	# 		# This catches the other messages
	# 		client.puts "ERROR_CODE:1\nERROR_DESCRIPTION:Invalid command"
	# 	end
	# 	if keep_connection_open
	# 		message = client.gets
	# 	self.handle_client(client, message)
	# 	end
		
	# end

	# def authenticate_user(client_name, join_id)
	# 	if @client_list.has_key?(client_name)
	# 		return @client_list[client_name].join_id == join_id
	# 	else
	# 		return false
	# 	end
	# end

	# def disconnect(client_name)
	# 	@client_list.delete(client_name)
	# 	@chatrooms.each do |key, clients|
	# 		if clients.clients.has_key?(client_name)
	# 			clients.clients.delete(client_name)
	# 		end
	# 	end
	# end

	def shutdown
		sleep(0.5)
		# Kills all threads in the thread pool and closes the server
		@size.times do |i|
			Thread.kill(@pool[i])
		end
		@server.close
		puts "Server shutdown"
	end

	def run
		# Main loop to accept incoming messages
		puts "Server started"
		while @server_running == true do
			client = @server.accept
			message = client.gets
			puts message
			schedule(client, message)
			# Updates the loop condition based on the message
			@server_running = (message != "KILL_SERVICE\n")
		end
		# Shutsdown once a kill_service message is received
		self.shutdown
	end
end

if $0 == __FILE__
	if ARGV[0] == nil
		port_no = 8000
	else
		port_no = ARGV[0]
	end
	server = ThreadPoolServer.new(150, port_no)
end