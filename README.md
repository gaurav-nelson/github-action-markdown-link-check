# GitHub Action - Markdown link check 🔗✔️
This GitHub action checks all Markdown files in your repository for broken links. (Uses [tcort/markdown-link-check](https://github.com/tcort/markdown-link-check))

## How to use
1. Create a new file in your repository `.github/workflows/action.yml`.
1. Copy-paste the folloing workflow in your `action.yml` file:

   ```yml
   name: Check Markdown links
   
   on: push
   
   jobs:
     markdown-link-check:
       runs-on: ubuntu-latest
       steps:
       - uses: actions/checkout@master
         with:
           fetch-depth: 1
       - uses: gaurav-nelson/github-action-markdown-link-check@0.4.0
   ```
1. To use a [custom configuration](https://github.com/tcort/markdown-link-check#config-file-format)
   for markdown-link-check, create a JSON configuration file and save it in the
   root folder as `mlc_config.json`.

## Test links

www.google.com

[This is a broken link](www.exampleexample.cox)

[This is another broken link](http://ignored-domain.com) but its ignored using a
configuration file. 
