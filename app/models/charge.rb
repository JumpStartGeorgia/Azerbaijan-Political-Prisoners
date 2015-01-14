class Charge < ActiveRecord::Base
  belongs_to :incident
  belongs_to :article
end
