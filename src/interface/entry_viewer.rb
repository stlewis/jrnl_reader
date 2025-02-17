class EntryViewer
  include Curses

  attr_reader :base_window, :content_window

  def initialize(nav_width)
    @nav_width = nav_width
  end

  def interface
    lines = Curses.lines
    cols = Curses.cols
    @base_window = Curses::Window.new(lines - 2, cols - (@nav_width + 2), 0, @nav_width + 2)
    @base_window.keypad(true)

    @base_window.box('|', '-')

    content_height = @base_window.maxy - 3
    content_width = @base_window.maxx - 2

    @content_window = @base_window.derwin(content_height, content_width, 1, 2)
    @content_window.keypad(true)

    self
  end

  def show_entry(entry)
    entry_content = JrnlWrapper.entry_content(entry.name)
    content_window.addstr(entry_content)

    entry_content
  end
end
