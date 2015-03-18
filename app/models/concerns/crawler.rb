
module Crawler

	extend ActiveSupport::Concern
  include Robots

	EXCLUDE_PATTERN = /.(jpg|jpeg|png|gif|pdf|svg|mp4)\z/

	def scrape_page(url)
		page = get_page(url)
		return [] if page.nil?
		links = page.search('a')
		urls = links.map { |link|	link['href'] }.compact.uniq
		filter_urls(urls).compact.uniq
	end

	def get_page(url)
		begin
			return Mechanize.new.get(url)
		rescue Exception => e
			Rails.logger.debug "Get #{url} resulted in #{e.message}"
		end
	end

	def filter_urls(urls)
		urls.map do |link|
			begin
				uri = URI(URI.encode(link))
				if uri.absolute? && uri.hostname == domain &&
				(uri.scheme == "http" || uri.scheme == "https")
					URI.decode(uri.to_s)
				elsif uri.relative?
					URI.decode(URI(URI.encode(base_url)).merge(uri).to_s)
				end
			rescue Exception => e
				Rails.logger.debug "Warning: #{e.message}"
				next
			end
		end
	end

	def page_title(url)
		if page = get_page(url)
			page.title
		end
	end
end
