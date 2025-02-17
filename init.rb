require 'curses'
require_relative 'src/lib/jrnl_wrapper'
require_relative 'src/interface/entry_list'
require_relative 'src/interface/entry_viewer'

entry_list_data = JrnlWrapper.list_entries

Curses.init_screen
Curses.noecho
Curses.curs_set(0)
Curses.cbreak
Curses.stdscr.keypad(true)

if Curses.has_colors?
  Curses.start_color
  Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
  Curses.init_pair(2, Curses::COLOR_RED, Curses::COLOR_BLACK)
end

def nav_width(entries)
  return 20 if entries.empty?

  max = entries.map { |entry| entry[:date].length + entry[:title].length }.max

  max + 5
end

def draw_menu
  Curses.setpos(Curses.lines - 2, 0)
  Curses.addstr("\u2191,\u2193, j,k to scroll | \u2190,\u2192, h,l to switch panels | Enter to read | q to quit")
end

entry_list = EntryList.new(entry_list_data, nav_width(entry_list_data)).interface
entry_viewer = EntryViewer.new(nav_width(entry_list_data)).interface

@list_base_window = entry_list.base_window
@list_nav_window = entry_list.nav_window

@entry_base_window = entry_viewer.base_window
@entry_content_window = entry_viewer.content_window

def activate_window(window)
  other_window = window == @entry_base_window ? @list_base_window : @entry_base_window

  window.attrset(Curses.color_pair(2)) if Curses.has_colors?
  window.box('|', '-')
  window.attrset(Curses.color_pair(1)) if Curses.has_colors?

  other_window.attrset(Curses.color_pair(1)) if Curses.has_colors?
  other_window.box('|', '-')

  window.refresh
  other_window.refresh
end

begin

  Curses.refresh

  entry_text = nil
  top_line = 0
  mode = 'nav'

  activate_window(@list_base_window)

  draw_menu()

  @list_base_window.refresh
  @list_nav_window.refresh
  @entry_base_window.refresh
  @entry_content_window.refresh

  while (ch = Curses.getch) && ch != 'q'
    begin
      case ch
      when Curses::KEY_LEFT, 'h'
        mode = 'nav'
        activate_window(@list_base_window)
      when Curses::KEY_RIGHT, 'l'
        unless entry_text.nil?
          mode = 'reader' 
          activate_window(@entry_base_window)
        end
      when Curses::KEY_DOWN, 'j'
        if mode == 'nav'
          entry_list.menu.down_item
          @list_base_window.refresh
          @list_nav_window.refresh
        else
          @entry_content_window.clear 
          top_line += 1 unless top_line == entry_text.lines.count - 1
          @entry_content_window.addstr(entry_text.lines[top_line..-1].join)
          @entry_content_window.refresh
        end
      when Curses::KEY_UP, 'k'
        if mode == 'nav'
          entry_list.menu.up_item
          @list_base_window.refresh
          @list_nav_window.refresh
        else
          @entry_content_window.clear 
          top_line -= 1 
          unless top_line == 0
            @entry_content_window.addstr(entry_text.lines[top_line..-1].join)
            @entry_base_window.refresh
            @entry_content_window.refresh
          end
        end
      when 'u'
        if mode == 'nav'
          entry_list.menu.scroll_up_page
          @list_base_window.refresh
          @list_nav_window.refresh
        else
          page_lines = @entry_content_window.maxy - 3
          top_line -= page_lines

          top_line = 0 if top_line < 0

          @entry_content_window.clear
          @entry_content_window.addstr(entry_text.lines[top_line..-1].join)
          @entry_base_window.refresh
          @entry_content_window.refresh
        end
      when 'd'
        if mode == 'nav'
          entry_list.menu.scroll_down_page
          @list_base_window.refresh
          @list_nav_window.refresh
        else
          page_lines = @entry_content_window.maxy - 3
          top_line += page_lines

          top_line = entry_text.lines.count - 1 if top_line > entry_text.lines.count

          @entry_content_window.clear
          @entry_content_window.addstr(entry_text.lines[top_line..-1].join)
          @entry_base_window.refresh
          @entry_content_window.refresh
        end

        
      when Curses::KEY_ENTER, 10, 13
        mode = 'reader'
        activate_window(@entry_base_window)
        @entry_content_window.clear
        entry_text = entry_viewer.show_entry(entry_list.menu.current_item)
        @entry_content_window.setpos(1, 1)
        @entry_base_window.setpos(1, 1)
        @entry_base_window.refresh
        @entry_content_window.refresh
      end
    rescue Curses::RequestDeniedError
    end
  end
ensure
  entry_list.menu.unpost
  @list_nav_window.close
  @entry_content_window.close
  @entry_base_window.close
  Curses.close_screen
end
