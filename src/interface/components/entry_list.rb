# This class is a wrapper around curses calls to create
# the panel that will hold the list of journal entries
class EntryList
  include Curses
  attr_reader :menu


  def initialize(entries = [], nav_width = 20)
    @entries = entries
    @nav_width = nav_width
  end

  def build 
    lines = Curses.lines
    @base_window = Curses::Window.new(lines - 2, nav_width, 0, 0)
    @base_window.keypad(true)

    @base_window.box('|', '-')
    @base_window.addstr('Entries')

    @nav_window = @base_window.derwin(lines - 3, nav_width - 2, 1, 1)
    build_menu
    self
  end

  def scroll(direction)
    direction == :up ? @menu.up_item : @menu.down_item
    refresh_components
  end

  def page(direction)
    direction == :up ? @menu.scroll_up_page : @menu.scroll_down_page
    refresh_components
  end

  def activate
    base_window.attrset(Curses.color_pair(2)) if Curses.has_colors?
    base_window.box('|', '-')
    base_window.attrset(Curses.color_pair(1)) if Curses.has_colors?
    refresh_components
  end

  def deactivate
    base_window.attrset(Curses.color_pair(1)) if Curses.has_colors?
    base_window.box('|', '-')
    refresh_components
  end

  def refresh_components
    @base_window.refresh
    @nav_window.refresh
  end

  private

  attr_reader :entries, :base_window, :nav_window, :nav_width

  def build_menu
    @menu.unpost if @menu

    menu_items = entries.map { |entry| Curses::Item.new(entry[:date], entry[:title]) }
    @menu = Curses::Menu.new(menu_items)
    @menu.set_win(nav_window)
    @menu.set_format(Curses.lines - 4, 1)
    @menu.post
  end
end
