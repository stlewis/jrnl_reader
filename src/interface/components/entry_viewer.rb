class EntryViewer
  include Curses

  attr_reader :entry_content 


  def initialize(reader_width, nav_width)
    @reader_width = reader_width
    @nav_width = nav_width
  end

  def build 
    lines = Curses.lines
    cols = Curses.cols
    @base_window = Curses::Window.new(lines - 2, reader_width, 0, nav_width + 2)
    @base_window.keypad(true)

    @base_window.box('|', '-')

    content_height = @base_window.maxy - 3
    content_width = @base_window.maxx - 2

    @content_window = @base_window.derwin(content_height, content_width, 1, 2)
    @content_window.keypad(true)

    self
  end

  def scroll(direction)
    content_window.clear 

    if direction == :up
      @top_line -= 1  unless @top_line == 0
    else
      @top_line += 1  unless @top_line == entry_content.lines.count - 1
    end

    content_window.addstr(entry_content.lines[@top_line..-1].join)
    refresh_components
  end

  def page(direction)
    page_lines = content_window.maxy - 3
    @top_line = direction == :up ? @top_line - page_lines : @top_line + page_lines

    @top_line = 0 if @top_line < 0
    @top_line = entry_content.lines.count - 1 if @top_line > entry_content.lines.count - 1

    content_window.clear 
    content_window.addstr(entry_content.lines[@top_line..-1].join)
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

  def show_entry(entry)
    content_window.clear
    @top_line = 0
    @entry_content = JrnlWrapper.entry_content(entry.name)
    content_window.addstr(@entry_content)
    refresh_components

    @entry_content
  end

  def refresh_components
    base_window.refresh
    content_window.refresh
  end

  private

  attr_reader :base_window, :content_window, :nav_width, :reader_width
end
