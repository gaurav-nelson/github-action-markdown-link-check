# GitHub Action - Markdown link check 🔗✔️
This GitHub action checks all Markdown files in your repository for broken links. (Uses [tcort/markdown-link-check](https://github.com/tcort/markdown-link-check))

## How to use
1. Create a new file in your repository `.github/workflows/action.yml`.
1. Copy-paste the following workflow in your `action.yml` file:

   ```yml
   name: Check Markdown links
   
   on: push
   
   jobs:
     markdown-link-check:
       runs-on: ubuntu-latest
       steps:
       - uses: actions/checkout@master
       - uses: gaurav-nelson/github-action-markdown-link-check@0.6.0
   ```

## Configuration

- [Custom variables](#custom-variables)
- [Scheduled runs](#scheduled-runs)
- [Disable check for some links](#disable-check-for-some-links)

### Custom variables
You cancustomize the action by using the following variables:
 
- `use-quiet-mode`: Specify `yes` to only show errors in output.
- `use-verbose-mode`: Specify `yes` to show detailed HTTP status for checked links.
- `config-file`: Specify a [custom configuration
  file](https://github.com/tcort/markdown-link-check#config-file-format) for
  markdown-link-check. You can use it to remove false-positives by specifying
  replacement patterns and ignore patterns.
- `folder-path`: By default the `github-action-markdown-link-check` action
  checks for all markdown files in your repository. Use this option to limit
  checks to only specific folders.

#### Sample workflow with variables

```yml
name: Check Markdown links

on: push

jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: gaurav-nelson/github-action-markdown-link-check@0.6.0
      with:
        use-quiet-mode: 'yes'
        use-verbose-mode: 'yes'
        config-file: 'mlc_config.json'
        folder-path: 'docs/markdown_files'
```

### Scheduled runs
In addition to checking links on every push, or pull requests, its also a good
hygine to check for broken links regularly as well. See
[Workflow syntax for GitHub Actions - on.schedule](https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#onschedule)
for more details.

#### Sample workflow with scheduled job

```yml
name: Check Markdown links

on: 
on: 
  push:
    branches:
    - master
  schedule:
  # Run everyday at 9:00 AM (See https://pubs.opengroup.org/onlinepubs/9699919799/utilities/crontab.html#tag_20_25_07)
  - cron: "0 9 * * *"

jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: gaurav-nelson/github-action-markdown-link-check@0.6.0
      with:
        use-quiet-mode: 'yes'
        use-verbose-mode: 'yes'
        config-file: 'mlc_config.json'
        folder-path: 'docs/markdown_files'
```

### Disable check for some links
You can include the following HTML comments into your markdown files to disable
checking for certain links in a markdown document.

1. `<!-- markdown-link-check-disable -->` and `<!-- markdown-link-check-enable-->`: Use these to disable links for all links appearing between these
    comments.
   - Example:
     ```md
     <!-- markdown-link-check-disable -->
     ## Section
     
     Disbale link checking in this section. Ignore this [Bad Link](https://exampleexample.cox)
     <!-- markdown-link-check-enable -->
     ```
2. `<!-- markdown-link-check-disable-next-line -->` Use this comment to disable link checking for the next line.
3. `<!-- markdown-link-check-disable-line -->` Use this comment to disable link
   checking for the current line.