$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)), '..')
require 'kfs_database'

VENDOR_DETAIL_DB_IN = {
  'vendorHeaderGeneratedIdentifier' => 'VNDR_HDR_GNRTD_ID',
  'vendorDetailAssignedIdentifier'  => 'VNDR_DTL_ASND_ID',
  'objectId'                        => 'OBJ_ID',
  'versionNumber'                   => 'VER_NBR',
  'vendorParentIndicator'           => 'VNDR_PARENT_IND',
  'vendorName'                      => 'VNDR_NM',
  'activeIndicator'                 => 'DOBJ_MAINT_CD_ACTV_IND',
  'vendorInactiveReasonCode'        => 'VNDR_INACTV_REAS_CD',
  'vendorDunsNumber'                => 'VNDR_DUNS_NBR',
  'vendorPaymentTermsCode'          => 'VNDR_PMT_TERM_CD'
}
VENDOR_DETAIL_DB_OUT = VENDOR_DETAIL_DB_IN.invert

class String
  def vendor_detail_db_in
    VENDOR_DETAIL_DB_IN.fetch(self, self)
  end

  def vendor_detail_db_out
    VENDOR_DETAIL_DB_OUT.fetch(self.upcase, self)
  end
end

PUR_VNDR_DTL_T = DB[:PUR_VNDR_DTL_T]
PUR_VNDR_DTL_T.identifier_input_method  = :vendor_detail_db_in
PUR_VNDR_DTL_T.identifier_output_method = :vendor_detail_db_out

class VendorDetail < Sequel::Model
  set_dataset PUR_VNDR_DTL_T
  set_primary_key [:vendorHeaderGeneratedIdentifier, :vendorDetailAssignedIdentifier]

  many_to_one :vendorHeader, :key => :vendorHeaderGeneratedIdentifier
end

