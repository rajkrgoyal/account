# frozen_string_literal: true

# Invoice has many payment. One invoice can be paid in multiple small amounts.
# NOTE: invoice_total field store value in cents not in dollars.
class Invoice < ApplicationRecord
  # We expect invoices to be created in dollars as it's more comfortable for
  # humans to work with, so we need to translate the dollar amount to pennies
  # before we create the invoice
  before_save :invoice_total_to_cents

  has_many :payments, dependent: :destroy

  validates_numericality_of :invoice_total, greater_than: 0

  # Return true or false for whether the invoice has been paid
  def fully_paid?
    amount_owed.zero? || amount_owed.negative?
  end

  # Return the remaining amount owed for the invoice in dolllars and cents
  def amount_owed
    invoice_total - total_amount_paid
  end

  def total_amount_paid
    payments.sum(:amount)
  end

  # Accepts payment amounts (in dollars and cents) and payment method and
  # records that payment against the invoice
  # It should be called after paying by user, so no need to use round here.
  # It must be with 2 decimal points, so multiply by 100 is sufficient.
  def record_payment(amount, payment_method)
    payments.create(amount: amount * 100,
                    raw_payment_method: payment_method)
  end

  private

  # Presumes that invoice_total was provided in dollars and translates to cents
  # before saving
  def invoice_total_to_cents
    self.invoice_total = (invoice_total * 100).round
  end
end
