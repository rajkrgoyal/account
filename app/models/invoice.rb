# frozen_string_literal: true

# Invoice has many payment. One invoice can be paid in multiple small amounts.
# NOTE: invoice_total field store value in cents not in dollars.
class Invoice < ApplicationRecord
  # We expect invoices to be created in dollars as it's more comfortable for
  # humans to work with, so we need to translate the dollar amount to pennies
  # before we create the invoice
  before_save :translate_invoice_total_to_cents

  has_many :payments, dependent: :destroy

  validates_numericality_of :invoice_total, greater_than: 0

  # Return true or false for whether the invoice has been paid
  def fully_paid?
    amount_owed <= 0
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
  #def record_payment(amount_owed, payment_method)
  #  payments.create({amount: (amount_owed * 100).to_i, raw_payment_method: payment_method})
  #end

  # Accepts payment amounts (in dollars and cents) and payment method and
  # records that payment against the invoice
  def record_payment(amount_paid, payment_method)
    payments.create(amount: dollars_to_cents(amount_paid),
                    raw_payment_method: payment_method)
  end

  private

  # Presumes that invoice_total was provided in dollars and translates to cents
  # before saving
  def translate_invoice_total_to_cents
    self.invoice_total = dollars_to_cents(invoice_total)
  end
end
