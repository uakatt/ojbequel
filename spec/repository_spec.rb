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

    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.should_not == nil
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.size.should == 14
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.first[:name].should == 'vendorHeaderGeneratedIdentifier'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.first[:column].should == 'VNDR_HDR_GNRTD_ID'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.first[:jdbc_type].should == 'INTEGER'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.first[:primarykey].should == true
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.first[:index].should == true
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.first[:autoincrement].should == true
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.fields.first[:sequence_name].should == 'VNDR_HDR_GNRTD_ID'

    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.references.first[:name].should == 'vendorType'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.references.first[:klazz].should == 'org.kuali.kfs.vnd.businessobject.VendorType'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.references.first[:auto_retrieve].should == true
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.references.first[:auto_update].should == 'none'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.references.first[:auto_delete].should == 'none'
    repository.class_descriptors.filter(:rb_klazz => 'VendorHeader').first.references.first[:proxy].should == true
  end
end
