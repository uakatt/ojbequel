require_relative '../lib/ojbequel'

describe OJBequel::Repository, ".parse" do
  it "should find class-descriptors" do
    repository = OJBequel::Repository.new(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'examples', 'ojb-vnd.xml'))
    repository.parse
    repository.class_descriptors.should_not == nil
    repository.class_descriptors.any? {|cd| cd[:rb_klazz] == 'VendorHeader' }.should ==  true
    repository.class_descriptors.any? {|cd| cd[:rb_klazz] == 'CommodityContractManager' }.should == true

    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first[:klazz].should == 'org.kuali.kfs.vnd.businessobject.VendorHeader'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first[:rb_klazz].should == 'VendorHeader'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first[:table].should == 'PUR_VNDR_HDR_T'
  end

  context "with good VendorHeader and VendorDetail class-descriptors" do
    before :all do
      @repository = OJBequel::Repository.new(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'examples', 'ojb-vnd.xml'))
      @repository.parse

      @vendor_header = @repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first
      @vendor_detail = @repository.class_descriptors.filter(:rb_klazz => 'VendorDetail').first
      @vendor_aliases = @vendor_detail.collections.first
    end

    it "should find all of the class-descriptor's fields" do
      @vendor_header.fields.should_not == nil
      @vendor_header.fields.size.should == 14
    end

    it "should correctly parse a class-descriptor's first field" do
      @vendor_header.fields.first[:name].should == 'vendorHeaderGeneratedIdentifier'
      @vendor_header.fields.first[:column].should == 'VNDR_HDR_GNRTD_ID'
      @vendor_header.fields.first[:jdbc_type].should == 'INTEGER'
      @vendor_header.fields.first[:primarykey].should == true
      @vendor_header.fields.first[:index].should == true
      @vendor_header.fields.first[:autoincrement].should == true
      @vendor_header.fields.first[:sequence_name].should == 'VNDR_HDR_GNRTD_ID'
    end

    it "should find a class-descriptor's first reference" do
      @vendor_header.references.first[:name].should == 'vendorType'
      @vendor_header.references.first[:klazz].should == 'org.kuali.kfs.vnd.businessobject.VendorType'
      @vendor_header.references.first[:auto_retrieve].should == true
      @vendor_header.references.first[:auto_update].should == 'none'
      @vendor_header.references.first[:auto_delete].should == 'none'
      @vendor_header.references.first[:proxy].should == true
    end

    it "should find a class-descriptor's collections" do
      @vendor_header.collections.should_not == nil
      @vendor_header.collections.size.should == 2

      @vendor_detail.collections.should_not == nil
      @vendor_detail.collections.size.should == 8
    end

    it "should parse a class-descriptor's first collection" do
      @vendor_header.collections.first[:name].should == 'vendorSupplierDiversities'
      @vendor_header.collections.first[:proxy].should == true
      @vendor_header.collections.first[:'element_class'].should == 'org.kuali.kfs.vnd.businessobject.VendorSupplierDiversity'
      @vendor_header.collections.first[:'collection_class'].should == 'org.apache.ojb.broker.util.collections.ManageableArrayList'
      @vendor_header.collections.first[:'auto_retrieve'].should == true
      @vendor_header.collections.first[:'auto_update'].should == 'object'
      @vendor_header.collections.first[:'auto_delete'].should == 'none'
    end

    it "should parse a class-descriptor's second collection" do
      @vendor_header.collections[1][:name].should == 'vendorTaxChanges'
      @vendor_header.collections[1][:proxy].should == true
      @vendor_header.collections[1][:'element_class'].should == 'org.kuali.kfs.vnd.businessobject.VendorTaxChange'
      @vendor_header.collections[1][:'auto_retrieve'].should == false
      @vendor_header.collections[1][:'auto_update'].should == 'none'
      @vendor_header.collections[1][:'auto_delete'].should == 'none'
    end

    it "should find a class-descriptor's second collection's inverse foreignkeys" do
      @vendor_aliases[:name].should == 'vendorAliases'
      @vendor_aliases.inverse_foreignkeys.should_not == nil
    end

    it "should parse a class-descriptor's second collection's inverse foreignkeys" do
      @vendor_aliases.inverse_foreignkeys[0].field.should == 'vendorHeaderGeneratedIdentifier'
      @vendor_aliases.inverse_foreignkeys[1].field.should == 'vendorDetailAssignedIdentifier'
    end

    it "should find a class-descriptor's second collection's orderbies" do
      @vendor_aliases.orderbies.should_not == nil
      @vendor_aliases.orderbies.size.should == 1
    end

    it "should parse a class-descriptor's second collection's orderbies" do
      @vendor_aliases.orderbies.first.name.should == 'vendorAliasName'
      @vendor_aliases.orderbies.first.sort.should == 'ASC'
    end
  end
end
