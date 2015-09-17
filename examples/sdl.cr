@[Include("SDL/SDL.h")]
lib LibSDL
  INIT_TIMER = SDL_INIT_TIMER

  fun init = SDL_Init
  fun get_error = SDL_GetError
  fun quit = SDL_Quit
  fun set_video_mode = SDL_SetVideoMode
  fun delay = SDL_Delay
  fun poll_event = SDL_PollEvent
  fun wait_event = SDL_WaitEvent
  fun lock_surface = SDL_LockSurface
  fun unlock_surface = SDL_UnlockSurface
  fun update_rect = SDL_UpdateRect
  fun show_cursor = SDL_ShowCursor
  fun get_ticks = SDL_GetTicks
  fun flip = SDL_Flip
  fun main = SDL_main
end
