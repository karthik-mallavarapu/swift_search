module Robots

	extend ActiveSupport::Concern

	# Returns boolean indicating if the site is crawlable according to robots.txt
	def crawlable?
    return true if robots_page.nil?
    populate_robots_urls
    allowed?("/")
  end

	# Populates the contents of robots.txt into a hash. Only looks for allow and
	# disallow statements.
	def populate_robots_urls
		if page = robots_page
			entries = robots_page.content.split("\n").select {|i| (i =~ /(Disallow:)|(Allow:)/) == 0 }
	    entries.each do |entry|
	      permission, url = entry.split(":")
	      robots_urls[URI(base_url).merge(URI.encode(url.strip)).to_s] = (permission == "Allow")
	    end
		end
	end

	# Returns true if url is allowed, false if url is disallowed or if url parent # path is disallowed.
	def allowed?(url)
		if ret_val = robots_urls[url]
    	return ret_val
		else
			robots_urls.each do |u, perms|
				return perms if url.include? u
			end
		end
		return true
	end

	private

	# Get the robots.txt page using mechanize. Returns nil on 404
	def robots_page
		robots_url = URI(base_url).merge(URI('robots.txt')).to_s
		begin
			return Mechanize.new.get(robots_url)
		rescue Mechanize::ResponseCodeError => e
			return nil
		end
	end

end
