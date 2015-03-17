class SitesController < ApplicationController

	before_action :find_site, only: [:reload, :show]

	def index
		@sites = Site.all
	end

	def create
		@site = Site.new(site_params)
		@site.process
		if @site.save
			render json: @site, status: :created, location: @site
		else
			render json: {"message" => @site.errors.full_messages},
			status: :unprocessable_entity
		end
	end

	def show

	end

	def reload
		@site.process
		if @site.save
			render json: {"message" => "Site has been updated."}, status: :accepted
		else
			render json: {"message" => @site.errors.full_messages},
			status: :unprocessable_entity
		end
	end

	private

	def find_site
		@site = Site.friendly.find(params[:id])
	end

	def site_params
		params.require(:site).permit(:url)
	end

end
