require 'socket'
require 'uri'

class DFSHandler

	def initialize()
		@root_dir = "server_files"
		@files    = Hash.new
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

		content_length = connection.gets
		content_length =~ /\ACONTENT_LENGTH:\s*(\w.*)\s*\z/
		content_length = $1

		file_data = connection.gets
		file_data =~ /\ACONTENT:(\w.*)/
		file_data = URI.unescape($1)

		file_size = file_data.length
		file.print file_data
		file.close
	end
end