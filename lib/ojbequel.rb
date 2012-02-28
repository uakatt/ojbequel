$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

# The namespace for all classes and modules under the OJBequel library. If creating Ruby classes
# from OJBequel::RbStringFactory, the classes will exist under this namespace as well. To use
# these Ruby classes (that inherit from Sequel::Model) with a little more ease, you can
# `include ojbequel`.
module OJBequel
end

require 'highline/import'
require 'nokogiri'
require 'active_support/inflector'

require 'ojbequel/repo_db'
require 'ojbequel/repository'
require 'ojbequel/model_factory/base'
require 'ojbequel/model_factory/rb_string_factory'
require 'ojbequel/utils'
require 'ojbequel/repo_files/base'
require 'ojbequel/repo_files/file_glob'
require 'ojbequel/repo_files/spring_load'
require 'pp'
require 'kernel'
require 'array'

include OJBequel::Utils
