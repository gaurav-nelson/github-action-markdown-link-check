<table>
  <tr>
    <td>
      <h1> ⛔️ Deprecation notice (Apr 2025) </h1>
      <p>
        This repository is now ⛔️ <strong>deprecated</strong> and is no longer actively maintained.
      </p>
      <p>
        For support and further development, please use the maintained fork available at
        <a href="https://github.com/tcort/github-action-markdown-link-check">Tcort GitHub Action Markdown Link Check</a>.
      </p>
      <hr />
      <p>
        I have also developed a new tool called
        <a href="https://github.com/UmbrellaDocs/linkspector">Linkspector</a>,
        which offers improved functionality and reduced false positives.
        You can try this tool as an alternative if it fits your needs.
      </p>
      <p>
        Try <a href="https://github.com/UmbrellaDocs/action-linkspector">GitHub Action Linkspector</a>!
      </p>
      <hr />
    </td>
  </tr>
</table>

### GitHub Action - Markdown link check 🔗✔️
[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Markdown%20link%20check-brightgreen?style=for-the-badge)](https://github.com/marketplace/actions/markdown-link-check)
<a href="https://liberapay.com/gaurav-nelson/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a>

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
       - uses: gaurav-nelson/github-action-markdown-link-check@v1
   ```

### Real-life usage samples

Following is a list of some of the repositories which are using GitHub Action -
Markdown link check.

1. [netdata](https://github.com/netdata/netdata/blob/master/.github/workflows/docs.yml) ![](https://img.shields.io/github/stars/netdata/netdata?style=social)
1. [GoogleChrome/lighthouse (Weekly cron job)](https://github.com/GoogleChrome/lighthouse/blob/master/.github/workflows/cron-weekly.yml)
   ![](https://img.shields.io/github/stars/GoogleChrome/lighthouse?style=social)
1. [tendermint/tendermint](https://github.com/tendermint/tendermint/blob/master/.github/workflows/markdown-links.yml)
   ![](https://img.shields.io/github/stars/tendermint/tendermint?style=social)
1. [pyroscope-io/pyroscope](https://github.com/pyroscope-io/pyroscope/blob/main/.github/workflows/lint-markdown.yml)
   ![](https://img.shields.io/github/stars/pyroscope-io/pyroscope?style=social)

If you are using this on production, consider [buying me a coffee](https://liberapay.com/gaurav-nelson/) ☕.

## Configuration

- [Custom variables](#custom-variables)
- [Scheduled runs](#scheduled-runs)
- [Disable check for some links](#disable-check-for-some-links)
- [Check only modified files in a pull request](#check-only-modified-files-in-a-pull-request)
- [Check multiple directories and files](#check-multiple-directories-and-files)
- [Status code 429: Too many requests](#too-many-requests)
- [GitHub links failure fix](#github-links-failure-fix)

### Custom variables
You customize the action by using the following variables:

| Variable | Description | Default value |
|:----------|:--------------|:-----------|
|`use-quiet-mode`| Specify `yes` to only show errors in output.| `no`|
|`use-verbose-mode`|Specify `yes` to show detailed HTTP status for checked links. |`no` |
|`config-file`|Specify a [custom configuration file](https://github.com/tcort/markdown-link-check#config-file-format) for markdown-link-check. You can use it to remove false-positives by specifying replacement patterns and ignore patterns. The filename is interpreted relative to the repository root.|`mlc_config.json`|
|`folder-path` |By default the `github-action-markdown-link-check` action checks for all markdown files in your repository. Use this option to limit checks to only specific folders. Use comma separated values for checking multiple folders. |`.` |
|`max-depth` |Specify how many levels deep you want to check in the directory structure. The default value is `-1` which means check all levels.|`-1` |
|`check-modified-files-only` |Use this variable to only check modified markdown files instead of checking all markdown files. The action uses `git` to find modified markdown files. Only use this variable when you run the action to check pull requests.|`no`|
|`base-branch`|Use this variable to specify the branch to compare when finding modified markdown files. |`master`|
|`file-extension`|By default the `github-action-markdown-link-check` action checks files in your repository with the `.md` extension. Use this option to specify a different file extension such as `.markdown` or `.mdx`.|`.md`|
|`file-path` | Specify additional files (with complete path and extension) you want to check. Use comma separated values for checking multiple files. See [Check multiple directories and files](#check-multiple-directories-and-files) section for usage.| - |

#### Sample workflow with variables

```yml
name: Check Markdown links

on: push

jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: gaurav-nelson/github-action-markdown-link-check@v1
      with:
        use-quiet-mode: 'yes'
        use-verbose-mode: 'yes'
        config-file: 'mlc_config.json'
        folder-path: 'docs/markdown_files'
        max-depth: 2
```

### Scheduled runs
In addition to checking links on every push, or pull requests, its also a good
hygiene to check for broken links regularly as well. See
[Workflow syntax for GitHub Actions - on.schedule](https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#onschedule)
for more details.

#### Sample workflow with scheduled job

```yml
name: Check Markdown links

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
    - uses: gaurav-nelson/github-action-markdown-link-check@v1
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

### Check only modified files in a pull request

Use the following workflow to only check links in modified markdown files in a
pull request.

When
you use this variable, the action finds modified files between two commits:
- latest commit in you PR
- latest commit in the `master` branch. If you are suing a different branch to
  merge PRs, specify the branch using `base-branch`.

> **NOTE**: We can also use GitHub API to get all modified files in a PR, but that
> would require tokens and stuff, create an issue or PR if you need that.

```yml
on: [pull_request]
name: Check links for modified files
jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: gaurav-nelson/github-action-markdown-link-check@v1
      with:
        use-quiet-mode: 'yes'
        use-verbose-mode: 'yes'
        check-modified-files-only: 'yes'

```

### Check multiple directories and files

```yml
on: [pull_request]
name: Check links for modified files
jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: gaurav-nelson/github-action-markdown-link-check@v1
      with:
        use-quiet-mode: 'yes'
        folder-path: 'md/dir1, md/dir2'
        file-path: './README.md, ./LICENSE, ./md/file4.markdown'
```

### Too many requests
Use `retryOn429`, `retry-after`, `retryCount`, and `fallbackRetryDelay` in your custom configuration file.
See https://github.com/tcort/markdown-link-check#config-file-format for details.

Or mark 429 status code as alive:
```json
{
  "aliveStatusCodes": [429, 200]
}
```

### GitHub links failure fix
Use the following `httpHeaders` in your custom configuration file to fix GitHub links failure.

```json
{
  "httpHeaders": [
    {
      "urls": ["https://github.com/", "https://guides.github.com/", "https://help.github.com/", "https://docs.github.com/"],
      "headers": {
        "Accept-Encoding": "zstd, br, gzip, deflate"
      }
    }
  ]
}
```

## Example Usage

Consider a workflow file that checks for the status of hyperlinks on push to the master branch,

``` yml
name: Check .md links

on:
  push: [master]

jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    # check out the latest version of the code
    steps:
    - uses: actions/checkout@v3

    # Checks the status of hyperlinks in .md files in verbose mode
    - name: Check links
      uses: gaurav-nelson/github-action-markdown-link-check@v1
      with:
        use-verbose-mode: 'yes'
```
A file `test.md` exists, containing

![image](https://user-images.githubusercontent.com/53875297/159135478-87194037-f3d6-4ca9-9da8-f01dac482fbc.png)

On running the workflow described above, the output shown below is obtained

![image](https://user-images.githubusercontent.com/53875297/159135426-9f439d39-8bb3-40f0-9255-9efe2b493c1a.png)


## Versioning
GitHub Action - Markdown link check follows the [GitHub recommended versioning strategy](https://github.com/actions/toolkit/blob/master/docs/action-versioning.md).

1. To use a specific released version of the action ([Releases](https://github.com/gaurav-nelson/github-action-markdown-link-check/releases)):
   ```yml
   - uses: gaurav-nelson/github-action-markdown-link-check@1.0.1
   ```
1. To use a major version of the action:
   ```yml
   - uses: gaurav-nelson/github-action-markdown-link-check@v1
   ```
1. You can also specify a [specific commit SHA](https://github.com/gaurav-nelson/github-action-markdown-link-check/commits/master) as an action version:
   ```yml
   - uses: gaurav-nelson/github-action-markdown-link-check@44a942b2f7ed0dc101d556f281e906fb79f1f478
   ```

<hr>
<p align="center">
 <a name="coffee" href="https://liberapay.com/gaurav-nelson/">
  <img src="https://i.imgur.com/1Q1YoHz.gif" alt="Buy me a coffee.">
 </a>
</p>
