require_relative 'lib/ojbequel'

ORG_KUALI_OJB_PATH = '/java/projects/kfs/work/src/org/kuali/kfs/'
ORG_KUALI_OJB_FILES = {
  'pdp'   => 'pdp/ojb-pdp.xml',
  'gl'    => 'gl/ojb-gl.xml',
  'vnd'   => 'vnd/ojb-vnd.xml',
  'sys'   => 'sys/ojb-sys.xml',
  'fp'    => 'fp/ojb-fp.xml',
  'ar'    => 'module/ar/ojb-ar.xml',
  'bc'    => 'module/bc/ojb-bc.xml',
  'ec'    => 'module/ec/ojb-ec.xml',
  'ld'    => 'module/ld/ojb-ld.xml',
  'purap' => 'module/purap/ojb-purap.xml',
  'cam'   => 'module/cam/ojb-cam.xml',
  'cg'    => 'module/cg/ojb-cg.xml',
  'cab'   => 'module/cab/ojb-cab.xml',
  'coa'   => 'coa/ojb-coa.xml'
}

COM_RSMART_OJB_PATH = '/java/projects/kfs/work/src/com/rsmart/kuali/kfs/'
COM_RSMART_OJB_FILES = [
  'prje/ojb-prje.xml',
  'cr/ojb-cr.xml',
  'fp/ojb-fp.xml',
  'tax/ojb-tax.xml',
  'module/purap/ojb-purap.xml'
]

EDU_ARIZONA_OJB_PATH = '/java/projects/kfs/work/src/edu/arizona/'
EDU_ARIZONA_OJB_FILES = [
  'kfs/prje/obj-prje.xml',
  'kfs/pdp/ojb-pdp.xml',
  'kfs/gl/ojb-gl.xml',
  'kfs/vnd/ojb-vnd.xml',
  'kfs/sys/ojb-sys.xml',
  'kfs/fp/ojb-fp.xml',
  'kfs/module/ld/ojb-ld.xml',
  'kfs/module/purap/ojb-purap.xml',
  'kfs/module/cam/ojb-cam.xml',
  'kfs/module/cg/ojb-cg.xml',
  'kfs/coa/ojb-coa.xml',
  'kim/ojb-kim.xml'
]

Repositories = {}
Factories = {}

ORG_KUALI_OJB_FILES.each do |name, file|
  puts "Creating #{name} repository (#{file})..."
  repository = OJBequel::Repository.new(File.join(File.expand_path(ORG_KUALI_OJB_PATH), file))
  repository.parse
  Factories[name] = OJBequel::RBStringFactory.new(repository)
  #puts repository.class_descriptors.map {|cd| cd.rb_klazz}.join(", ")
  repository.class_descriptors.each do |cd|
    begin
      puts "  Building #{cd.rb_klazz}..."
      string = Factories[name].build(cd.rb_klazz)
      eval string
      # EXPERIMENTAL
#      if string =~ /^class (\w+) < Sequel::Model/
#        cc = $1
#        eval <<-HERE
#class #{cc}
#  Definition = "#{string}"
#end
#        HERE
#      end
    rescue ArgumentError => error
      puts "  #{cd.rb_klazz} is no good!"
    rescue Sequel::Error => error
      puts "ERROR: #{cd.rb_klazz} is no good: #{error}"
      puts "ERROR: #{cd.rb_klazz} will not accessible."
    rescue StandardError => error
      puts "  Died on: #{string}"
      raise error
    rescue SyntaxError => error
      puts "  Died on: #{string}"
      raise error
    end
  end
  Repositories[name] = repository
end


