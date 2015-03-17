module ApplicationHelper
  # Based on https://gist.github.com/roberto/3344628

  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success"   # Green
      when "error"
        "alert-danger"    # Red
      when "alert"
        "alert-warning"   # Yellow
      when "notice"
        "alert-info"      # Blue
      else
        flash_type.to_s
    end
  end

  def title(page_title)
    content_for :title, page_title.to_s
  end

end
