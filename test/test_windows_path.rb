require 'test/unit'
$:.unshift File.dirname(__FILE__) + "/../lib" unless $:.include?(File.dirname(__FILE__) + "../lib")
require 'windows_path'

class WindowsPathTests < Test::Unit::TestCase
	
	def setup
		@path = WindowsPath.new
	end
	
	def test_clean
		# add some non-existent directories
		fake = add_fake
		
		assert_dir_found fake, "Fake directory not added to current path."
		@path.clean
		assert_dir_not_found fake, "Fake directory found in current path after cleaning!"
	end
	
	def test_clean_dups
		fake = add_fake_dup

		assert_dir_found fake, "Duplicate directory not found in path."
		assert_dup_found fake, "Did not find the right number of duplicates directories in the path."
		
		@path.clean
		assert_dir_not_found fake, "Duplicate directory found in current path after cleaning!"
	end
	
	def test_clean_and_notfound
		fake_dup = add_fake_dup
		fake_not_found = add_fake

		assert_dup_found fake_dup, "Did not find the right number of duplicates directories in the path."
		assert_dir_found fake_not_found, "Nonexistent directory not found in path."

		@path.clean
		assert_dir_not_found fake_dup, "Duplicate directory found in current path after cleaning!"
		assert_dir_not_found fake_not_found, "Nonexistent directory found in current path after cleaning!"
	end
	
	def test_remove_dir
		fake_dir = add_fake
		assert_dir_found fake_dir, "Fake directory not found in path."
		@path.remove fake_dir
		assert_dir_not_found fake_dir, "Fake directory found in path after removal."
	end
	
	def test_remove_glob
		fake_dir = add_fake
		assert_dir_found fake_dir, "Fake directory not found in path."
		fake_glob = fake_dir.chop << "*"
		@path.remove fake_glob
		assert_dir_not_found fake_dir, "Fake directory not removed by glob: #{fake_glob}"
	end
	
	def test_remove_regexp
		fake_dir = add_fake
		assert_dir_found fake_dir, "Fake directory not found in path."
		fake_regex = Regexp.new("^" << fake_dir.gsub('\\', '\\\\\\\\') << "$")
		@path.remove fake_regex
		assert_dir_not_found fake_dir, "Fake directory not removed by regex: #{fake_regex}"
	end
	
	def test_remove_case_sensitive_glob
		# Ensure matches with different case works.
		fake_dir = add_fake "C:\\program files"
		fake_glob = "C:\\PROGRAM*"
		@path.remove fake_glob
		assert_dir_not_found fake_dir, "Fake directory not removed by glob: #{fake_glob}"
	end

	def test_remove_glob_two_stars
		# Test that a glob with wildcards on both ends works
		fake_dir = add_fake "C:\\program files"
		fake_glob = "*PROGRAM*"
		@path.remove fake_glob
		assert_dir_not_found fake_dir, "Fake directory not removed by glob: #{fake_glob}"
	end

	def test_remove_glob_single_char
		# Test that a glob with question mark works
		fake_dir = add_fake 
		fake_glob = fake_dir.chop << "?"
		@path.remove fake_glob
		assert_dir_not_found fake_dir, "Fake directory not removed by glob: #{fake_glob}"
	end

	# Makes a directory guarnteed not to exist
	def make_fake_dir(dir)
		cnt = 1
		fake_dir = dir
		while @path.paths.include? fake_dir
			fake_dir = dir << cnt
			cnt += 1
		end
		
		fake_dir
	end

	# Add a fake path	
	def add_fake(base = "C:\\foobar")
		@path.paths << fake = make_fake_dir(base)
		fake
	end
	
	# Add a duplicated fake path 
	def add_fake_dup
		fake = add_fake
		@path.paths << fake
		
		fake
	end
	
	def assert_dir_found(dir, msg)
		assert @path.paths.include?(dir), msg
	end
		
	def assert_dir_not_found(dir, msg)
		assert ! @path.paths.include?(dir), msg
	end
	
	def assert_dup_found(dir, msg)
		cnt = 0
		@path.paths.each { |p| cnt += 1 if p == dir }
		assert cnt == 2, msg
	end
end
