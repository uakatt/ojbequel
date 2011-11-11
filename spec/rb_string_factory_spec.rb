require_relative '../lib/kfsequel'

describe KFSequel::RBStringFactory, ".build" do
  it "should build class files" do
    repository = KFSequel::Repository.new(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'ojb-vnd.xml'))
    repository.parse

    factory = KFSequel::RBStringFactory.new(repository)

    vendor_class01 = repository.class_descriptors[:id => 1]
    vendor_class01.rb_klazz.should == "CampusParameter"
    campus_parameter_string = factory.build(vendor_class01.rb_klazz)
    puts campus_parameter_string

    vendor_class02 = repository.class_descriptors.filter[:id => 2]
    vendor_class02.rb_klazz.should == "ContactType"
    contact_type_string = factory.build(vendor_class02.rb_klazz)
    puts contact_type_string

    vendor_class03 = repository.class_descriptors.filter[:id => 3]
    vendor_class03.rb_klazz.should == "VendorHeader"
    vendor_header_string = factory.build(vendor_class03.rb_klazz)
    puts vendor_header_string

    vendor_class04 = repository.class_descriptors[:id => 4]
    vendor_class04.rb_klazz.should == "VendorDetail"
    vendor_detail_string = factory.build(vendor_class04.rb_klazz)
    puts vendor_detail_string
  end
end
