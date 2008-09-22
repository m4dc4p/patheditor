require 'win32ole'
require 'pathname'

# Specialized array that knows how to compare paths.
class WindowsPathArray < Array
	
	def include?(path)
    # Compare paths case-insensitive, and also checking
    # trailing separators (so c:\program files == c:\program files\)
    self.any? { |p| compare_paths(path, p) }
	end

	def compare_paths(left, right)
    left = Pathname.new(WindowsPath.expand_vars(left.to_s).downcase).cleanpath
    right = Pathname.new(WindowsPath.expand_vars(right.to_s).downcase).cleanpath
    
    return left.eql?(right)
  end

  def <<(p)
    super(p.to_s)
  end
	
  alias_method :add, :<<

	def delete(path)
		self.delete_if { |p| compare_paths(path, p) }
	end
	
	def each
		for i in 0..size - 1
			yield WindowsPath.expand_vars(raw_item(i))
		end
	end
	
	# Preserve access to base class definition of []
	alias_method :raw_item, :[]
	
	def [](idx)
		WindowsPath.expand_vars(super)
	end
end

# Manages access to and updating of windows path setting. 
class WindowsPath
  include Enumerable
  FILE_SEPARATOR = File::ALT_SEPARATOR
	
	# paths is a WindowsPathArray holding all paths in the system.
	attr_accessor :paths

	# Holds a reference to the Win32 Shell COM object.
	def self.shell
    @shell ||= WIN32OLE.new("WScript.Shell")
	end

	# Given a path, expands any environment variables found in it.
	# Returns the expanded path.
	def self.expand_vars(path)
    while m = path.match(/%.*?%/)
      path = path.gsub(m[0], shell.ExpandEnvironmentStrings(m[0]))
    end
		
    path
  end
	
  def initialize
		@source = Hash.new
    @paths = WindowsPathArray.new
		@system = WindowsPath.shell.Environment("System")
		@user = WindowsPath.shell.Environment("User")
		
		[@system, @user].each do |which|
			which.Item("Path").split(";").each do |p|
				@paths.add(p.strip)
				source[p] = which
			end
		end
  end
  
  # Update any changes 
  def update
		# Map paths back to origina environment object
		env = Hash.new
		
		@paths.each do |p|
			o = (source[p] || @user)
			env[o] ||= []
			env[o] << p
		end

		# Update each source object
		env.each { |o, p| o["Item", "Path"] = p.join(";") }
  end
	
	# Cleans the current path of any non-existent or duplicate directories.
	# If a block is given, yields each directory removed along with a
	# the symbol :dup or :notfound. 
	def clean # :yields: path, reason
		nonexistent = []
		found = WindowsPathArray.new
		duplicates = []
		idx = 0 
    @paths.each do |p| 
      pathname = Pathname.new(p).cleanpath
			if ! pathname.exist? 
				nonexistent << p  
			elsif found.include?(pathname)
				duplicates << idx
			else
				found << pathname
			end
			idx += 1
    end

		unless duplicates.empty?
			remove_paths(duplicates) { |p| yield p, :dup if block_given? } 
		end

		unless nonexistent.empty?					
			remove_paths(nonexistent) { |p|  yield p, :notfound if block_given? } 
		end
	end
	
	# Removes paths matching the path given. If path is regular
	# expression, it is matched directly. Any other
	# pattern is treated as a potential shell "glob" 
	# match, which means "*" and "?" are treated 
	# specially. 
	#
	# In all cases, the path(s) removed are yielded.
	def remove(pattern) # :yields: path
		paths_to_remove = []
		@paths.each do |p|
			if pattern.is_a?(Regexp)
				paths_to_remove << p if pattern.match(p)
			else
				paths_to_remove << p if File.fnmatch(pattern, p, File::FNM_CASEFOLD | File::FNM_NOESCAPE)
			end
		end
		
		paths_to_remove.each do |p|
			yield p if block_given?
			@paths.delete(p)
		end
	end

private

	attr_accessor :source
	
  def remove_paths(paths_to_remove)
		adjust = 0
    paths_to_remove.each do |p| 
			if p.is_a?(Fixnum)
				idx = p - adjust # adjust index based on paths removed so far.
				yield @paths[idx] if block_given?
				@paths.delete_at(idx)
			else
				yield p if block_given?
				@paths.delete p
      end
      
      adjust += 1
    end
  end
end
