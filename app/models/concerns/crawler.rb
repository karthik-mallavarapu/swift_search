
module Crawler

	extend ActiveSupport::Concern

  include Robots

	EXCLUDE_PATTERN = /.(jpg|jpeg|png|gif|pdf|svg|mp4)\z/
	URL_LIMIT = 100

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
				uri = Addressable::URI.parse(Addressable::URI.encode(link))
				if uri.absolute? && uri.hostname == domain &&
				(uri.scheme == "http" || uri.scheme == "https")
				uri.to_s
				elsif uri.relative?
					Addressable::URI.parse(Addressable::URI.
					encode(base_url)).join(uri).to_s
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

	def crawl
		workers = (0..4).map do
			Thread.new do
				while (!queue_empty? and page_visit_len < URL_LIMIT) do
					url = thread_safe_op do
		      	dequeue
					end
		      unless invalid?(url)
						thread_safe_op { visit_page(url) }
						begin
		        	index_page(url)
						ensure
							ActiveRecord::Base.connection_pool.release_connection
						end
		        urls = scrape_page(url)
		        thread_safe_op { urls.each { |u| enqueue(u) } }
		      end
		    end
			end
		end
		workers.map(&:join)
  end

	def visited? (url)
    visited_pages.include? url
  end

  def invalid?(url)
    visited?(url) || disallowed?(url) || !reachable?(url) || has_fragment?(url)
  end

  def queue_empty?
    pages_to_visit.empty?
  end

	def disallowed?(url)
    !!(url =~ EXCLUDE_PATTERN) || !robots_allowed?(url)
  end

	def has_fragment?(url)
		!(Addressable::URI.parse(Addressable::URI.encode(url)).fragment.nil?)
	end

	def reachable?(url)
		return true if get_page(url)
		false
	end

  def page_visit_len
    visited_pages.length
  end

	def visit_page(url)
    visited_pages << url
  end

  def enqueue(url)
    pages_to_visit.add(url)
  end

  def dequeue
    url = pages_to_visit.take(1).join
		pages_to_visit.subtract([url])
		return url
  end

end
