class Array

  protected

    def columnized_row(fields, sized)
      r = []
      fields.each_with_index do |f, i|
        r << sprintf("%0-#{sized[i]}s", f.to_s.gsub(/\n|\r/, '').slice(0, sized[i]))
      end
      r.join(' | ')
    end

  public

  def columnized(options = {})
    sized = {}
    self.each do |row|
      row.values.values.each_with_index do |value, i|
        sized[i] = [sized[i].to_i, row.values.keys[i].length, value.to_s.length].max
        sized[i] = [options[:max_width], sized[i].to_i].min if options[:max_width]
      end
    end

    table = []
    table << header = columnized_row(self.first.values.keys, sized)
    table << header.gsub(/./, '-')
    self.each { |row| table << columnized_row(row.values.values, sized) }
    table.join("\n")
  end
end
