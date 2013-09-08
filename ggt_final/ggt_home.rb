require 'openssl'
require 'fileutils'

################################################################
# This is the 'home', or local, part of the GGT handler.
# This script sets up the public directory, encrypts all of the local XLS
# files and moves them to the create public directory
#
# This script MUST be in the same directory as the 'ggt' directory!
################################################################

#encrypt all of the .xls files in this directory, return a a list of their names
def encrypt_files(names, key)
	enc_names = Array.new
	counter = 0 

	puts 'Encrypting files...'

	names.each do |name|
		enc_name = name.gsub('.xls', '.enc')
		encrypt(name, enc_name, key)
		enc_names << enc_name
		counter += 1
	end

	puts 'done, encrypted ' + counter.to_s + ' files'
	return enc_names
end

# move each file from this directory to the sheets section of the public directory
def move_files(file_names, directory)
	puts 'Moving files to the public directory...'

	counter = 0
	path = File.expand_path(directory + '/sheets')

	file_names.each do |name|
		FileUtils.move(name, path);
		counter += 1
	end
	
	puts 'done, moved ' + counter.to_s + ' files'
end

#remove all the files in the server directory that are not present in this 
#directory ( so server directory mirrors this one )
def remove_files(enc_files, directory)
	puts 'Removing files from public directory that are no longer present in home...'
	names = Array.new
	c = 0

	path = File.expand_path(directory + '/sheets')

	Dir.entries(path).each do |f|
		if f.include? '.enc'
			names << f
		end
	end

	names.each do |n|
		unless enc_files.include? n
			#if the file exists in the public directory but not here, delete it
			FileUtils.remove(path + '/' + n)

			puts 'Removed ' + n + ' from public directory'
			c += 1
		end
	end

	puts "done, removed " + c.to_s + ' files'
end

#get all the files in the directory that match an extension
def get_files
	names = Array.new

	Dir.glob("*.xls").each do |f| 
		names << f
	end

	return names
end


#check if the GGT suite is present in the public directory
#creates and/or fixes and issues it finds
def check_server(server_path)
	#check to make sure the directory exists
	puts 'Checking server directories and files...'

	#path has to be passed in as "~/public/html/ggt" for production version

	path = File.expand_path server_path

	#Check LOCAL directories
	return false unless check_local_directories './ggt'
	return false unless check_local_directories './ggt/sheets'
	return false unless check_local_directories './ggt/framework'
	
	unless File.exist?('./ggt/sheets/ggt_handler.php')
		puts 'FATAL ERROR: the ggt server is no longer present at "/ggt/sheets/ggt_handler.php."'
		return false;	
	end

	#Check SERVER directories
	unless File.directory? path
		puts 'Main Directory does not exist'
		create_folder path
	end

	unless File.directory? path + '/sheets'
		puts 'Sheets Directory does not exist'
		create_folder path + '/sheets'
	end

	## check the framework directory and size 
	unless File.directory? path + '/framework'
		puts 'Framework Directory does not exist'
		create_folder path + '/framework'
		FileUtils.cp_r('./ggt/framework', path)
	end

=begin
	if File.size('./ggt/framework') != File.size(path + '/framework')
		puts 'Framework has been modified, cleaning directory...'

		FileUtils.remove(path + '/framework')
		create_folder path + '/framework'
		FileUtils.copy_entry('./ggt/framework', path + '/ggt/framework')

		puts 'done'
	end
=end

	#check server presence and size
	unless File.exist?(path + '/sheets/ggt_handler.php')
		puts 'Server does not exist'
		puts 'Copying server...'
		FileUtils.copy_file('./ggt/sheets/ggt_handler.php', path + '/sheets/ggt_handler.php')
		puts 'done'
	end

	if File.size(path + '/sheets/ggt_handler.php') != File.size('./ggt/sheets/ggt_handler.php')
		puts 'Server has been modified, replacing...'

		FileUtils.remove(path + '/sheets/ggt_handler.php')
		FileUtils.copy_file('./ggt/sheets/ggt_handler.php', path + '/sheets/ggt_handler.php')

		puts 'done'
	end

	puts 'done'
	return true
end

def check_local_directories(directory)
	unless File.directory? directory
		puts 'FATAL ERROR: the ' + directory + ' directory cannot be found in this directory. Please
		make sure you have not moved this script or deleted the directory.'

		return false
	end

	return true
end

#create the folder in the appropriate location for the GGT fils
def create_folder(directory)
	puts 'Creating directory \'' + directory + '\'...'
	FileUtils.mkdir_p directory
	puts 'done'
end

# encryption
def encrypt(in_name, out_name, key)
	cipher = OpenSSL::Cipher.new('aes-256-cbc')
	cipher.encrypt
	cipher.key = key
	cipher.iv = '1234567812345678'

	buf = ""
	File.open(out_name, "wb") do |outf|
		  File.open(in_name, "rb") do |inf|
		    while inf.read(4096, buf)
		      	outf << cipher.update(buf)
		    end

		    outf << cipher.final
		end
	end
end

# decryption
def decrypt(in_name, out_name)
	cipher = OpenSSL::Cipher.new('aes-256-cbc')
	cipher.decrypt
	cipher.key = key
	cipher.iv = iv # key and iv are the ones from above

	buf = ""
	File.open(out_name, "wb") do |outf|
		  File.open(in_name, "rb") do |inf|
		    while inf.read(4096, buf)
		      	outf << cipher.update(buf)
		    end

		    outf << cipher.final
		end
	end
end


######## COMMAND METHODS-- controls the flow of the script
# get the key from the user, return as hex encoded ascii
def get_key
	asking = true

	while asking do
		puts 'Please enter a password: '
		key = gets.chomp

		if(key.size < 1)
			puts 'Password too short' 
		else
			asking = false 
		end
	end

	#validate the key...

	#hash the key (has to be 32 bytes long for sha-256)
	hash = Digest::SHA2.hexdigest(key)
	
	return hash;
end

#encrypt and move all the files in the local directories, deleting the ones in the
#server directory that dont appear here
def encrypt_move(directory, key)
	file_names = get_files
	#puts 'FILE NAMES ' + file_names.to_s
	
	enc_names = encrypt_files(file_names, key)
	#puts 'ENC NAMES ' + enc_names.to_s
	
	move_files(enc_names, directory)
	remove_files(enc_names, directory)
end

######## SCRIPT LOGIC
## ggt_home.rb about 	details the functionality of the script


######## MAIN SCRIPT LOGIC
def main
	puts 'Starting GGT Home Script'
	#puts 'Please enter "ruby ggt_home.rb about" to learn more about this script'

	directory = '/var/www/ggt_testing/ggt'

	## make sure the 'ggt' directory is present in this directory
	unless check_server directory
		puts 'Quitting'
		return false
	end
	## Ask the user for a password, validate
	key = get_key;

	#encrypt and move the files
	encrypt_move(directory, key)

	puts 'GGT Home Script finished'
end

#FileUtils.cp_r('./ggt/sheets/ggt_handler.php', '/var/www/ggt')


main
#puts check_server
# create_folder
#puts get_key
#key = get_key

#encrypt('samplefile.xls', 'samplefile.enc', key)