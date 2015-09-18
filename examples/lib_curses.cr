@[Include("curses.h")]
@[Link("ncurses")]
lib LibCurses
  # $lines : Void
  # $cols : Void

  fun initscr
  fun printw
  fun refresh
  fun getch
  fun cbreak
  fun move
  fun wmove
  fun addstr
  fun waddstr
  fun newwin
  fun box
  fun endwin

  fun delwin
  fun wrefresh
  fun wgetch
end
