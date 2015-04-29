require 'open-uri'
require 'set'

class Site < ActiveRecord::Base

  extend FriendlyId

  include Crawler

  has_many :pages, dependent: :destroy, extend: UpdateOrBuild

  validates :title, presence: true
  validates :url, presence: true, uniqueness: true
  validates :slug, presence: true

  friendly_id :title, use: :slugged

  attr_reader :pages_to_visit, :visited_pages, :visited_pages, :base_url, :domain, :robots_urls

  def process
    raise "Site not reachable" unless reachable?(self.url)
    begin
      self.title = page_title(self.url)
      setup
      if crawlable?
        crawl
      else
        raise "Something went wrong"
      end
    rescue Exception => e
      errors[:base] << e.message
    end
  end

  def setup
    @base_url = self.url
    @domain = Addressable::URI.parse(Addressable::URI.encode(@base_url)).hostname
    @visited_pages  = Set.new
    @pages_to_visit = Set.new
    @mutex = Mutex.new
    @robots_urls = Hash.new
    enqueue(@base_url)
  end

  private

  def thread_safe_op(&block)
    @mutex.synchronize do
      yield
    end
  end

  def index_page(url)
    title = page_title(url)
    page = Mechanize.new.get url
    content = Readability::Document.new(page.content,
    :remove_empty_nodes => true).content.gsub(/<\/*([a-z]*)>/, '')
    page = self.pages.where(url: url).update_or_build(title: title, content: content)
  end

end
