require_relative '../lib/ojbequel'

describe OJBequel::ModelFactory::RBStringFactory, ".build" do
  before :all do
    @repository = OJBequel::Repository.new(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'examples', 'ojb-vnd.xml'))
    @repository.parse

    @factory = OJBequel::ModelFactory::RBStringFactory.new(@repository)
  end

  before :each do
    @vendor_class01 = @repository.class_descriptors[:id => 1]
    @campus_parameter_string = @factory.build(@vendor_class01.rb_klazz)
    #puts @campus_parameter_string

    @vendor_class02 = @repository.class_descriptors.filter[:id => 2]
    @contact_type_string = @factory.build(@vendor_class02.rb_klazz)
    #puts contact_type_string

    @vendor_class03 = @repository.class_descriptors.filter[:id => 3]
    @vendor_header_string = @factory.build(@vendor_class03.rb_klazz)
    #puts vendor_header_string

    @vendor_class04 = @repository.class_descriptors[:id => 4]
    @vendor_detail_string = @factory.build(@vendor_class04.rb_klazz)
    #puts vendor_detail_string
  end

  it "should build class rows (in Tableau)" do
    @vendor_class01.rb_klazz.should == "CampusParameter"
    @vendor_class02.rb_klazz.should == "ContactType"
    @vendor_class03.rb_klazz.should == "VendorHeader"
    @vendor_class04.rb_klazz.should == "VendorDetail"
  end

  it "should build class strings with correct input/output conversion Hashes" do
    hash_expectation = <<HASH_EXPECTATION
CAMPUS_PARAMETER_DB_IN = {
  'campusCode' => 'CAMPUS_CD',
  'objectId' => 'OBJ_ID',
  'versionNumber' => 'VER_NBR',
  'campusPurchasingDirectorName' => 'CMP_PUR_DRCTR_NM',
  'campusPurchasingDirectorTitle' => 'CMP_PUR_DRCTR_TTL',
  'campusAccountsPayableEmailAddress' => 'CMP_AP_EMAIL_ADDR',
  'purchasingInstitutionName' => 'PUR_INST_NM',
  'purchasingDepartmentName' => 'PUR_DEPT_NM',
  'purchasingDepartmentLine1Address' => 'PUR_DEPT_LN1_ADDR',
  'purchasingDepartmentLine2Address' => 'PUR_DEPT_LN2_ADDR',
  'purchasingDepartmentCityName' => 'PUR_DEPT_CTY_NM',
  'purchasingDepartmentStateCode' => 'PUR_DEPT_ST_CD',
  'purchasingDepartmentZipCode' => 'PUR_DEPT_ZIP_CD',
  'purchasingDepartmentCountryCode' => 'PUR_DEPT_CNTRY_CD',
  'active' => 'ACTV_IND'
}
HASH_EXPECTATION
    @campus_parameter_string.should include(hash_expectation)
    @campus_parameter_string.should include('CAMPUS_PARAMETER_DB_OUT = CAMPUS_PARAMETER_DB_IN.invert')
  end

  it "should build class strings with correct new String methods" do
    string_expectations = <<STRING_EXPECTATION
class ::String
  def campus_parameter_db_in
    CAMPUS_PARAMETER_DB_IN.fetch(self, self)
  end

  def campus_parameter_db_out
    CAMPUS_PARAMETER_DB_OUT.fetch(self.upcase, self)
  end
end
STRING_EXPECTATION
    @campus_parameter_string.should include(string_expectations)
  end

  it "should build class strings with correct database and input/output identifiers" do
    database_expectations = <<DB_EXPECTATION
PUR_AP_CMP_PARM_T__CampusParameter = DB[:PUR_AP_CMP_PARM_T]
PUR_AP_CMP_PARM_T__CampusParameter.identifier_input_method  = :campus_parameter_db_in
PUR_AP_CMP_PARM_T__CampusParameter.identifier_output_method = :campus_parameter_db_out
DB_EXPECTATION
    @campus_parameter_string.should include(database_expectations)
  end

  it "should build class strings with correct Sequel::Model class definition" do
    @campus_parameter_string.should include('class CampusParameter < Sequel::Model')
    @contact_type_string.should include('class ContactType < Sequel::Model')
    @vendor_header_string.should include('class VendorHeader < Sequel::Model')
    @vendor_detail_string.should include('class VendorDetail < Sequel::Model')
  end

  it "should build class strings, setting the dataset correctly" do
    @campus_parameter_string.should include('set_dataset PUR_AP_CMP_PARM_T__CampusParameter')
  end

  it "should build class strings, setting the primary key correctly" do
    @campus_parameter_string.should include('set_primary_key [:campusCode]')
  end

  it "should build class strings, setting up reference tables correctly" do
    @vendor_header_string.should include('many_to_one :vendorType, :class => :VendorType, :key => [:vendorTypeCode]')
    @vendor_header_string.should include('many_to_one :vendorOwnership, :class => :OwnershipType, :key => [:vendorOwnershipCode]')
    @vendor_header_string.should include('many_to_one :vendorOwnershipCategory, :class => :OwnershipCategory, :key => [:vendorOwnershipCategoryCode]')
  end

  it "should build class strings, setting up collections correctly" do
    @vendor_header_string.should include('one_to_many :vendorSupplierDiversities,')
    @vendor_header_string.should include('            :class => :VendorSupplierDiversity,')
    @vendor_header_string.should include('            :key => [:vendorHeaderGeneratedIdentifier]')

    @vendor_header_string.should include('one_to_many :vendorTaxChanges,')
    @vendor_header_string.should include('            :class => :VendorTaxChange,')
    @vendor_header_string.should include('            :key => [:vendorHeaderGeneratedIdentifier]')
  end

  it "should build class strings, setting up collections and an orderby correctly" do
    @vendor_detail_string.should include('one_to_many :vendorAliases,')
    @vendor_detail_string.should include('            :class => :VendorAlias,')
    @vendor_detail_string.should include('            :order => [:vendorAliasName],')
    @vendor_detail_string.should include('            :key => [:vendorHeaderGeneratedIdentifier, :vendorDetailAssignedIdentifier]')
  end

  it "should build class strings, setting up collections and an orderby correctly" do
    @vendor_detail_string.should include('one_to_many :vendorCustomerNumbers,')
    @vendor_detail_string.should include('            :class => :VendorCustomerNumber,')
    @vendor_detail_string.should include('            :order => [:chartOfAccountsCode, :vendorOrganizationCode],')
    @vendor_detail_string.should include('            :key => [:vendorHeaderGeneratedIdentifier, :vendorDetailAssignedIdentifier]')
  end
end
