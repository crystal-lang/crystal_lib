@[Include(
  "stdlib.h",
  "sys/types.h",
  "sys/socket.h",
  "netinet/tcp.h",
  "arpa/inet.h",
  "netdb.h",
  "string.h",
  "stdio.h",
  "unistd.h",
  "sys/file.h",
  "dirent.h",
  "sys/stat.h",
  "glob.h",
  flags: "-Dlint",
)]
lib LibC
  AF_UNSPEC = AF_UNSPEC
  AF_UNIX = AF_UNIX
  AF_INET = AF_INET
  AF_INET6 = AF_INET6

  SOL_SOCKET = SOL_SOCKET
  SO_REUSEADDR = SO_REUSEADDR
  SO_KEEPALIVE = SO_KEEPALIVE
  SO_LINGER = SO_LINGER
  SO_SNDBUF = SO_SNDBUF
  SO_RCVBUF = SO_RCVBUF
  TCP_NODELAY = TCP_KEEPALIVE
  TCP_KEEPIDLE = TCP_KEEPALIVE
  TCP_KEEPINTVL = TCP_KEEPINTVL
  TCP_KEEPCNT = TCP_KEEPCNT

  # memory
  fun malloc
  fun free

  # socket
  fun freeaddrinfo
  fun gai_strerror
  fun getaddrinfo
  fun socket
  fun socketpair
  fun inet_pton
  fun inet_ntop
  fun htons
  fun bind
  fun listen
  fun accept
  fun connect
  fun gethostbyname
  fun getsockname
  fun getpeername
  fun getsockopt
  fun setsockopt
  fun shutdown

  # string
  fun atof
  fun strtof
  fun strlen
  fun snprintf

  # file
  F_OK = F_OK
  X_OK = X_OK
  W_OK = W_OK
  R_OK = R_OK

  fun access
  fun link
  fun rename
  fun symlink
  fun unlink
  fun flock

  # dir
  fun getcwd
  fun chdir
  fun opendir
  fun closedir
  fun mkdir
  fun rmdir
  fun readdir
  fun rewinddir
  fun glob
  fun globfree

  # env
  # $environ : Void
  fun getenv
  fun setenv
  fun unsetenv
end