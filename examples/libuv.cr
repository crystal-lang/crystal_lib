@[Include("uv.h")]
@[Link("uv")]
lib LibUV
  fun close = uv_close

  fun fs_open = uv_fs_open
  fun fs_read = uv_fs_read
  fun fs_write = uv_fs_write
  fun fs_close = uv_fs_close
  fun fs_req_cleanup = uv_fs_req_cleanup
  fun fs_fstat = uv_fs_fstat

  fun prepare_init = uv_prepare_init
  fun prepare_start = uv_prepare_start
  fun prepare_stop = uv_prepare_stop

  fun timer_init = uv_timer_init
  fun timer_start = uv_timer_start
  fun timer_stop = uv_timer_stop
  fun timer_again = uv_timer_again

  fun read_start = uv_read_start
  fun read_stop = uv_read_stop
  fun write = uv_write
  fun listen = uv_listen
  fun accept = uv_accept

  fun tcp_init = uv_tcp_init
  fun tcp_connect = uv_tcp_connect
  fun tcp_bind = uv_tcp_bind

  fun getaddrinfo = uv_getaddrinfo
  fun freeaddrinfo = uv_freeaddrinfo

  fun loop_new = uv_loop_new
  fun default_loop = uv_default_loop
  fun run = uv_fs_req_cleanup
end
