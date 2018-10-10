# frozen_string_literal: true

# Invoice payments
# NOTE: amount field store value in cents not in dollars.
class Payment < ApplicationRecord
  METHODS = { 1 => 'cash', 2 => 'check', 3 => 'charge' }.freeze

  # Since external methods pass in a raw_payment_method, we need to set the ID
  # value for storing in the database

  belongs_to :invoice

  # Payment record in database must not be modified. it can only be created as
  # another transaction if needed.
  # valid_payment_method? should call before set_payment_method_id
  before_validation :valid_payment_method?, :set_payment_method_id

  validates :amount, numericality: { only_integer: true, greater_than: 0 }
  validates :payment_method_id, presence: true
  attr_accessor :raw_payment_method

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
