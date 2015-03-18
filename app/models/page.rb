class Page < ActiveRecord::Base

	extend FriendlyId

  searchkick
  
	belongs_to :site

	validates :url, presence: true, uniqueness: true
	validates :content, presence: true
	validates :slug, presence: true

	friendly_id :title, use: :slugged

end

