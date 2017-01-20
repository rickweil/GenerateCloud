require 'optparse'
require 'roo'
require 'active_record'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

  def importx(file, name, attr=nil)

    case File.extname(file)
      when '.csv' then spreadsheet = Roo::Csv.new(file)  #, nil, :ignore)
      when '.xls' then spreadsheet = Roo::Excel.new(file, nil, :ignore)
      when '.xlsx' then spreadsheet = Roo::Excelx.new(file) #, nil, :ignore)
      else raise "Unknown file type: #{file}"
    end

    if name != 'ApplicationRecord'
      begin
        spreadsheet.default_sheet = name
      rescue
        raise "ya, you're gonna need a spreadsheet  tab labeled '#{name}' for this to work\r\n"
      end
    end
    model = name.constantize
    header = spreadsheet.row(1)
    types = spreadsheet.row(2)

      #print "file=#{file}, model=#{model} name=#{name} header=#{header} def=#{spreadsheet.default_sheet}\n"

    # @todo WISE!! restrict accessible columns for import
    attr = attr.map { |str| str.to_s} if !attr.nil?
    (3..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      begin
        item = model.find_by_id(row['id']) || model.new
      rescue
        print "ya, you're gonna need a dB table '#{model.name.downcase.pluralize}' for this to work\r\n"
        exit
      end

      item.attributes = attr.nil? ? row : row.to_hash.slice(*attr)
      item.attributes['password'] = item.attributes['password'].to_s    if spreadsheet.default_sheet == 'User'
      item.save!
    end

    begin
      name = model.name.underscore.pluralize
      result = model.maximum(:id).next
      cmd = "ALTER SEQUENCE #{name}_id_seq RESTART WITH #{result}"
      ActiveRecord::Base.connection.execute(cmd)
      puts "#{spreadsheet.last_row-2} records imported into #{model.name}, #{name}_id_seq=#{result}"
    rescue
      puts "Warning: not procesing table #{name.name}. Id is missing?"
    end

    spreadsheet.last_row-2    # this is how many rows we imported
  end

#############  work begins here ##############
$dir = (Dir.pwd.split '/').last
$file = $dir + '.xlsx'

# models.csv can contain a list of specific models to import, else all models are imported.
begin
  text = File.read('db/migrate/models.csv')
  sheets = text.split(',').map { |model| model.gsub(/\s+/, "")}
rescue
  case File.extname($file)
    when '.csv' then spreadsheet = Roo::Csv.new($file)  #, nil, :ignore)
    when '.xls' then spreadsheet = Roo::Excel.new($file, nil, :ignore)
    when '.xlsx' then spreadsheet = Roo::Excelx.new($file) #, nil, :ignore)
    else raise "Unknown file type: #{$file}"
  end
  sheets = spreadsheet.sheets
end

sheets.each { |model|
    num = importx($file, model, $allowable)
    #print "#{num} records imported into #{model}\n"
}

