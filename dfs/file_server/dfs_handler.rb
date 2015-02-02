require 'socket'
require 'uri'

class DFSHandler

	def initialize(dir_ip, dir_port, port_no)
		@root_dir = "server_files"
		@directory_ip = dir_ip
		@directory_port = dir_port

		directory_conn = TCPSocket.new(@directort_ip, @directory_port)
		local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
		directory_conn.puts "JOIN:#{local_ip}"
		directory_conn.puts "PORT:#{port_no}"

		@id = regex_match(directory_conn, /\AID:\s.*(\w.*)\s*\z/)
	end

	def get(filename, connection)
		path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
		if File.file?(path)
			file = File.open(path, 'r')
			file_contents = file.read
			connection.puts "CONTENT_LENGTH:#{file_contents.length}"
			connection.puts "CONTENT:#{URI.escape(file_contents)}"
			file.close
		else
			connection.puts "ERROR_CODE:8"
			connection.puts "ERROR_DESCRIPTION:No such file"
		end
	end

	def put(filename, connection)
		path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
		file = File.open(path, 'wb')

		content_length = regex_match(connection, /\ACONTENT_LENGTH:\s*(\w.*)\s*\z/)
		file_data = regex_match(connection, /\ACONTENT:(\w.*)/)

		file_size = file_data.length
		file.print file_data
		file.close
	end

	def regex_match(connection, regex)
		arg = connection.gets
		arg =~ regex
		return $1
	end

end