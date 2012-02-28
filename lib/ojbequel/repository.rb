# The OJBequel::Repository class can parse an OJB repository file for the class descriptors and their child nodes, inserting everything into an in-memory SQLite database
#
# @author Sam Rawlins
class OJBequel::Repository
  include ::OJBequel::RepoDB

  # Initialize a new {OJBequel::Repository} file for one specific OJB repository file
  #
  # @param [String] file the path to an OJB repository file
  def initialize(file)
    @file = file
    @doc = Nokogiri::XML(File.open(@file))
  end

  # @return the Sequel dataset of class_descriptors for this repository file
  def class_descriptors
    Tableau.filter(:ojb_repository => @file)
  end

  def field_descriptors
    Field
  end

  # Parse the OJB repository file which, for now, consists of just parsing the class descriptors.
  # This results in the in-memory SQLite database being fully populated.
  def parse
    parse_class_descriptors
  end

  # Parse a `<class-descriptor>`, inserting a row into the Tableau table in the in-memory SQLite
  # database, and call methods to parse the class's field descriptors, reference descriptors, and
  # collection descriptors
  #
  # @param [Nokogiri::XML::Node] cd the class-descriptor node
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

  # Iterate over all of the `<class-descriptor>`'s in the OJB repository file, calling `parse_class_descriptor` on each
  def parse_class_descriptors
    @doc.xpath('//class-descriptor').each do |cd|
      parse_class_descriptor(cd)
    end
  end

  # Parse a `<collection-descriptor>`, inserting a row into the Collection table in the in-memory
  # SQLite database, and call {#parse_inverse_foreignkeys} to parse the class's inverse foreign keys
  #
  # @param [Sequel::Model] tableau the row in the in-memory `Tableau` table that this collection descriptor belongs to
  # @param [Nokogiri::XML::Node] cod the collection-descriptor node
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
    parse_orderbies(cod, collection)
  end

  # Iterate over all of the `<collection-descriptor>`'s under a given `<class-descriptor>`, calling {#parse_collection_descriptor} on each
  #
  # @param [Nokogiri::XML::Node] cd the class-descriptor node that this collection descriptor belongs to
  # @param [Sequel::Model] tableau the row in the in-memory `Tableau` table
  def parse_collection_descriptors(cd, tableau)
    cd.xpath('.//collection-descriptor').each do |cod|
      parse_collection_descriptor(tableau, cod)
    end
  end

  # Parse a `<field-descriptor>`, inserting a row into the Field table in the in-memory SQLite database
  #
  # @param [Sequel::Model] tableau the row in the in-memory `Tableau` table that this collection descriptor belongs to
  # @param [Nokogiri::XML::Node] field the field-descriptor node
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

  # Iterate over all of the `<field-descriptor>`'s under a given `<class-descriptor>`, calling {#parse_field_descriptor} on each
  #
  # @param [Nokogiri::XML::Node] cd the class-descriptor node that this field descriptor belongs to
  # @param [Sequel::Model] tableau the row in the in-memory `Tableau` table
  def parse_field_descriptors(cd, tableau)
    cd.xpath('.//field-descriptor').each do |fd|
      parse_field_descriptor(tableau, fd)
    end
  end

  # Parse a `<foreignkey>`, inserting a row into the Foreignkey table in the in-memory SQLite database
  #
  # @param [Sequel::Model] reference the row in the in-memory `Reference` table that this foreign key belongs to
  # @param [Nokogiri::XML::Node] fk the foreign key node
  def parse_foreignkey(reference, fk)
    Foreignkey.insert(:field        => fk[:'field-ref'],
                      :reference_id => reference[:id])

    remaining = fk.attributes.dup.delete_if { |k,v| Foreignkey.fields.include? k.to_sym }
    remaining.each { |k,v| puts "New field for #{fk[:'field-ref']}: #{k.inspect} = #{v}" }
  end

  # Iterate over all of the `<foreignkey>`'s under a given `<reference-descriptor>`, calling {#parse_foreignkey} on each
  #
  # @param [Nokogiri::XML::Node] rd the reference-descriptor node that this foreign key belongs to
  # @param [Sequel::Model] reference the row in the in-memory `Reference` table
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

  # Iterate over all of the `<inverse-foreignkey>`'s under a given `<collection-descriptor>`, calling {#parse_inverse_foreignkey} on each
  def parse_inverse_foreignkeys(cod, collection)
    cod.xpath('.//inverse-foreignkey').each do |ifk|
      parse_inverse_foreignkey(collection, ifk)
    end
  end

  def parse_orderby(collection, o)
    Orderby.insert(:name          => o[:'name'],
                   :sort          => o[:'sort'],
                   :collection_id => collection[:id])

    remaining = o.attributes.dup.delete_if { |k,v| Orderby.fields.include? k.to_sym }
    remaining.each { |k,v| puts "New field for #{o[:'name']}: #{k.inspect} = #{v}" }
  end

  # Iterate over all of the `<orderby>`'s under a given `<collection-descriptor>`, calling {#parse_orderby} on each
  def parse_orderbies(cod, collection)
    cod.xpath('.//orderby').each do |o|
      parse_orderby(collection, o)
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

  # Iterate over all of the `<reference-descriptor>`'s under a given `<class-descriptor>`, calling {#parse_reference_descriptor} on each
  #
  # @param [Nokogiri::XML::Node] cd the class-descriptor node that this reference descriptor belongs to
  # @param [Sequel::Model] tableau the row in the in-memory `Tableau` table
  def parse_reference_descriptors(cd, tableau)
    cd.xpath('.//reference-descriptor').each do |rd|
      parse_reference_descriptor(tableau, rd)
    end
  end
end
