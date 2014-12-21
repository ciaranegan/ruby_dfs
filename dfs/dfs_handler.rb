class DFSHandler

	def initialize()
		@root_dir = "files"
		@files    = Hash.new
	end

	def get(filename, connection)
		path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
		if File.file?(path)
			file = File.open(path, 'r')
			file_content = file.read
			connection.puts file_content
			file.close
		else
			connection.puts "ERROR_CODE:8"
			connection.puts "ERROR_DESCRIPTION:No such file"
		end
	end

	def put(filename, connection)
		path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
		file = File.open(path, 'wb')
		file_date = connection.gets
		file.print file_date
		file.close
	end
end