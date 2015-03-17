require 'elasticsearch/model'

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    __elasticsearch__.client = Elasticsearch::Client.new log: true
    __elasticsearch__.client.transport.logger.formatter = proc { |s, d, p, m| "\e[32m#{m}\n\e[0m" }

    include Indexing
    after_touch() { __elasticsearch__.index_document }
  end

  module Indexing

    # Customize the JSON serialization for Elasticsearch
    def as_indexed_json(options={})
      self.as_json(
        include: { pages: { only: [:title, :content]} })
    end
  end
end
