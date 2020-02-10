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
       - uses: gaurav-nelson/github-action-markdown-link-check@0.5.0
   ```
1. If you want to use a [custom configuration](https://github.com/tcort/markdown-link-check#config-file-format)
   for markdown-link-check, or use the `--verbose` or `--quite` options, use the
   `config-file`, `use-quite-mode`, and `use-verbose-mode` variables as follows:

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
       - uses: gaurav-nelson/github-action-markdown-link-check@0.5.0
         with:
           use-quite-mode: 'yes'
           use-verbose-mode: 'yes'
           config-file: 'mlc_config.json'
   ```

## Test internal and external links

www.google.com

[This is a broken link](https://www.exampleexample.cox)

[This is another broken link](http://ignored-domain.com) but its ignored using a
configuration file. 

### Alpha

This [exists](#alpha).
This [one does not](#does-not).
References and definitions are [checked][alpha] [too][charlie].

### Bravo

Headings in `readme.md` are [not checked](readme.md#bravo).
But [missing files are reported](missing-example.js).

[alpha]: #alpha
[charlie]: #charlie

External file: [Charlie](./README2.md/#charlie)