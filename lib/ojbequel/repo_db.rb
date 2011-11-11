require 'sequel'

module OJBequel::RepoDB
  DB = Sequel.sqlite  # memory database

  DB.create_table :tableaus do
    primary_key :id
    String :table
    String :klazz
    String :rb_klazz
    String :ojb_repository
    String :ojb_entry
  end

  class Tableau < Sequel::Model
    one_to_many :fields
    one_to_many :references
    one_to_many :collections
  end

  DB.create_table :fields do
    primary_key :id
    String  :name
    String  :column
    String  :jdbc_type
    Boolean :primarykey
    Boolean :index
    Boolean :autoincrement
    String  :sequence_name
    Boolean :locking
    String  :conversion
    Integer :tableau_id
  end

  class Field < Sequel::Model
    many_to_one :table

    @@fields = [:name, :column, :'jdbc-type', :primarykey, :index, :autoincrement, :'sequence-name', :locking, :conversion]
    def self.fields; @@fields; end
  end

  DB.create_table :references do
    primary_key :id
    String  :name
    String  :klazz
    String  :rb_klazz
    Boolean :auto_retrieve
    String  :auto_update
    String  :auto_delete
    Boolean :proxy
    Integer :tableau_id
  end

  class Reference < Sequel::Model
    many_to_one :table
    one_to_many :foreignkeys

    @@fields = [:name, :'class-ref', :'auto-retrieve', :'auto-update', :'auto-delete', :proxy]
    def self.fields; @@fields; end
  end

  DB.create_table :foreignkeys do
    primary_key :id
    String  :field
    Integer :reference_id
  end

  class Foreignkey < Sequel::Model
    many_to_one :reference

    @@fields = [:'field-ref']
    def self.fields; @@fields; end
  end

  DB.create_table :collections do
    primary_key :id
    String :name
    Boolean :proxy
    String :element_class
    String :rb_klazz
    String :collection_class
    Boolean :auto_retrieve
    Boolean :auto_update
    Boolean :auto_delete
    Integer :tableau_id
  end

  class Collection < Sequel::Model
    many_to_one :table
    one_to_many :inverse_foreignkeys

    @@fields = [:name, :proxy, :'element-class-ref', :'collection-class', :'auto-retrieve', :'auto-update', :'auto-delete']
    def self.fields; @@fields; end
  end

  DB.create_table :inverse_foreignkeys do
    primary_key :id
    String :field
    Integer :collection_id
  end

  class InverseForeignkey < Sequel::Model
    many_to_one :collection

    @@fields = [:'field-ref']
    def self.fields; @@fields; end
  end

  DB.create_table :orderbys do
    primary_key :id
    String :name
    String :sort
    Integer :collection_id
  end

  class Orderby < Sequel::Model
    many_to_one :collection
  end
end
