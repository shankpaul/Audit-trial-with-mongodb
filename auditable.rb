# class for Audit-trial
module Auditable
	require 'mongo'
	cattr_accessor :signed_user	
	cattr_accessor :remote_ip	
	cattr_accessor :http_user_agent
	cattr_accessor :request_uri
	cattr_accessor :params	
	def init
		@client = Mongo::Client.new([MONGODB_URL], :database => 'audit_trial')		
		@audit_collection = @client[:log]
	end
	def self.included(base)
		base.after_create ->(obj) { log('create') }
		base.after_update ->(obj) { log('update') }
		base.after_destroy ->(obj) { log('delete') }
  end
  
	def log action		
		init		
		user = self.signed_user.to_json rescue nil
		user_id = self.signed_user.id rescue nil
		doc = { 
			user_id: user_id ,
			user: user, 
			action: action,
			object: self.to_json,
			object_id: self.id,
			object_type: self.class.to_s,
			time: DateTime.now.to_s,
			remote_ip: self.remote_ip,			
			request_uri: self.request_uri,
			http_user_agent: self.http_user_agent,
			params: self.params
			 }
		begin 
			result = @audit_collection.insert_one(doc)
			if result
				logger.info "Data saved to log # #{action}"
			end
		rescue
			logger.info "log 	failed"
		end
	end

	def self.fetch_all
		@client = Mongo::Client.new([MONGODB_URL], :database => 'audit_trial')		
		@audit_collection = @client[:log]
		p "================ Audit Trial Collection ============"
		p "|---------------------------------------------------|"
		p "| User ID | Action | Object Type   |     Time       "
		p "|---------------------------------------------------|"
		@audit_collection.find.each do |item|			
			user_id = item["user_id"] || "NIL"
			action = item["action"]
			object_type = item["object_type"] || "NIL"
			time = item["time"].to_s
		 	p "|#{user_id}|#{action}|#{object_type}|#{time}"
		 	p "|--------------------------------------------------|"
	end


	end
		
end
