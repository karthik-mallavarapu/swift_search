module Robots

	extend ActiveSupport::Concern

	def crawlable?
    return true if robots_page.nil?
    populate_robots_urls
    return robots_urls["/"]
  end

	def populate_robots_urls
		if page = robots_page
			entries = robots_page.content.split("\n").select {|i| (i =~ /(Disallow:)|(Allow:)/) == 0 }
	    entries.each do |entry|
	      permission, url = entry.split(":")
	      robots_urls[URI(base_url).merge(URI.encode(url.strip)).to_s] = (permission == "Allow")
	    end
		end
	end

	def allowed?(url)
    robots_urls[URI.encode(url)]
	end

	private

	def robots_page
		robots_url = URI(base_url).merge(URI('robots.txt')).to_s
		begin
			return Mechanize.new.get(robots_url)
		rescue Mechanize::ResponseCodeError => e
			return nil
		end
	end

end
