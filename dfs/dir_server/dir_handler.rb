require 'sqlite3'

class DirectoryHandler

	def initialize()
		@file_refs = SQLite3::Database.new "file_refs.db"
		@file_refs.results_as_hash = true

		# @file_refs.execute "SELECT * FROM FileServer;" do |file_server|
		# 	puts "-> #{file_server['id']} --> #{file_server['ip_addr']} --> #{file_server['port']}"
		# end
	end

	def join_network(ip_addr, connection)
		port_no = regex_match(connection, /\APORT:\s*(\w.*)\s*\z/)

		if !exists_check(ip_addr, port_no)
			@file_refs.execute "INSERT INTO FileServer(ip_addr, port) values(\"#{ip_addr}\", #{port_no.to_i});"
			id = @file_refs.execute "SELECT server_id FROM FileServer WHERE ip_addr=\"#{ip_addr}\" AND port=#{port_no.to_i};"
			connection.puts "ID:#{id}"
			puts "Joined network"
		end
	end

	def get_file_server(filename, connection)
		puts "asking for file"
		lookup = @file_refs.execute "SELECT * FROM FileRef WHERE filename=\"#{filename}\";"
		# IF null delegate new server
		# puts "server_id=#{server_id['server']}"
		check = false
		if lookup
			server_id = lookup[0]
			check = true
		end
		
		if !check
			puts "No such filename"
			id = self.delegate_to_server
			# Insert new file into DB
			@file_refs.execute "INSERT INTO FileRef values(\"#{filename}\", #{id.to_i});"
		else
			puts server_id
			puts server_id['server']
			id = server_id['server']
		end

		
		# if server_id.length > 0
		# 	puts "No such filename"
		# 	server_id = self.delegate_to_server
		# 	# Insert new file into DB
		# 	@file_refs.execute "INSERT INTO FileRefs values(\"#{filename}\", #{server_id.to_i});"
		# end
		puts "looking up id=#{id.to_i}"
		# lookup =        @file_refs.execute "SELECT * FROM FileRef WHERE filename=\"#{filename}\";"
		server_lookup = @file_refs.execute "SELECT * from FileServer WHERE server_id=#{id.to_i};"
		server_details = server_lookup[0]
		connection.puts "SERVER_IP:#{server_details['ip_addr']}"
		connection.puts "SERVER_PORT:#{server_details['port']}"

		
		
		
	end

	# def update_files(id, connection)
	# 	file_count = regex_match(connection, /\AFILE_COUNT:\s*(\w.*)\s*\z/)

	# 	file_count.times do |i|
	# 		file_ref = regex_match(connection, /\AFILE_REF:\s*(\w.*)\s*\z/)
	# 		@file_refs.execute "INSERT INTO FileRefs values(\"#{file_ref}\", #{id.to_i});"
	# 	end
	# end

	def add_file(file_ref, connection)
		# Need to delegate to a server here and get its ID
		id = self.delegate_to_server
		@file_refs.execute "INSERT INTO FileRefs values(\"#{file_ref}\", #{id.to_i});"
	end

	def delegate_to_server()
		# @file_refs.execute "SELECT * FROM FileServer;" do |file_server|
		# 	id = file_server['id']
		# 	delegate_info[id] = @file_refs.execute "SELECT COUNT(*) FROM FileRefs WHERE server=#{file_server['id']}"
		# end
		# current_smallest = delegate_info[0]
		# delegate_info.each do |server|
		# 	if delegate_info[i]
		# end

		return 1
	end

	def exists_check(ip_addr, port)
    	@file_refs.execute("SELECT 1 FROM FileServer WHERE ip_addr=\"#{ip_addr}\" AND port=#{port.to_i};").length > 0
	end

	def regex_match(connection, regex)
		arg = connection.gets
		arg =~ regex
		return $1
	end

end