# GitHub Action - Markdown link check 🔗✔️
This GitHub action checks all Markdown files in your repository for broken links. (Uses [tcort/markdown-link-check](https://github.com/tcort/markdown-link-check))

## Sample workflow
```
workflow "New workflow" {
  on = "push"
  resolves = ["markdown-link-check"]
}

action "markdown-link-check" {
  uses = "./"
}
```

## Test links

www.google.com

[This is a broken link](www.exampleexample.cox)
