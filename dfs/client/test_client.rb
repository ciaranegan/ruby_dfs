require_relative 'dfs_client.rb'

class TestClient

	def initialize()
		@client_stub = DFSClient.new("localhost", 8000)
	end

	def show_menu()
		puts "1. Upload file"
		puts "2. Dpwnload file"
		selection = gets.chomp
		if selection == '1'
			upload_file
		else selection == '2'
			download_file
		end
	end

	def upload_file()
		puts "Please enter a file to be uploaded"
		filename = gets.chomp
		puts filename
		@client_stub.upload_file(filename)
		self.show_menu()
	end

	def download_file()
		puts "Please enter a file to be downloaded"
		filename = gets.chomp
		@client_stub.download_file(filename)
		self.show_menu()
	end

end

client = TestClient.new()
client.show_menu()