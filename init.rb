require 'curses'
require_relative 'src/lib/jrnl_wrapper'
require_relative 'src/tui.rb'

entry_list_data = JrnlWrapper.list_entries
interface = Tui.new(entry_list_data).build
interface.start

