# frozen_string_literal: true

# It's superclass of all other models we create in app/models
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
