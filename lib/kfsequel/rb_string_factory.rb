class KFSequel::RBStringFactory
  def initialize(*repositories)
    @repositories = repositories
  end

  def build_all
    strings = []

    repository.class_descriptors.each do |class_descriptor|
      strings << build(class_descriptor.rb_klazz)
    end

    strings
  end

  def build(klazz_name)
    klazz_underscore  = klazz_name.underscore
    klazz_underupcase = klazz_name.underscore.upcase
    klazzes = @repositories.map { |r| r.class_descriptors.filter(:rb_klazz => klazz_name).first }.compact
    raise StandardError if klazzes.empty?
    klazz = klazzes[-1]  # keep the last one
    table = klazz.table
    if table.nil?
      raise ArgumentError  # Fix this
    end
    string = %{
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
require 'kfs_database'

}

    string = add_mapping_constants(klazz, klazz_name, string)

    string << %{
class String
  def #{klazz_underscore}_db_in
    #{klazz_underupcase}_DB_IN.fetch(self, self)
  end

  def #{klazz_underscore}_db_out
    #{klazz_underupcase}_DB_OUT.fetch(self.upcase, self)
  end
end

#{table}__#{klazz_name} = DB[:#{table}]
#{table}__#{klazz_name}.identifier_input_method  = :#{klazz_underscore}_db_in
#{table}__#{klazz_name}.identifier_output_method = :#{klazz_underscore}_db_out
}

    string << "class #{klazz_name} < Sequel::Model\n"

    string << "  set_dataset #{table}__#{klazz_name}\n\n"
    string = add_primary_keys(klazz, string)
    string = add_references(klazz, string)
    string = add_collections(klazz, string)
    string = add_ojb_entry(klazz, string)

    string << "end\n"

    string << <<DEFN
class #{klazz_name}
  Definition = "#{string}"

  def self.definition
    KFSequel::Utils.less Definition
  end
end
DEFN

    #string << add_definition(klazz_name, string)
    string
  end

  # produces something like:
  #
  #     one_to_many :useTaxItems, :key => :itemIdentifier
  def add_collections(klazz, string)
    klazz.collections.each do |c|
      string << "  one_to_many #{c.name.to_sym.inspect}, :class => #{c.rb_klazz.to_sym.inspect}, :key => #{c.inverse_foreignkeys.map {|ifk| ifk.field.to_sym}.inspect}\n"
    end
    string
  end

  def add_definition(klazz_name, string)
    # Now we have almost everything, but maybe when someone evals this string, they'd like to keep the source handy:
    string << <<DEFN
class #{klazz_name}
  Definition = "#{string}"

  def self.definition
    KFSequel::Utils.less Definition
  end
end
DEFN
    string
  end

  def add_mapping_constants(klazz, klazz_name, string)
    klazz_underupcase = klazz_name.underscore.upcase
    string << "#{klazz_underupcase}_DB_IN = {\n"
    string << klazz.fields.map { |field|
      "  '#{field.name}' => '#{field.column}'"
    }.join(",\n")
    string << "\n}\n"
    string << "#{klazz_underupcase}_DB_OUT = #{klazz_underupcase}_DB_IN.invert\n"
  end

  def add_ojb_entry(klazz, string)
    string_open_thing = "<<OHJAYBEE"
    string_close_thing = "OHJAYBEE"
    string << %{
  OJBEntry = #{string_open_thing}
#{klazz.ojb_entry.gsub('"', "\\\"")}
#{string_close_thing}

  def self.ojb_entry
    KFSequel::Utils.less OJBEntry
  end
}
  end

  # produces something like:
  #
  #     set_primary_key :vendorHeaderGeneratedIdentifier
  def add_primary_keys(klazz, string)
    string << "  set_primary_key #{klazz.fields.select {|f| f[:primarykey]}.map {|pk| pk.name.to_sym}.inspect}\n\n"
    string
  end

  # produces something like:
  #
  #     one_to_one :vendorDetail, :key => :vendorHeaderGeneratedIdentifier
  def add_references(klazz, string)
    klazz.references.each do |r|
      string << "  many_to_one #{r.name.to_sym.inspect}, :class => #{r.rb_klazz.to_sym.inspect}, :key => #{r.foreignkeys.map {|fk| fk.field.to_sym}.inspect}\n"
    end
    string << (klazz.references.empty? ? '' : "\n")
  end
end
