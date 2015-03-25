class Page < ActiveRecord::Base

	extend FriendlyId

  searchkick

	belongs_to :site

	validates :url, presence: true, uniqueness: true
	validates :content, presence: true
	validates :slug, presence: true

	friendly_id :title, use: :slugged

	def self.search_query(query, site_id)
		results = search query, where: {site_id: site_id}, highlight: true,
		limit: 10, fields: [:title, :content]
		final_results = []
		results.with_details.each do |records|
			final_results << {
				title: get_detail(records, :title),
				url: get_detail(records, :url),
				content: get_detail(records, :content)
			}
		end
		final_results
	end

	def self.get_detail(records, attr)
		if last = records.last
			if last[:highlight][attr]
				return last[:highlight][attr].html_safe
			end
		end
		return records.first.send(attr).html_safe[0..300]
	end

end
