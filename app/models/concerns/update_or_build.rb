module UpdateOrBuild

  def update_or_build(attributes = nil, options = {}, &block)
    first.try(:update_attributes, attributes) || scoping{ proxy_association.build(attributes, &block)}
  end

end
