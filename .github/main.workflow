workflow "Markdown link check" {
  resolves = ["markdown-link-check"]
  on = "push"
}

action "markdown-link-check" {
  uses = "./"
}
