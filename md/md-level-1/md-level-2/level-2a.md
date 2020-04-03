
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

Headings in `readme.md` are [not checked](file1.md#bravo).
But [missing files are reported](missing-example.js).

[alpha]: #alpha
[charlie]: #charlie

External file: [Charlie](./file2.md/#charlie)