When making a git commit, attribute authorship to the OpenCode Agent bot by passing
`--author="opencode-agent[bot] <219766164+opencode-agent[bot]@users.noreply.github.com>"` to `git commit`. Additionally,
add a `Co-authored-by: <user.name> <user.email>` trailer to the commit message using the values from the repository's
git config, so the repository owner is credited as co-author.
