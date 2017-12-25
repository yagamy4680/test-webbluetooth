#!/usr/bin/env lsc -cj
#

# Known issue:
#   when executing the `package.ls` directly, there is always error
#   "/usr/bin/env: lsc -cj: No such file or directory", that is because `env`
#   doesn't allow space.
#
#   More details are discussed on StackOverflow:
#     http://stackoverflow.com/questions/3306518/cannot-pass-an-argument-to-python-with-usr-bin-env-python
#
#   The alternative solution is to add `envns` script to /usr/bin directory
#   to solve the _no space_ issue.
#
#   Or, you can simply type `lsc -cj package.ls` to generate `package.json`
#   quickly.
#

# package.json
#
name: \test-webbluetooth

author:
  name: \yagamy
  email: \yagamy@gmail.com

description: 'A simple web server to test WebBluetooth APIs, to connect to several know BLE peripherals'

version: \0.0.1

repository:
  type: \git
  url: ''

engines:
  node: \4.4.x

scripts:
  server: '''
    ./node_modules/budo/bin/cmd.js \\
      --open \\
      --verbose \\
      --live \\
      --host 127.0.0.1 \\
      --watch-glob '**/*.{html,css,jade}' \\
      --css bootstrap.min.css \\
      --dir $(pwd)/assets \\
      $(pwd)/lib/entry.ls \\
      -- -t [ browserify-livescript --extensions .ls ]
  '''

dependencies: {}

devDependencies:
  budo: \*
  pug: \*
  \browserify-livescript : \*

optionalDependencies: {}

keywords: <[ble binary cb1 foop]>

license: \ISC
