module Robots

	extend ActiveSupport::Concern
  
	def crawlable?
		disallowed_urls.each do |path|
			if path == "/"
				return false
			end
		end
		return true
	end

	def populate_disallowed_urls
		robots_url = URI(base_url).merge(URI('/robots.txt'))
		robots_page = get_page(robots_url)
		return if robots_page.nil?
		disallowed = robots_page.content.split("\n")
		.select {|i| (i =~ Regexp.new("Disallow:")) == 0 }
		disallowed_urls = disallowed.map { |i| URI.encode(i.split(":")[1].strip) }
	end

	def allowed? (url)
		disallowed_urls.each do |path|
			if url.include? path
				return false
			end
		end
		return true
	end

end
