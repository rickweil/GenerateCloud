class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def full_name
    first_name = (defined? self.first_name) ? self.first_name : ""
    last_name = (defined? self.last_name) ? self.last_name : ""
    first_name + " " + last_name
  end
end
