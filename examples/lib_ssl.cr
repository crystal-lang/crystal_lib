@[Include(
  "openssl/ssl.h",
  "openssl/err.h",
)]
lib LibSSL
  fun ssl_load_error_strings = SSL_load_error_strings
  fun ssl_library_init = SSL_library_init
  fun sslv23_method = SSLv23_method
  fun ssl_ctx_new = SSL_CTX_new
  fun ssl_ctx_free = SSL_CTX_free
  fun ssl_new = SSL_new

  @[Raises]
  fun ssl_connect = SSL_connect

  @[Raises]
  fun ssl_accept = SSL_accept

  @[Raises]
  fun ssl_write = SSL_write

  @[Raises]
  fun ssl_read = SSL_read

  @[Raises]
  fun ssl_shutdown = SSL_shutdown

  fun ssl_free = SSL_free
  fun ssl_ctx_use_certificate_chain_file = SSL_CTX_use_certificate_chain_file
  fun ssl_ctx_use_privatekey_file = SSL_CTX_use_PrivateKey_file
  fun ssl_set_bio = SSL_set_bio
end
