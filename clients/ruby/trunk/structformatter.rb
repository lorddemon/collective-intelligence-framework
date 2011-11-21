#!/usr/bin/env ruby
# DESCRIPTION: extends ruby Structs to be outputted as yaml, xml, and json. This is meant to be used as a mixin
require 'json'

class Array
	def render_xml(element_name, element)
		str = ""
		if element.class == Date
			str = "<#{element_name}>#{element.strftime("%Y-%m-%d")}</#{element_name}>"
		elsif element.class == Time or element.class == DateTime
			str = "<#{element_name}>#{element.strftime("%Y-%m-%dT%H:%M:%SZ")}</#{element_name}>"
		elsif element.kind_of? Struct or element.kind_of? Hash or element.kind_of? Array
			str = element.to_xml
		else
			str = "<#{element_name}>#{element}</#{element_name}>"
		end
	end
	def to_xml
		str = "<array>"
		self.each do |item|
			str += render_xml("element",item)
		end
		str += "</array>"
	end
	def to(format)
		case format
		when 'xml'
			self.to_xml
		when 'json'
			self.to_json
		when 'string'
			self.to_s
		else
			raise "invalid format: #{format}, use one of xml, json, or string"
		end
	end
end

class Hash
	def render_xml(element_name, element)
		str = ""
		if element.class == Date
			str = "<#{element_name}>#{element.strftime("%Y-%m-%d")}</#{element_name}>"
		elsif element.class == Time or element.class == DateTime
			str = "<#{element_name}>#{element.strftime("%Y-%m-%dT%H:%M:%SZ")}</#{element_name}>"
		elsif element.kind_of? Struct or element.kind_of? Hash or element.kind_of? Array
			str = element.to_xml
		else
			str = "<#{element_name}>#{element}</#{element_name}>"
		end
	end
	def to_xml
		str = "<hash>"
		self.each do |key,value|
			str += "<element><key>#{key}</key>"
			str += render_xml("value",value)
			str += "</element>"
		end
		str += "</hash>"
	end
	def to(format)
		case format
		when 'xml'
			self.to_xml
		when 'json'
			self.to_json
		when 'string'
			self.to_s
		else
			raise "invalid format: #{format}, use one of xml, json, or string"
		end
	end
end

class Struct
	@@printclass = true
	def Struct::printclass=(pc)
		@@printclass = pc
	end
	def render_xml(element_name, element)
		str = ""
		if element.class == Date
			str = "<#{element_name}>#{element.strftime("%Y-%m-%d")}</#{element_name}>"
		elsif element.class == Time or element.class == DateTime
			str = "<#{element_name}>#{element.strftime("%Y-%m-%dT%H:%M:%SZ")}</#{element_name}>"
		elsif element.kind_of? Struct
			str = element.to_xml
		elsif element.kind_of? Hash or element.kind_of? Array
			str = element.to_xml(element_name)
		else
			str = "<#{element_name}>#{element}</#{element_name}>"
		end
	end
	def to_xml
		children = []
		str = "<#{self.class}"
		self.members.each do |member|
			if self[member].class == Array or self[member].class == Hash or self[member].kind_of? Struct
				children << member
			elsif self[member].class == Date
				str += " #{member}='#{self[member].strftime("%Y-%m-%d")}'"
			elsif self[member].class == Time
				str += " #{member}='#{self[member].strftime("%Y-%m-%dT%H:%M:%SZ")}'"
			else
				str += " #{member}='#{self[member]}'"
			end
		end
		if children.length == 0
			str += ' />'
		else
			str += '>'
			children.each do |member|
				if self[member].class == Array
					str += "<#{member}s>"
					self[member].each do |item|
						str += render_xml(member,item)
					end
					str += "</#{member}s>"
				elsif self[member].class == Hash
					str += "<#{member}s>"
					self[member].each do |key,value|
						str += "<HashElement><key>#{key}</key><value>"
						str += render_xml(member,value)
						str += "</value></HashElement>"
					end
					str += "</#{member}s>"
				elsif self[member].kind_of? Struct
					str += self[member].to_xml
				end
			end
			str += "</#{self.class}>"
		end
	end
	
	def to_json(*a)
		hash = (@@printclass) ? { 'class' => self.class } : {}
		self.members.sort.each do |member|
			hash[member] = self[member]
		end
		hash.to_json(*a)
	end
	
	def to(format)
		case format
		when 'xml'
			self.to_xml
		when 'json'
			self.to_json
		when 'string'
			self.to_s
		else
			raise "invalid format: #{format}, use one of xml, json, or string"
		end
	end
	
	def to_s(sep = " ")
		self.members.map{ |x| self[x].to_s }.join(sep)
	end
	
	def to_s_header(sep = " ")
		self.members.map{ |x| x.to_s }.join(sep)
	end
end
