require 'socket'
require 'uri'

class DFSClient

	def initialize(host, port_no)
		@connection = TCPSocket.open host, port_no
		@root_dir   = "client_files"
	end

	def connect_to(host, port_no)
		@connection = TCPSocket.open host, port_no
	end

	def run()
		self.show_menu()
		menu_selection = gets.chomp
		case menu_selection.to_i
		when 1
			self.upload_file
		when 2
			self.download_file
		else
			puts "invalid selection"
			self.run
		end
			
	end

	def upload_file()
		puts "Please enter file to be uploaded"
		file_path = gets.chomp
		file_path = File.expand_path("../#{@root_dir}/#{file_path}", __FILE__)

		if File.file?(file_path)
			file = File.open(file_path)
			file_content = file.read
			@connection.puts "PUT_FILE:#{File.basename(file)}"
			@connection.puts "CONTENT_LENGTH:#{file_content.length}"
			@connection.puts "CONTENT:#{URI.escape(file_content)}"
		end

		self.run
	end

	def download_file()
		puts "Please enter file to be downloaded"
		filename = gets.chomp

		@connection.puts "GET_FILE:#{filename}"

		path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
		file = File.open(path, 'wb')

		content_length = @connection.gets
		content_length =~ /\ACONTENT_LENGTH:\s*(\w.*)\s*\z/
		content_length = $1

		file_data = @connection.gets
		file_data =~ /\ACONTENT:(\w.*)/
		file_data = URI.unescape($1)

		puts "FILE_DATA:#{file_data}"

		file.print file_data
		file.close
		self.run
	end

	def show_menu()
		puts "1. Upload file"
		puts "2. Download file"
	end
end

if $0 == __FILE__
	client = DFSClient.new('localhost', 8000)
	client.run
end