@[Include(
  "git2.h",
  "git2/global.h",
  prefix: %w(git_ GIT_ Git))]
@[Link("git2")]
lib LibGit2
end
