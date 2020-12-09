
## Test internal and external links

www.google.com

<!-- markdown-link-check-disable-next-line -->
[This is a broken link](https://www.exampleexample.cox)
<!-- markdown-link-check-disable-next-line -->
[This is another broken link](http://ignored-domain.com) but its ignored using a
configuration file.

This is to test URLencoding.
<https://en.wikipedia.org/wiki/Glob_%28programming%29>
<https://www.google.com/?q=url%20with%20a%20space>

### Alpha

This [exists](#alpha).
<!-- markdown-link-check-disable-next-line -->
This [one does not](#does-not).
References and definitions are [checked][alpha].

### Bravo

Headings in `readme.md` are [not checked](file1.md#bravo).
<!-- markdown-link-check-disable-next-line -->
But [missing files are reported](missing-example.js).

[alpha]: #alpha
