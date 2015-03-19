class SearchController < ApplicationController

	before_action :find_site, only: [:search]

	def search
		pages = Page.search_query(params[:search_term], @site.id)
		render json: pages
	end

	private

	def find_site
		@site = Site.friendly.find(params[:site_id])
	end

end
