describe Robots do

  class Client

    attr_reader :base_url
    attr_accessor :robots_urls

    include Robots
    include Crawler

    def initialize(url)
      @base_url = url
      @robots_urls = Hash.new
    end
  end

  def uri_to_url(uri, base_url)
    URI(base_url).merge(URI(uri)).to_s
  end

  subject(:client) { Client.new("https://www.google.com") }

  context "when robots.txt returns a 404, " do

    before {
      stub_request(:get, "https://www.google.com/robots.txt").
      with(headers: {'Accept'=>'*/*'}).
      to_return(status: 404,
      body: "", headers: {})
    }

    it "allows crawling if no robots.txt file is found" do
      expect(client.crawlable?).to be true
    end

    it "does not add any entries to robots_urls" do
      client.populate_robots_urls
      expect(client.robots_urls.empty?).to be true
    end

    it "allows urls for crawling" do
      url = URI(client.base_url).merge(URI("images")).to_s
      client.crawlable?
      expect(client.robots_allowed?(url)).to be true
    end

  end


  context "when robots.txt returns a 200, " do

    before {
      body = File.read("#{Rails.root}/spec/fixtures/google.txt")
      stub_request(:get, "https://www.google.com/robots.txt").
      with(headers: {'Accept'=>'*/*'}).
      to_return(status: 200,
      body: body, headers: {})
      client.populate_robots_urls
    }

    it "allow crawlers" do
      expect(client.crawlable?).to be true
    end

    it "populates urls from robots.txt" do
      expect(client.robots_urls.empty?).not_to be true
    end

    it "populates disallowed urls from robots.txt" do
      url = uri_to_url("/shopping/product/", client.base_url)
      expect(client.robots_allowed?(url)).to be false
    end

    it "populates allowed urls from robots.txt" do
      url = uri_to_url("/mail/help/", client.base_url)
      expect(client.robots_allowed?(url)).to be true
    end

    it "allows url without an entry to crawl" do
      url = uri_to_url("/shopping", client.base_url)
      expect(client.robots_allowed?(url)).to be true
    end

    it "disallows url if url parent path is disallowed" do
      url = uri_to_url("/m/news/", client.base_url)
      expect(client.robots_allowed?(url)).to be false
    end

    it "allows url if it has a specific entry even if url parent path is disallowed" do
      url = uri_to_url("/m/finance", client.base_url)
      expect(client.robots_allowed?(url)).to be true
    end

  end

end
