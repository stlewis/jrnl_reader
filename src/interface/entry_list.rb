# This class is a wrapper around curses calls to create
# the panel that will hold the list of journal entries
class EntryList
  include Curses

  attr_reader :entries, :base_window, :nav_window, :menu

  def initialize(entries = [], nav_width = 20)
    @entries = entries
    @nav_width = nav_width
  end

  def interface
    lines = Curses.lines
    @base_window = Curses::Window.new(lines - 2, nav_width, 0, 0)
    @base_window.keypad(true)

    @base_window.box('|', '-')
    @base_window.addstr('Entries')

    @nav_window = @base_window.derwin(lines - 3, nav_width - 2, 1, 1)
    build_menu
    self
  end

  private

  attr_reader :nav_width

  def build_menu
    @menu.unpost if @menu

    menu_items = entries.map { |entry| Curses::Item.new(entry[:date], entry[:title]) }
    @menu = Curses::Menu.new(menu_items)
    @menu.set_win(nav_window)
    @menu.post
  end
end
