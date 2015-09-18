@[Include("editline/readline.h")]
@[Link("readline")]
lib LibReadline
  # $rl_attempted_completion_function : CPP
  # $rl_line_buffer : UInt8*
  # $rl_point : Int
  # $rl_done : Int

  fun readline
  fun add_history
  fun rl_bind_key
  # fun rl_unbind_key
end
