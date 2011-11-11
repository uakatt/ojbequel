class KFSequel::Repository
  include ::KFSequel::RepoDB
  def initialize(file)
    @file = file
    @doc = Nokogiri::XML(File.open(@file))
  end

  def class_descriptors
    Tableau.filter(:ojb_repository => @file)
  end

  def field_descriptors
    Field
  end

  def parse
    parse_class_descriptors
  end

  def parse_class_descriptor(cd)
    klazz = cd['class']
    rb_klazz = klazz.sub(/^.+\./, '')
    table = cd['table']
    ojb_entry = cd.to_xml
    tableau = Tableau.create(:klazz => klazz, :rb_klazz => rb_klazz, :table => table, :ojb_repository => @file, :ojb_entry => ojb_entry)
    puts "tableau has new id: %2s. #{tableau[:rb_klazz]}" % [tableau[:id]] if $debug
    parse_field_descriptors(cd, tableau)
    parse_reference_descriptors(cd, tableau)
    parse_collection_descriptors(cd, tableau)
  end

  def parse_class_descriptors
    @doc.xpath('//class-descriptor').each do |cd|
      parse_class_descriptor(cd)
    end
  end

  def parse_collection_descriptor(tableau, cod)
    klazz = cod[:'element-class-ref']
    rb_klazz = klazz.sub(/^.+\./, '')
    collection = Collection.create(:name => cod[:name],
                                   :element_class    => cod[:'element-class-ref'],
                                   :rb_klazz         => rb_klazz,
                                   :collection_class => cod[:'collection-class'],
                                   :auto_retrieve    => cod[:'auto-retrieve'],
                                   :auto_update      => cod[:'auto-update'],
                                   :auto_delete      => cod[:'auto-delete'],
                                   :proxy            => cod[:'proxy'],
                                   :tableau_id       => tableau[:id])
    remaining = cod.attributes.dup.delete_if { |k,v| Collection.fields.include? k.to_sym }
    remaining.each { |k,v| puts "New field for #{cod[:name]}: #{k.inspect} = #{v}" }
    parse_inverse_foreignkeys(cod, collection)
  end

  def parse_collection_descriptors(cd, tableau)
    cd.xpath('.//collection-descriptor').each do |cod|
      parse_collection_descriptor(tableau, cod)
    end
  end

  def parse_field_descriptor(tableau, fd)
    Field.insert(:name          =>  fd[:name],
                 :column        =>  fd[:column],
                 :jdbc_type     =>  fd[:'jdbc-type'],
                 :primarykey    => (fd[:primarykey]      || false),
                 :index         => (fd[:index]           || false),
                 :autoincrement => (fd[:autoincrement]   || false),
                 :sequence_name =>  fd[:'sequence-name'],
                 :locking       => (fd[:locking]         || false),
                 :conversion    =>  fd[:conversion],
                 :tableau_id    =>  tableau[:id])

    remaining = fd.attributes.dup.delete_if { |k,v| Field.fields.include? k.to_sym }
    #unless remaining.empty?
      remaining.each { |k,v| puts "New field for #{fd[:name]}: #{k.inspect} = #{v}" }
    #end
  end

  def parse_field_descriptors(cd, tableau)
    cd.xpath('.//field-descriptor').each do |fd|
      parse_field_descriptor(tableau, fd)
    end
  end

  def parse_foreignkey(reference, fk)
    Foreignkey.insert(:field        => fk[:'field-ref'],
                      :reference_id => reference[:id])

    remaining = fk.attributes.dup.delete_if { |k,v| Foreignkey.fields.include? k.to_sym }
    remaining.each { |k,v| puts "New field for #{fk[:'field-ref']}: #{k.inspect} = #{v}" }
  end

  def parse_foreignkeys(rd, reference)
    rd.xpath('.//foreignkey').each do |fk|
      parse_foreignkey(reference, fk)
    end
  end

  def parse_inverse_foreignkey(collection, ifk)
    InverseForeignkey.insert(:field         => ifk[:'field-ref'],
                             :collection_id => collection[:id])

    remaining = ifk.attributes.dup.delete_if { |k,v| InverseForeignkey.fields.include? k.to_sym }
    remaining.each { |k,v| puts "New field for #{ifk[:'field-ref']}: #{k.inspect} = #{v}" }
  end

  def parse_inverse_foreignkeys(cod, collection)
    cod.xpath('.//inverse-foreignkey').each do |ifk|
      parse_inverse_foreignkey(collection, ifk)
    end
  end

  def parse_reference_descriptor(tableau, rd)
    klazz = rd[:'class-ref']
    rb_klazz = klazz.sub(/^.+\./, '')
    reference = Reference.create(:name          => rd[:name],
                                 :klazz         => rd[:'class-ref'],
                                 :rb_klazz      => rb_klazz,
                                 :auto_retrieve => rd[:'auto-retrieve'],
                                 :auto_update   => rd[:'auto-update'],
                                 :auto_delete   => rd[:'auto-delete'],
                                 :proxy         => rd[:'proxy'],
                                 :tableau_id    => tableau[:id])
    remaining = rd.attributes.dup.delete_if { |k,v| Reference.fields.include? k.to_sym }
    remaining.each { |k,v| puts "New field for #{rd[:name]}: #{k.inspect} = #{v}" }
    parse_foreignkeys(rd, reference)
  end

  def parse_reference_descriptors(cd, tableau)
    cd.xpath('.//reference-descriptor').each do |rd|
      parse_reference_descriptor(tableau, rd)
    end
  end
end
