require 'rubygems'
require 'benchmark'
require File.dirname(__FILE__)+'/../lib/h2o'
require 'stringio'
require 'pp'
require 'strscan'

ParseRegex = /
  (.*?)(?:
    #{Regexp.escape(H2o::BLOCK_START)}    (.*?)
    #{Regexp.escape(H2o::BLOCK_END)}          |
    #{Regexp.escape(H2o::VAR_START)}      (.*?)
    #{Regexp.escape(H2o::VAR_END)}            |
    #{Regexp.escape(H2o::COMMENT_START)}  (.*?)
    #{Regexp.escape(H2o::COMMENT_END)}    | (.*?) 
  )(?:\r?\n)?
/xm

ParseRegex2 = /\G
  (.*?)(?:
    #{Regexp.escape(H2o::BLOCK_START)}    (.*?)
    #{Regexp.escape(H2o::BLOCK_END)}          |
    #{Regexp.escape(H2o::VAR_START)}      (.*?)
    #{Regexp.escape(H2o::VAR_END)}            |
    #{Regexp.escape(H2o::COMMENT_START)}  (.*?)
    #{Regexp.escape(H2o::COMMENT_END)}
  ) (?:\r?\n)?
/xm

ParseRegex3 = /(.*?) (?:\{\{ (.*?) \}\}|.*?|\{(?:% (.*?) %|\* (.*?) \*)\}) (?:\r?\n)? /mx

ParseRegex4 = /\G (?:\{\{ .*? \}\}|.*?|\{(?:% .*? %|\* .*? \*)\}) \r?\n /mx


file = File.read(File.dirname(__FILE__)+'/../benchmark/source.html')

pp ParseRegex

Benchmark.bm do|b|


  b.report('String#scan :') do
    file.scan(ParseRegex)
  end
   
  b.report('String#scan - with \G :') do
    file.scan(ParseRegex2)
  end
  
  b.report('String#scan - optimized :') do
    file.scan(ParseRegex3)
  end
  
  b.report('String#scan - optimized with \G :') do
    file.scan(ParseRegex4)
  end
end