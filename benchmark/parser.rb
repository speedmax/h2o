require 'rubygems'
require 'benchmark'
require File.dirname(__FILE__)+'/../lib/h2o'
require 'stringio'
require 'pp'
require 'strscan'

ParseRegex = /\G
  (?:
    #{Regexp.escape(H2o::BLOCK_START)}    (.*?)
    #{Regexp.escape(H2o::BLOCK_END)}          |
    #{Regexp.escape(H2o::VAR_START)}      (.*?)
    #{Regexp.escape(H2o::VAR_END)}            |
    #{Regexp.escape(H2o::COMMENT_START)}  (.*?)
    #{Regexp.escape(H2o::COMMENT_END)}    | (.*?) 
  )(?:\r?\n)
/xm

ParseRegex2 = /
  (.*??)(?:
    #{Regexp.escape(H2o::BLOCK_START)}    (.*?)
    #{Regexp.escape(H2o::BLOCK_END)}          |
    #{Regexp.escape(H2o::VAR_START)}      (.*?)
    #{Regexp.escape(H2o::VAR_END)}            |
    #{Regexp.escape(H2o::COMMENT_START)}  (.*?)
    #{Regexp.escape(H2o::COMMENT_END)}
  ) (?:\r?\n)
/xm

file = File.read(File.dirname(__FILE__)+'/../benchmark/source.html')

pp ParseRegex

Benchmark.bm do|b|


  b.report('String#scan :') do
    file.scan(ParseRegex)
  end 
  b.report('String#scan2 :') do
    file.scan(ParseRegex2)
  end
end