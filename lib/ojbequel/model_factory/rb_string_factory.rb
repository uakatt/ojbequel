class OJBequel::ModelFactory::RBStringFactory
  # Create a new {OJBequel::ModelFactory::RBStringFactory} for one or more OJB repository files.
  #
  # @param [OJBequel::Repository] repositories one or more repositories to use when building Strings
  def initialize(*repositories)
    @repositories = repositories
  end

  def build_all
    strings = []

    @repositories.each do |repository|
        repository.class_descriptors.each do |class_descriptor|
        strings << build(class_descriptor.rb_klazz)
      end
    end

    strings
  end

  # Build a String for `klazz_name`. This String is Ruby code that is meant to be written out to a file, or loaded into memory via `eval`. The String will contain 4 parts:
  #
  # * Two lines that require the connection file from the present working directory
  # * Two constant hashes that represent the identifier input and output mappings between Java classes/attributes and DB tables/columns
  # * Two new string methods that use the above hashes to convert a String back and forth
  # * A Ruby class that inherits Sequel::Model, for a given Java class mapped in the OJB repository file
  #
  # @param [String] klazz_name the Java class name that is mapped in the OBJ repository file
  def build(klazz_name)
    klazz_underscore  = klazz_name.underscore
    klazzes = @repositories.map { |r| r.class_descriptors.filter(:rb_klazz => klazz_name).first }.compact
    raise StandardError if klazzes.empty?
    klazz = klazzes[-1]  # keep the last one
    table = klazz.table
    if table.nil?
      raise ArgumentError  # Fix this
    end
    string = %{
$LOAD_PATH << Dir.pwd unless $LOAD_PATH.include? Dir.pwd
require 'connection'

}

    string = add_mapping_constants(klazz, klazz_name, string)
    string += string_methods(klazz_name)

    string << %{
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
    OJBequel::Utils.less Definition
  end
end
DEFN

    #string << add_definition(klazz_name, string)
    string
  end  # END build   woah that's too long

  # Add any collection definitions to the class as a call to `one_to_many`.
  # Produces something like:
  #
  #     one_to_many :useTaxItems, :class => XXXX, :key => :itemIdentifier
  def add_collections(klazz, string)
    klazz.collections.each do |c|
      orderby_str = ''
      if not c.orderbies.empty?
        orderby_str = "              :order => #{c.orderbies.map {|o| o.name.to_sym}.inspect},\n"
      end
      string << "  one_to_many #{c.name.to_sym.inspect},\n" +
        "              :class => #{c.rb_klazz.to_sym.inspect},\n" +
        orderby_str +
        "              :key => #{c.inverse_foreignkeys.map {|ifk| ifk.field.to_sym}.inspect}\n"
    end
    string
  end

  def add_definition(klazz_name, string)
    # Now we have almost everything, but maybe when someone evals this string, they'd like to keep the source handy:
    string << <<DEFN
class #{klazz_name}
  Definition = "#{string}"

  def self.definition
    OJBequel::Utils.less Definition
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

  # Add the full text of the OJB entry to the class itself, so that it can be accessble from, for example, irb.
  def add_ojb_entry(klazz, string)
    string_open_thing = "<<OHJAYBEE"
    string_close_thing = "OHJAYBEE"
    string << %{
  OJBEntry = #{string_open_thing}
#{klazz.ojb_entry.gsub('"', "\\\"")}
#{string_close_thing}

  def self.ojb_entry
    OJBequel::Utils.less OJBEntry
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

  def string_methods(klazz_name)
    klazz_underscore  = klazz_name.underscore
    klazz_underupcase = klazz_name.underscore.upcase
    return <<STRING

class ::String
  def #{klazz_underscore}_db_in
    #{klazz_underupcase}_DB_IN.fetch(self, self)
  end

  def #{klazz_underscore}_db_out
    #{klazz_underupcase}_DB_OUT.fetch(self.upcase, self)
  end
end
STRING
  end
end
