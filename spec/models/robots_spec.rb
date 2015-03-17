describe Robots do
  
  class Dummy

    attr_reader :base_url
    attr_accessor :disallowed_urls

    def initialize(url)
      @base_url = url 
    end
  end

  describe '#populate_disallowed_urls' do
    
    it "populates valid entries from robots.txt" do

    end

  end


end
