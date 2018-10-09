class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.references :invoice, foreign_key: true
      t.integer :payment_method_id
      t.integer :amount

      t.timestamps
    end
  end
end
