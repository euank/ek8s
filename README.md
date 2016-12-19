# ek8s

This is more or less a dumping ground for pods I have on my personal k8s
cluster right now. I intend to make it a bit more sophisticated one of these
days, but for now...

I'm slowly migrating things from my old private git onto this, but I didn't do
a good job separating secrets out the first time and this isn't exactly a
priority. 


## Helm

This repository depends on the helm tool. It is primarily used in order to
correctly abstract out me-specific variables and at least pretend these could
be reused elsewhere.

## TODO

* Finish moving things over from the old repo
* Somewhat better secrets management would be nice
* Add linting (helm lint, yaml validation) for everything!
