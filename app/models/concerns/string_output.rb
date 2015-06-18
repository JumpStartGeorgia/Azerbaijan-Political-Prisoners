# String output helpers
module StringOutput
  extend ActiveSupport::Concern

  module ClassMethods
    def remove_tags(str)
      str.gsub(/<.*?>/, '') if str.present?
    end
  end
end
