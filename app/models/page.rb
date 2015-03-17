require 'elasticsearch/model'

class Page < ActiveRecord::Base

	extend FriendlyId

  
	belongs_to :site

	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks

	validates :url, presence: true, uniqueness: true
	validates :content, presence: true
	validates :slug, presence: true

	friendly_id :title, use: :slugged

end

Page.import
