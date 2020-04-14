
## Test internal and external links

www.google.com

<!-- markdown-link-check-disable-next-line -->
[This is a broken link](https://www.exampleexample.cox)
<!-- markdown-link-check-disable-next-line -->
[This is another broken link](http://ignored-domain.com) but its ignored using a
configuration file. 

### Delta

This [exists](#delta).
<!-- markdown-link-check-disable-next-line -->
This [one does not](#does-not).
References and definitions are [checked][delta].

### Echo

Headings in `readme.md` are [not checked](file3.markdown#echo).
<!-- markdown-link-check-disable-next-line -->
But [missing files are reported](missing-example.js).

[delta]: #delta
