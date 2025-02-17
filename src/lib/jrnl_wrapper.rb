require 'colorized_string'

class JrnlWrapper
  class << self
    def list_entries
      entries = []
      r = IO.popen('jrnl --short --format short', 'r+')
      raw_output = r.read
      decolorized = raw_output.gsub(/\e\[\d+m/, '')

      entry_strings = decolorized.split("\n")

      entry_strings.each do |entry|
        _, date, time, title = entry.match(/(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}) (.*)/).to_a

        entries << {
          date: "#{date} #{time}",
          title: title
        }
      end

      entries
    end

    def entry_content(title)
      formatted_date = title.split(' ').join('T')
      r = IO.popen("jrnl --format fancy -on #{formatted_date} --config-override colors.title none --config-override colors.date none", 'r+')
      raw_content = r.read

      ColorizedString.new(raw_content)
    end
  end
end
