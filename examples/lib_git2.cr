@[Include(
  "git2.h",
  prefix: %w(git_ GIT_ Git),
  import_docstrings: "brief",
)]
@[Link("git2")]
lib LibGit2
end
