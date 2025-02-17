# frozen_string_literal: true
# This class is a wrapper around curses calls to create the 
# interface

require 'curses'
require_relative 'interface/components/entry_list'
require_relative 'interface/components/entry_viewer'

class Tui
  def initialize(entry_data)
    @entry_data = entry_data
    @mode = 'nav'
    initialize_curses
  end

  def nav_width
    return 20 if entry_data.empty?
    max = entry_data.map { |entry| entry[:date].length + entry[:title].length }.max

    max + 5
  end

  def reader_width
    Curses.cols - nav_width
  end

  # Handles initial interface setup
  def build
    @entry_list = EntryList.new(entry_data, nav_width).build
    @entry_viewer = EntryViewer.new(reader_width, nav_width).build

    # Help Bar
    Curses.setpos(Curses.lines - 2, 0)
    Curses.addstr("\u2191,\u2193 or  j,k to scroll | \u2190,\u2192 or h,l to switch panels | u, d to scroll pagewise | Enter to read | q to quit")
    Curses.refresh

    self
  end

  # Starts input capture
  def start
    begin 
      Curses.refresh
      activate_window('nav')
      @entry_list.refresh_components
      @entry_viewer.refresh_components

      while(ch = Curses.getch) && ch != 'q'
        if ['h', Curses::KEY_LEFT].include?(ch)
          @mode = 'nav'
          activate_window('nav')
          next
        end

        if ['l', Curses::KEY_RIGHT].include?(ch) && !@entry_viewer.entry_content.nil?
          @mode = 'reader'
          activate_window('reader')
          next
        end

        if @mode == 'nav'
          handle_nav_input(ch)
        else
          handle_reader_input(ch)
        end
      end

    end
  end

  private
  
  attr_reader :entry_data, :entry_list, :entry_viewer, :mode

  def initialize_curses
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
  end

  def activate_window(window_name = 'nav')
    window, other_window = window_name == 'nav' ? [entry_list, entry_viewer] : [entry_viewer, entry_list]
    window.activate
    other_window.deactivate
  end

  def handle_nav_input(ch)
    begin
    case ch
    when Curses::KEY_UP, 'k'
      @entry_list.scroll(:up)
    when Curses::KEY_DOWN, 'j'
      @entry_list.scroll(:down)
    when 'u'
      @entry_list.page(:up)
    when 'd'
      @entry_list.page(:down)
    when Curses::KEY_ENTER, 10, 13
      Curses.setpos(0, 0)
      Curses.refresh
      @mode = 'reader'
      @entry_viewer.show_entry(@entry_list.menu.current_item)
      activate_window('reader')
    end
    rescue Curses::RequestDeniedError
    end

    Curses.refresh
  end

  def handle_reader_input(ch)
    case ch
    when Curses::KEY_UP, 'k'
      @entry_viewer.scroll(:up)
    when Curses::KEY_DOWN, 'j'
      @entry_viewer.scroll(:down)
    when 'u'
      @entry_viewer.page(:up)
    when 'd'
      @entry_viewer.page(:down)
    end

    Curses.refresh
  end
end
