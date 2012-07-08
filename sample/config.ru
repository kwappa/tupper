# -*- coding: utf-8 -*-
$: << File.dirname(File.expand_path(__FILE__))
require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'sample'
run Sample
