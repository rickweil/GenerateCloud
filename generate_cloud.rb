#!/usr/bin/env ruby
require 'optparse'
require 'roo'
require 'active_record'

$verbose = false
#$allowable = [:inventory_type, :expiration_date, :specimen_id, :mfg_info, :consumable_id, :serial_number]
$allowable = nil

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def self.import(file, attr=nil)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    types = spreadsheet.row(2)

    # @todo WISE!! restrict accessible columns for import
    attr = attr.map { |str| str.to_s} if !attr.nil?
    (3..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      begin
        item = find_by_id(row['id']) || new
      rescue
        print "ya, you're gonna need a dB table '#{self.name.downcase.pluralize}' for this to work\r\n"
        exit
      end

      item.attributes = attr.nil? ? row : row.to_hash.slice(*attr)
      print "IMPORT:\t#{row.keys.map { |key| key if !item.attributes[key].nil?}.join(' ')}\r\n" if i==2
      p item.attributes if $verbose
      item.save!
    end
    spreadsheet.last_row-1    # this is how many rows we imported
  end

  def self.migrate(config_file, attr)
    app_name = File.basename(config_file, '.xlsx').downcase
    spreadsheet = open_spreadsheet(config_file)
    header = spreadsheet.row(1)
    header.each { |name| name.gsub!(/_id$/,'') }    # change name_id to name
    types = spreadsheet.row(2)

    cmd = header.each_with_index.map { |column, ii| "#{column}:#{types[ii]}" if column!='id'}
    ["rails g scaffold #{self.name} #{cmd.join(' ')}", Hash[header.zip types]]
  end

  def self.open_spreadsheet(file)
    case File.extname(file)
      when '.csv' then spreadsheet = Roo::Csv.new(file)  #, nil, :ignore)
      when '.xls' then spreadsheet = Roo::Excel.new(file, nil, :ignore)
      when '.xlsx' then spreadsheet = Roo::Excelx.new(file) #, nil, :ignore)
      else raise "Unknown file type: #{file}"
    end

    if self.name != 'ApplicationRecord'
      begin
        spreadsheet.default_sheet = self.name
      rescue
        raise "ya, you're gonna need a spreadsheet  tab labeled '#{self.name}' for this to work\r\n"
      end
    end

    spreadsheet
  end
end


def create_app_script options
  config_file = options[:file]
  app_name = File.basename(config_file, '.xlsx').downcase
  script_name = app_name + '_create.sh'
  file = File.open("#{script_name}", 'w')
  file.puts '#!/bin/bash'
  file.puts "rm -rf #{app_name}"
  file.puts "rails new #{app_name} -d postgresql"
  file.puts "cp Gemfile #{app_name}"
  file.puts "cp #{config_file} #{app_name}"
  file.puts "cd #{app_name}"
  file.puts 'bundle'

# configure the database
  file.puts "echo configure the database"
  file.puts "sed -i 's/  adapter:/  #TODO!!! YOU NEED TO CONFIGURE THIS for EACH environment for (development, test, production) \\\n  adapter:/' config/database.yml"
  file.puts "sed -i 's/  adapter:/  username: #{options[:username]} \\\n  adapter:/' config/database.yml"
  file.puts "sed -i 's/  adapter:/  password: #{options[:password]} \\\n  adapter:/' config/database.yml"
  file.puts "sed -i 's/  adapter:/  host: \"localhost\" \\\n\\\n  adapter:/' config/database.yml"
  #file.write "sed -i 's/#host: localhost/host: \"localhost\"/' config/database.yml"
  file.puts 'rake db:drop'
  file.puts 'rake db:create'
  # file.write "sudo dropdb #{app_name}_development"
  # file.write "sudo createdb -O #{options[:username]} #{app_name}_development"    # must be root role in postgres with permissions

# now install devise
  file.puts "spring stop"    # ensure the spring server is stopped before running generator
  file.puts "rails g devise:install"
  file.puts "sed -i 's/config.action_mailer.raise_delivery_errors = false/config.action_mailer.raise_delivery_errors = true\\nconfig.action_mailer.default_url_options = { host: \"localhost\", port:3000 }\\n/' config/environments/development.rb"
  file.puts "rails generate devise User"
  file.puts "rails generate devise:views"
#
# # modify user model to add fields found in .xlsx file User tab
#   spreadsheet = ApplicationRecord.open_spreadsheet(options[:file])
#   name = 'User'
#   begin
#     spreadsheet.default_sheet = name
#     header = spreadsheet.row(1)
#     types = spreadsheet.row(2)
#     header.each_with_index { |name, ii |

#   YOU WILL NEED TO ADD INTO application_controller.rb the permitted User parameters
#   and edit views/devise/sign_up to add in the required new User fields

#     }
#   rescue
#     raise "ya, you're gonna need a spreadsheet tab labeled '#{name}' to modify User and authorizations\r\n"
#   end


# add cancancan abilities
  file.puts "rails g cancan:ability"

# create welcome page and route, and set root url to point there
  file.puts "\necho create welcome page and route, and set root url to point there"
  file.puts "rails generate controller Welcome index"
  file.puts  "sed -i 's/get /root :to => \"welcome#index\"\\n  get /' config/routes.rb"

# add web administration
  file.puts 'rails g rails_admin:install'

  file.puts "cp -r ../assets/* ."

  file.close
  File.chmod(0755, script_name)
  script_name
end

# now the post processing script
def post_process_script options
  config_file = options[:file]
  app_name = File.basename(config_file, '.xlsx').downcase
  script_name = app_name + '_post.sh'
  file = File.open("#{script_name}", "w")
  file.puts "#!/bin/bash"

#  file.puts "cp -r assets2/* #{app_name}"
  file.puts "cd #{app_name}"
  file.puts "rake db:migrate"

# augment Abililties
  spreadsheet = Roo::Excelx.new(config_file)
  spreadsheet.default_sheet = 'ability'
  header = spreadsheet.row(1)

  file2 = File.open("#{app_name}/app/models/ability.rb",'w')
  file2.puts "class Ability"
  file2.puts "# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities"
  file2.puts "  include CanCan::Ability\n"
  file2.puts "  def initialize(user)\n"
  file2.puts "  ############# @todo NO_AUTHORZATION"
  file2.puts "  if !$AUTHENTICATOR"
  file2.puts "    can [:manage], [:all]"
  file2.puts "    return"
  file2.puts "  end\n"

  attr = attr.map { |str| str.to_s} if !attr.nil?
  (2..spreadsheet.last_row).each do |i|
    h = header.zip spreadsheet.row i
    h = h.to_h
    roles = h['Role'].split(',').map { |role| "user.#{role}? " }
    abilities = h['Ability'].split(',').map { |ability| ability.strip.to_sym }
    resources = h['Resource'].split(',').map { |resource| resource.strip }
    conditions = []
    conditions = h['Condition'].split(',').map { |condition| condition.strip } if h['Condition']
    file2.puts "    if #{roles.join ' || '}"

    # create abilities
    str = "      can #{abilities}, [#{resources.join ', '}]"

    # add conditions if any
    str += ', ' if conditions.length > 0
    conditions.each_with_index { |condition, ii|
      str += ', ' if ii > 0
      if condition == 'user_id'
        str += ":#{condition} => user.id"
      elsif condition == "#{resources[0].underscore.downcase}_id"
        str += ":id => user.#{condition}"
      else
        str += ":#{condition} => user.#{condition}"
      end
    }
    file2.puts str

    file2.puts "    end"
  end
  file2.puts "  end\nend\n"
  file2.close
  file.puts "cat #{app_name}/app/models/ability.rb"
  file.close
  File.chmod(0755, script_name)
  script_name
end

# now the migration script
def create_model_script options
  config_file = options[:file]
  app_name = File.basename(config_file, '.xlsx').downcase
  script_name = app_name + '_migration.sh'
  file = File.open("#{script_name}", "w")
  file.puts "#!/bin/bash"
  file.puts "cd #{app_name}"

  if options[:create_model] != 'all'
    sheets = [options[:create_model]]
  else
    sheets = ApplicationRecord.open_spreadsheet(options[:file]).sheets
  end

  sheets.each { |model|
    ## create the model
    if model == 'User'    # user is created with devise


      # modify user model to add fields found in .xlsx file User tab
      begin
        spreadsheet = ApplicationRecord.open_spreadsheet(options[:file])
        spreadsheet.default_sheet = model
        header = spreadsheet.row(1)
        header.each { |model| model.gsub!(/_id$/,'') }    # change name_id to name
        types = spreadsheet.row(2)
        header.each_with_index { |model, ii |
          refname = model.gsub(/_id/, "")
          file.puts "rails generate migration add_#{model.underscore.pluralize}_to_users #{refname}:#{types[ii]}" if model!='id' && model!='email'
        }
      rescue
        raise "ya, you're gonna need a spreadsheet tab labeled '#{name}' to modify User and authorizations\r\n"
      end

    elsif model[0] == model[0].upcase   # Models MUST begin with upper case
      # create dynamic function to import a model
      foo = Object.const_set(model, Class.new(ApplicationRecord) {
        def self.import_file(file)
          open_spreadsheet file
          import(file, $allowable)
        end
        def self.create_model(file)
          open_spreadsheet file
          migrate(file, $allowable)
        end
      })
      begin
        cmd, types = foo.create_model options[:file]
        file.puts cmd
        file.puts "sed -i 's/def index/load_and_authorize_resource\\n  def index/'   app/controllers/#{model.underscore.pluralize}_controller.rb"
        file.puts "sed -i 's/.all/.where get_query_hash/'   app/controllers/#{model.underscore.pluralize}_controller.rb"
        file.puts "sed -i 's/@#{model.underscore} = /# @#{model.underscore} = /'   app/controllers/#{model.underscore.pluralize}_controller.rb"
        file.puts "sed -i 's/@#{model.underscore.pluralize} = /# @#{model.underscore.pluralize} = /'   app/controllers/#{model.underscore.pluralize}_controller.rb"


      rescue
        print "==> Problem creating #{model}, it already exists??\n"
      end

      ## import data into the model
      begin
        types.each { |k,v|
          if v=='references'
            item = "#{model.underscore}.#{k}"
            if k=='user'
              s="sed -i 's/#{item}/#{item}.email /'   app/views/#{model.underscore.pluralize}/index.html.erb"
            elsif model[0] == model[0].upcase
              path = "\"\\\/#{k.underscore.pluralize}\\\/\#{#{model.underscore}.#{k}_id}\""
              s="sed -i 's/#{item}/link_to #{item}_id, #{path} /'   app/views/#{model.underscore.pluralize}/index.html.erb"
            end
            file.puts s
          end
        }
      rescue
        print "==> Problem populating #{model}\n"
      end
    end
  }
  file.puts "rake db:migrate"
  file.puts "cp -r ../assets2/* ."
  file.puts "rake db:seed"

  file.close
  File.chmod(0755, script_name)
  script_name
end

############   WORK BEGINS HERE ##################

# set up initial configuration parameters
options = {
    # database configuration
    adapter:  'postgresql', # or 'mysql' or 'sqlite3' or 'oracle_enhanced'
    host:     'localhost',
    database: 'development',
    username: 'blog_role',
    password: 'blog_role',
    #app_admin_name: 'rick.weil@sparton.com',
    #app_admin_password: '12341234',

    # import stuff
    model:  'all',            # work with all data models in the spreadsheet
    file: nil,                # you have to specify this
    import_data: true,        # import data for specified models
    create_model: false,  # create and run migrations for specified models
    execute:  false,          # After creating a script, execute it.
}

# parse command line optionsF
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]  FILE.xlsx"

  opts.on("-c", "--create", "Create an app from scratch") do |v|
    options[:create_app] = v
  end

  opts.on("-p", "--postprocess", "Post processing of generated script (after it is run") do |v|
    options[:post_process] = v
  end

  opts.on("-mNAME", "--model=NAME", "Must specify model name") do |m|
    options[:create_model] = m
  end

  opts.on("-i", "--import", "Import data") do |v|
    options[:import_data] = v
  end

  opts.on("-x", "--execute", "After creating a script, execute it") do |v|
    options[:execute] = v
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
    $verbose = v
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!
options[:file] = ARGV.pop if options[:file].nil?


options[:app_name] = File.basename(options[:file], '.xlsx').downcase
options[:database] = "#{options[:app_name]}_#{options[:database]}"

print "OPTION:\t#{options}\r\n" if $verbose
print "ARGV:\t#{ARGV}\r\n"      if $verbose
# raise "Configuration file.xlsx must be specified.  See --help option." if options[:file].nil?

# OK, start doing some work.
if options[:create_app]
  # we are creating an app...
  script_name = create_app_script(options)

  if options[:execute]
    print %x[ sh ./#{script_name} ]
  else
    print "You must now run #{script_name}\n"
    exit
  end
end

if options[:post_process]
  script_name = post_process_script(options)
  if options[:execute]
    print %x[ sh ./#{script_name} ]
  else
    print "You must now run #{script_name}\n"
    exit
  end
end

# establish connection to database (these can be moved easily to command line params)
ActiveRecord::Base.establish_connection(
    adapter:  options[:adapter],
    host:     options[:host],
    database: options[:database],
    username: options[:username],
    password: options[:password]
)

if options[:create_model]
  script_name = create_model_script(options)
  if options[:execute]
    print %x[ sh ./#{script_name} ]
  else
    print "You must now run #{script_name}\n"
    exit
  end
end
