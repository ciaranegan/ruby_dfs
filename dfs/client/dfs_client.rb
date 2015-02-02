require 'socket'
require 'uri'

class DFSClient

	def initialize(host, port_no)
		puts "initialize"
		@dir_host = host
		@dir_port_no = port_no
		# @connection = TCPSocket.open(@dir_host, @dir_port_no)
		@root_dir   = "client_files"
	end

	def connect_to(host, port_no)
		puts port_no
		puts host
		@connection = TCPSocket.open(host, port_no)
	end

	def upload_file(filename)
		file_path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
		puts file_path
		if File.file?(file_path)
			puts "inside if"
			file = File.open(file_path)
			file_content = file.read

			self.connect_to(@dir_host, @dir_port_no)
			@connection.puts "GET_FILE:#{File.basename(file)}"
			puts "Connected"
			ip = regex_match(@connection, /\ASERVER_IP:\s*(\w.*)\s*\z/)
			puts "IP received=#{ip}"
			port = regex_match(@connection, /\ASERVER_PORT:\s*(\w.*)\s*\z/).to_i

			puts "dir server done"

			self.connect_to(ip, port)
			@connection.puts "PUT_FILE:#{File.basename(file)}"
			@connection.puts "CONTENT_LENGTH:#{file_content.length}"
			@connection.puts "CONTENT:#{URI.escape(file_content)}"
			puts "done uploading"
		end
	end

	def download_file(filename)

		self.connect_to(@dir_host, @dir_port_no)
		@connection.puts "GET_FILE:#{filename}"

		ip = regex_match(@connection, /\ASERVER_IP:\s*(\w.*)\s*\z/)
		port = regex_match(@connection, /\ASERVER_PORT:\s*(\w.*)\s*\z/)

		puts port
		puts ip

		path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
		file = File.open(path, 'wb')

		file_length = regex_match(@connection, /\ACONTENT_LENGTH:\s*(\w.*)\s*\z/)
		file_data = regex_match(@connectionm, /\ACONTENT:(\w.*)/)

		file.print file_data
		file.close
	end

	def regex_match(connection, regex)
		arg = connection.gets
		arg =~ regex
		return $1
	end
end
	
if $0 == __FILE__
	client = DFSClient.new('localhost', 8000)
	client.run
end