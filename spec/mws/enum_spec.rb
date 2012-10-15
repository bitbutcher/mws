require 'spec_helper'

module Mws

  describe 'Enum' do
    
    it 'should map from symbols to string values' do
      OrderStatus = Enum.for_hash(
        pending: 'Pending',
        unshipped: [ 'Unshipped', 'PartiallyShipped' ],
        shipped: 'Shipped',
        invoice_unconfirmed: 'InvoiceUnconfirmed',
        cancelled: 'Cancelled',
        unfulfillable: 'Unfulfillable'
      )
      OrderStatus.entry_for(:pending).should == OrderStatus.PENDING
      OrderStatus.entry_for('Pending').should == OrderStatus.PENDING
      OrderStatus.PENDING.sym.should == :pending
      OrderStatus.PENDING.val.should == 'Pending'
      OrderStatus.entry_for(:unshipped).should == OrderStatus.UNSHIPPED
      OrderStatus.entry_for('Unshipped').should == OrderStatus.UNSHIPPED
      OrderStatus.entry_for('PartiallyShipped').should == OrderStatus.UNSHIPPED
    end

  end

end