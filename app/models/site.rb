require 'open-uri'

class Site < ActiveRecord::Base

	extend FriendlyId

	include Crawler

	has_many :pages, dependent: :destroy, extend: UpdateOrBuild

	validates :title, presence: true
	validates :url, presence: true, uniqueness: true
	validates :slug, presence: true

  friendly_id :title, use: :slugged

	URL_LIMIT = 100

	attr_reader :visited_pages, :base_url, :domain

	def process
		raise "Site not reachable" unless reachable?(self.url)
		begin
			self.title = page_title(self.url)
			setup
			crawl
		rescue Exception => e
			errors[:base] << e.message
		end
	end

	def crawl
		# Populate disallowed paths from robots.txt and check for sitemap
    while (!queue_empty? and page_visit_len < URL_LIMIT) do
      url = dequeue
      unless ignorable?(url)
        index_page(url)
        urls = scrape_page(url)
        urls.each { |u| enqueue(u) }
      end
    end
  end

	private

	def index_page(url)
		title = page_title(url)
		page = open(url).read
		content = Readability::Document.new(page, :remove_empty_nodes => true).content.
		gsub(/<\/*([a-z]*)>/, '')
		page = self.pages.where(url: url).update_or_build(title: title, content: content)
		visit_page(url)
	end

	def setup
		@base_url = self.url
    @domain = URI(URI.encode(@base_url)).hostname
    @visited_pages  = []
    @pages_to_visit = []
    enqueue(@base_url)
	end

	def visited? (url)
    @visited_pages.include? url
  end

  def ignorable?(url)
    visited?(url) || disallowed?(url) || !reachable?(url) || has_fragment?(url)
  end

  def queue_empty?
    @pages_to_visit.empty?
  end

	def disallowed?(url)
    !!(url =~ EXCLUDE_PATTERN)
  end

	def has_fragment?(url)
		!(URI(URI.encode(url)).fragment.nil?)
	end

	def reachable?(url)
		return true if get_page(url)
		false
	end

  def page_visit_len
    @visited_pages.length
  end

	def visit_page(url)
    @visited_pages << url
  end

  def enqueue(url)
    @pages_to_visit << url unless @pages_to_visit.include? url
  end

  def dequeue
    @pages_to_visit.shift
  end

end
