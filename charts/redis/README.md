This chart is basically the bitnami Redis chart, but adapted to use
the official `library/redis:alpine` image instead.

Why?
I couldn't get the bitnami chart to work. Pod would crash complaining of no
permissions to `/bitnami/data`.
