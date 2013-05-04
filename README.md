# heroku-monitor
Monitors your app's logs and displays metrics in your shell. Works really well in 
combination with [log-runtime-metrics](https://devcenter.heroku.com/articles/log-runtime-metrics).

## Install
```
$ heroku plugins:install https://github.com/naaman/heroku-monitor.git
```

## Usage
```
$ heroku monitor --ps web
[       Metric        |   Median   |    P75     |    P95     |    P99    ]
[---web.1---          | ---------- | ---------- | ---------- | ----------]
[web.1.load_avg_15m   | 0.09       | 0.09       | 0.09       | 0.09      ]
[web.1.load_avg_1m    | 0.02       | 0.02       | 0.03       | 0.03      ]
[web.1.load_avg_5m    | 0.08       | 0.09       | 0.09       | 0.09      ]
...
```

## Known Issues
* Escape sequences aren't quite right. If there's more output than the screen
can handle and you scroll in the terminal, output gets mangled.
* Only handles `measure=<name> val=<val>` [l2met](https://github.com/ryandotsmith/l2met)
format so far.
