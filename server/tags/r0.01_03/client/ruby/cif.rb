#!/usr/bin/env ruby
# DESCRIPTION: queries collective-intelligence-framework sources
require 'json'
require 'open-uri'
require 'digest/sha1'
require 'zlib'
require 'base64'
require 'configparser'
require 'openssl'
require 'pp'
require 'snort_rule'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module CIF
	class Client
		attr_accessor :fields
		attr_writer :severity, :restriction, :fields
		def initialize(host,apikey,severity=nil,restriction=nil,nolog=false)
			@host = host
			@apikey = apikey
			@severity = severity
			@nolog = nolog
			@restriction = restriction
		end
		
		def query(q,severity=nil,restriction=nil,nolog=false)
			params = {'apikey' => @apikey}
			params['restriction'] = restriction || @restriction if restriction || @restriction
			params['severity'] = severity || @severity if severity || @severity
			params['nolog'] = 1 if nolog || @nolog
			s = "#{@host}/#{q}?"+params.map{|k,v| "#{k}=#{v}"}.join("&")
			doc = open(s).read
			data = JSON.parse(doc)
			@response_code = data['status']
			if data['data'] and data['data']['result']
				feed = data['data']['result']['feed']
			end
			if data['data'] and data['data']['result'] and data['data']['result']['hash_sha1']
				hash = data['data']['result']['hash_sha1']
				sha1 = Digest::SHA1.new.update(feed).to_s
				raise "data did not pass the SHA1 checksum" unless sha1 == hash
				feed = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(feed)))
			end
			feed
		end
	end
end

if __FILE__ == $0
	require 'getoptlong'
	require 'pp'
	require 'structformatter'
	require 'yaml'
	def usage
		puts "Usage: #{$0} [-h] [-c <config>] [-s <severity>] [-r <restriction>] [-n] [-x|-j|-y|-t|-o] [-d <delim>] <query> [<query> ...]"
		puts "-h               prints this help"
		puts "-c <config>      specifies a configuration file with the API key and host endpoint"
		puts "-s <severity>    severity: low, medium, or high"
		puts "-r <restriction> examples: need-to-know and private"
		puts "-n               requests the server to not log the query"
		puts "-x               outputs in XML"
		puts "-j               outputs in JSON"
		puts "-y               outputs in YAML"
		puts "-o               outputs in SNORT formatted rules"
		puts "-t               outputs in ASCII text"
		puts "-d <delimiter>   specifies the delimiter for text (default tab)"
		puts "<query>          terms, usually domains, IPs, or CIDRs, that are being queried from the CIF"
		exit
	end
	
	def format_results(results,format,delim)
		return unless results
		case format
		when 'xml'
			results.to_xml
		when 'json'
			results.to_json
		when 'yaml'
			results.to_yaml
		when 'text'
			fields = nil
			output = ""
			results['items'].each do |item|
				unless fields
					fields = item.keys 
					output += fields.join(delim)+"\n"
				end
				sep = ""
				fields.each do |field|
					output += sep
					output += item[field].chomp if item[field]
					sep = delim
				end
				output += "\n"
			end
			output
		when 'snort'
			sid = 1
			output = ""
			results['items'].each do |item|
				next unless item['address']
				portlist = item['portlist']
				if item['rdata']
					portlist = 53
				end
				rule = Snort::Rule.new
				rule.dst = item['address']
				rule.dport = portlist || 'any'
				rule.opts['msg'] = "#{item['restriction']} - #{item['description']}" if item['restriction'] and item['description']
				rule.opts['threshold'] = 'type limit,track by_src,count 1,seconds 3600'
				rule.opts['sid'] = sid
				sid += 1
				rule.opts['reference'] = item['alternativeid'] if item['alternativeid']
				output += rule.to_s + "\n"
			end
			output
		end
	end
	
	opts = GetoptLong.new(
		[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
		[ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--severity', '-s', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--restriction', '-r', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--nolog', '-n', GetoptLong::NO_ARGUMENT ],
		[ '--xml', '-x', GetoptLong::NO_ARGUMENT ],
		[ '--json', '-j', GetoptLong::NO_ARGUMENT ],
		[ '--yaml', '-y', GetoptLong::NO_ARGUMENT ],
		[ '--delim', '-d', GetoptLong::REQUIRED_ARGUMENT ],
		[ '--text', '-t', GetoptLong::NO_ARGUMENT ],
		[ '--snort', '-o', GetoptLong::NO_ARGUMENT ]
	)
	config = "#{ENV['HOME']}/.cif"
	severity = nil
	restriction = nil
	nolog = false
	format = 'text'
	delim = "\t"
	
	opts.each do |opt, arg|
		case opt
		when '--help'
			usage
		when '--config'
			config = arg
		when '--severity'
			severity = arg
		when '--restriction'
			restriction = arg
		when '--nolog'
			nolog = true
		when '--xml'
			format = 'xml'
		when '--json'
			format = 'json'
		when '--yaml'
			format = 'yaml'
		when '--snort'
			format = 'snort'
		when '--delim'
			delim = arg
		when '--text'
			format = 'text'
		else
			usage
		end
	end
	usage if ARGV.length == 0
	config = ConfigParser.new(config)
	host = config['client']['host']
	apikey = config['client']['apikey']
	client = CIF::Client.new(host,apikey,severity,restriction,nolog)
	ARGV.each do |query|
		puts format_results(client.query(query),format,delim)
	end
end