require_relative '../lib/ojbequel'

describe OJBequel::RepoFiles::SpringLoad, ".find" do
  before :all do
    @base_dir = File.join(File.dirname(__FILE__), '..', 'examples', 'sample_project', 'work', 'src', 'configuration.properties')
    @files = OJBequel::RepoFiles::SpringLoad.new(@base_dir, /^(.+?\/.+?\/).+ojb-(.+?)\.xml/)
    @files.find
  end

  it "should find the first file given a base_dir and repo_re" do
    @files.first[0].should == 'org/kuali/sys'
    @files.first[1].should == @files.spring_base_dir + '/org/kuali/kfs/sys/ojb-sys.xml'
  end

  it "should find the right number of files given a base_dir and repo_re" do
    @files.size.should == 30
  end
end
