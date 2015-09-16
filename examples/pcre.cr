@[Include("pcre.h")]
@[Link("pcre")]
lib LibPCRE
  fun compile = pcre_compile
  fun study = pcre_study
  fun exec = pcre_exec
  fun full_info = pcre_fullinfo
  fun get_stringnumber = pcre_get_stringnumber

  INFO_CAPTURECOUNT  = PCRE_INFO_CAPTURECOUNT
  INFO_NAMEENTRYSIZE = PCRE_INFO_NAMEENTRYSIZE
  INFO_NAMECOUNT     = PCRE_INFO_NAMECOUNT
  INFO_NAMETABLE     = PCRE_INFO_NAMETABLE

  $pcre_malloc : Void
  $pcre_free : Void
end
