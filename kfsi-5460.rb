require_relative 'kfsequel'

def last_req_doc
  RequisitionDocument.order(:documentNumber).last
end

def req_items_for(req_doc)
  RequisitionItem.filter(:purapDocumentIdentifier => req_doc.purapDocumentIdentifier).where('ITM_LN_NBR is not null')
end

def po_for(req_doc)
  PurchaseOrderDocument.filter(:requisitionIdentifier => req_doc.purapDocumentIdentifier)
end

def po_items_for(po_doc)
  PurchaseOrderItem.where('ITM_LN_NBR is not null').filter(:documentNumber => po_doc.documentNumber)
end

def preq_for(po_doc)
  PaymentRequestDocument.filter(:purchaseOrderIdentifier => po_doc.purapDocumentIdentifier)
end

def preq_items_for(preq)
  PaymentRequestItem.filter(:purapDocumentIdentifier => preq.purapDocumentIdentifier).where('ITM_LN_NBR is not null')
end

def preq_items_use_tax_for(item)
  PaymentRequestItemUseTax.filter(:itemIdentifier => item.itemIdentifier)
end

def li_receiving_for(po_doc)
  LineItemReceivingDocument.filter(:purchaseOrderIdentifier => po_doc.purapDocumentIdentifier)
end

def li_receiving_items_for(li_rec)
  LineItemReceivingItem.filter(:documentNumber => li_rec.documentNumber)
end

$go = <<HERE
r     = last_req_doc
ri    = r.items_dataset.where("ITM_LN_NBR is not null").first
po    = po_for(r).first
poi   = po_items_for(po).first
preq  = preq_for(po).first
pitem = preq_items_for(preq).first
lir   = li_receiving_for(po).first
HERE
