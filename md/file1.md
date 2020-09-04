
## Test internal and external links

www.google.com

<!-- markdown-link-check-disable-next-line -->
[This is a broken link](https://www.exampleexample.cox)
<!-- markdown-link-check-disable-next-line -->
[This is another broken link](http://ignored-domain.com) but its ignored using a
configuration file. 

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

### Check mailto links

Maksim Izmaylov <max@windingtree.com>


