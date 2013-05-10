# Landable
Rails engine providing an API and such for managing mostly static content.

It will likely also contain CSS and JS assets which provide common component implementations.

## See Also
Related projects we are also building:

1. [publicist](http://git.cashnetusa.com/trogdor/publicist): a web app for working with landable applications

Open source projects possibly worth using or referencing:

1. [doorkeeper](https://github.com/applicake/doorkeeper): OAuth2 provider engine ([example app](https://github.com/applicake/doorkeeper-provider-app))
2. [combustion](https://github.com/pat/combustion): gem to supposedly ease the pain of testing isolated Rails engines

## Generated Using
Just in case we need to do this due to incompatibilities from 3.x -> 4.0:

~~~~
$ gem install rails --version 4.0.0.rc1 --no-ri --no-rdoc

$ rails -v
Rails 4.0.0.rc1

$ rails plugin new landable --skip-test-unit --mountable --full --dummy-path=spec/dummy --database=postgresql

$ cd landable
$ git init
$ git add .
$ git commit -m 'landable: fresh engine generated with rails 4.0.0.rc1'
~~~~
