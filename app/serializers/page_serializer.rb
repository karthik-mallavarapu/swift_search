class PageSerializer < ActiveModel::Serializer
  attributes :title, :url, :content
end
