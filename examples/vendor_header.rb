$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)), '..')
require 'kfs_database'

VENDOR_HEADER_DB_IN = {
  'vendorHeaderGeneratedIdentifier' => 'VNDR_HDR_GNRTD_ID',
  'objectId'                        => 'OBJ_ID',
  'versionNumber'                   => 'VER_NBR',
  'vendorTypeCode'                  => 'VNDR_TYP_CD',
  'vendorTaxNumber'                 => 'VNDR_TAX_NBR',
  'vendorTaxTypeCode'               => 'VNDR_TAX_TYP_CD',
  'vendorOwnershipCode'             => 'VNDR_OWNR_CD',
  'vendorOwnershipCategoryCode'     => 'VNDR_OWNR_CTGRY_CD'
}
VENDOR_HEADER_DB_OUT = VENDOR_HEADER_DB_IN.invert

class String
  def vendor_header_db_in
    VENDOR_HEADER_DB_IN.fetch(self, self)
  end

  def vendor_header_db_out
    VENDOR_HEADER_DB_OUT.fetch(self.upcase, self)
  end
end

PUR_VNDR_HDR_T = DB[:PUR_VNDR_HDR_T]
PUR_VNDR_HDR_T.identifier_input_method  = :vendor_header_db_in
PUR_VNDR_HDR_T.identifier_output_method = :vendor_header_db_out

class VendorHeader < Sequel::Model
  set_dataset PUR_VNDR_HDR_T
  set_primary_key :vendorHeaderGeneratedIdentifier

  one_to_one :vendorDetail, :key => :vendorHeaderGeneratedIdentifier
end

