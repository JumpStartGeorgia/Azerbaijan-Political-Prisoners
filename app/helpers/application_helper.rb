module ApplicationHelper
  def page_title(page_title)
    content_for(:page_title) { page_title.html_safe }
  end

  def if_can_edit_or_destroy? resource
    if can? :edit, resource or can? :destroy, resource
      yield
    end
  end
end
