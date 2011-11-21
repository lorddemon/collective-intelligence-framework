#!/usr/bin/env ruby
# DESCRIPTION: generates textual snort rules based on given parameters

module Snort
	class Rule
		attr_accessor :action, :proto, :src, :sport, :dir, :dst, :dport, :opts
		
		def initialize(kwargs={})
			@action = kwargs['action'] || 'alert'
			@proto = kwargs['proto'] || 'IP'
			@src = kwargs['src'] || 'any'
			@sport = kwargs['sport'] || 'any'
			@dir = kwargs['dir'] || '->'
			@dst = kwargs['dst'] || 'any'
			@dport = kwargs['dport'] || 'any'
			@opts = kwargs['opts'] || {}
		end
		
		def to_s(options_only=false)
			rule = ""
			rule = [@action, @proto, @src, @sport, @dir, @dst, @dport, '( '].join(" ") unless options_only
			opts.keys.sort.each do |k|
				rule += k if opts[k];
				unless opts[k] == true
					rule += ":#{opts[k]}"
				end
				rule += "; "
			end
			rule += ")" unless options_only
			rule
		end
	end
end

if __FILE__ == $0
	require 'getoptlong'
	
	def usage
		puts "Usage: #{$0} [-h] [-a <action>] [-p <protocol>] [-s <srcip>] [-x <srcport>] [-w <direction>] [-d <dstip>] [-c <dstport>] [-o <key:value>] [-o <key:value> ...]"
		puts "-h             This text."
		puts "-a <action>    alert, log, pass, ... : alert"
		puts "-p <protocol>  ip, udp, tcp, ... : ip"
		puts "-s <srcip>     dotted quad IP address : any"
		puts "-x <srcport>   port number : any"
		puts "-w <direction> ->, <-, or <> : ->"
		puts "-d <dstip>     dotted quad IP address : any"
		puts "-c <dstport>   port number : any"
		puts "-o <key:value> option/value pairs, specify multiple times for multiple options"
		exit
	end
	
	opts = GetoptLong.new(
		[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
		[ '--action', '-a', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--proto', '-p', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--src', '-s', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--sport', '-x', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--dir', '-w', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--dst', '-d', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--dport', '-c', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--opts', '-o', GetoptLong::REQUIRED_ARGUMENT ]
	)
	
	rule = Snort::Rule.new
	opts.each do |opt, arg|
		case opt
		when '--help'
			usage
		when '--action'
			rule.action = arg
		when '--proto'
			rule.proto = arg
		when '--src'
			rule.src = arg
		when '--sport'
			rule.sport = arg.to_i
		when '--dir'
			rule.dir = arg
		when '--dst'
			rule.dst = arg
		when '--dport'
			rule.dport = arg.to_i
		when '--opts'
			if arg =~ /(.+?)\s*[=:]\s*(.+)/
				rule.opts[$1] = $2
			else
				rule.opts[arg] = true
			end
		else
			usage
		end
	end
	
	puts rule.to_s
end