#! /usr/bin/env python
# encoding: utf-8

VERSION='0.0.1'
APPNAME='waf-template-project'


top = '.'
out = 'build'


def options(opt):
  opt.load('compiler_cxx')
  opt.load('waf_unit_test')


def configure(conf):
  from waflib.Tools.compiler_cxx import cxx_compiler
  cxx_compiler['linux'] = ['clangxx', 'gxx']

  conf.load('compiler_cxx')

  # Unit Testing Library
  conf.load('waf_unit_test')
  conf.check(lib='gtest', uselib_store='GTEST')


def gtest_results(bld):
  from waflib import Logs
  lst = getattr(bld, 'utest_results', [])
  if not lst:
    return
  for (f, code, out, err) in lst:
    # if not code:
    #     continue

    # uncomment if you want to see what's happening
    # print(str(out, 'utf-8'))
    output = str(out, 'utf-8').split('\n')
    for i, line in enumerate(output):
      if '[ RUN      ]' in line and code:
        i += 1
        if '    OK ]' in output[i]:
          continue
        while not '[ ' in output[i]:
          Logs.warn('%s' % output[i])
          i += 1
      elif ' FAILED  ]' in line and code:
        Logs.error('%s' % line)
      elif ' PASSED  ]' in line:
        Logs.info('%s' % line)


def build(bld):
  directories = ['include', 'source', 'tests']

  bld.recurse(directories)
  bld.add_post_fun(gtest_results)
