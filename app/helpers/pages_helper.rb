module PagesHelper
  def real_page_path(page)
    begin
      eval("#{page.name}_path")
    rescue NameError
      page.errors.add(:name, 'does not match any real page')
      return '#'
    end
  end
end
