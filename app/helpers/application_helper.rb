module ApplicationHelper
  def page_title(page_title)
    content_for(:page_title) { page_title.html_safe }
  end

  def page_subtitle(page_subtitle)
    content_for(:page_subtitle) { page_subtitle.html_safe }
  end

  def page_title_right(page_title_right)
    content_for(:page_title_right) { page_title_right.html_safe }
  end

  def current_url
    "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
  end

  def full_url(path)
    "#{request.protocol}#{request.host_with_port}#{path}"
  end

  # from http://www.kensodev.com/2012/03/06/better-simple_format-for-rails-3-x-projects/
  # same as simple_format except it does not wrap all text in p tags
  def simple_format_no_tags(text, _html_options = {}, options = {})
    text = '' if text.nil?
    text = smart_truncate(text, options[:truncate]) if options[:truncate].present?
    text = sanitize(text) unless options[:sanitize] == false
    text = text.to_str
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    #   text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
    text.html_safe
  end
end
