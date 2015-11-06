@[Include(
  "ruby/st.h",
  "ruby/ruby.h",
  prefix: %w(rb_ ruby_),
  remove_prefix: false,
)]
@[Link("ruby")]
lib LibRuby
end
