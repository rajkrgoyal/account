# frozen_string_literal: true

# Invoice payments
# NOTE: amount field store value in cents not in dollars.
class Payment < ApplicationRecord
  METHODS = {1 => "cash", 2 => "check", 3 => "charge"}.freeze

  # Since external methods pass in a raw_payment_method, we need to set the ID
  # value for storing in the database
  before_validation :set_payment_method_id

  belongs_to :invoice

  attr_accessor :raw_payment_method
  
  validates :amount, numericality: { only_integer: true, greater_than: 0 }

  validates :payment_method_id, presence: true

  # Returns a symbol of the payment method based on the payment_method_id value
  def payment_method
    METHODS[payment_method_id]
  end

  # Set the payment_method_id value from the raw_payment_method.
  def set_payment_method_id
    self.payment_method_id = METHODS.key(raw_payment_method)
  end
  
  private
  # Returns true or false based on whether the provided payment method is one of
  # our acceptable methods
  def valid_payment_method?
    METHODS.value?(raw_payment_method)
  end
end
