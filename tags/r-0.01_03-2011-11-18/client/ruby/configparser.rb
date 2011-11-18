#!/usr/bin/env ruby
# DESCRIPTION: parses configuration files compatable with Python's ConfigParser

class ConfigParser < Hash
	def initialize(fname)
		section = nil
		key = nil
		File.open(fname,"r").each_line do |line|
			unless(line =~ /^#/)
				begin
					if line =~ /^(.+?)\s*[=:]\s*(.+)$/ # handle key=value lines
						if section
							self[section] = {} unless self[section]
							key = $1
							self[section][key] = $2
						else
							key = $1
							self[key] = $2
						end
					elsif line =~ /^\[(.+?)\]/ # handle new sections
						section = $1
					elsif line =~ /^\s(.+?)$/ # handle continued lines
						if section
							self[section][key] += "\n#{$1}";
						else
							self[key] += "\n#{$1}"
						end
					end
				end
			end
		end
		# handle substitutions
		self.each_key do |k|
			if self[k].is_a? Hash
				self[k].each_key do |j|
					self[k][j].gsub!(/\$\((.+?)\)/) {|x| self[k][$1]}
				end
			else
				self[k].gsub!(/\$\((.+?)\)/) {|x| self[$1]}
			end
		end
	end
end

if __FILE__ == $0
	require 'pp'
	if ARGV.length == 0
		puts "Usage: $0 <config> [<config> ...]"
		exit
	end
	
	ARGV.each do |file|
		pp ConfigParser.new(file)
	end
end