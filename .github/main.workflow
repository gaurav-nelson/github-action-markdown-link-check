workflow "New workflow" {
  on = "push"
  resolves = ["markdown-link-check"]
}

action "markdown-link-check" {
  uses = "./"
}
