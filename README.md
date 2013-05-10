# Landable
Rails engine providing an API and such for managing mostly static content.

It will likely also contain CSS and JS assets which provide common component implementations.

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
