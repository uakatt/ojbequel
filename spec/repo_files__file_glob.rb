require_relative '../lib/ojbequel'

describe OJBequel::RepoFiles::FileGlob, ".find" do
  before :all do
    @base_dir = File.join(File.dirname(__FILE__), '..', 'examples', 'sample_project')
    @files = OJBequel::RepoFiles::FileGlob.new(@base_dir, /ojb-(.+?).xml/)
    @files.find

    @module_files = OJBequel::RepoFiles::FileGlob.new(@base_dir, /module.+ojb-(.+?).xml/)
    @module_files.find

    @unfound_files = OJBequel::RepoFiles::FileGlob.new(@base_dir, /ojb-(.+?).xml/)
  end

  it "should find the first file given a base_dir and repo_re" do
    @files.first[0].should == 'cr'
    @files.first[1].should == @base_dir + '/work/src/com/rsmart/kuali/kfs/cr/ojb-cr.xml'
  end

  it "should find the right number of files given a base_dir and repo_re" do
    @files.size.should == 18
    @module_files.size == 8
  end

  it "should find files without explicitly calling #find" do
    @unfound_files.size.should == 18
  end
end
