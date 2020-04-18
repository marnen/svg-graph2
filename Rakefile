# -*- ruby -*-
# -*- coding: utf-8 -*-

# TODO
#
#require 'rubygems'
#require 'hoe'
#
#Hoe.plugin :git
#
#require_relative 'lib/svggraph'
#
#Hoe.spec 'svg-graph' do
#  self.version=SVG::Graph::VERSION
#  self.developer('Sean Russell', 'ser_AT_germane-software.com')
#  self.developer('Claudio Bustos', 'clbustos_AT_gmail.com')
#  self.developer('Liehann Loots','liehhanl_AT_gmail.com')
#  self.developer('Piergiuliano Bossi','pgbossi_AT_gmail.com')
#  self.developer('Manuel Widmer','m-widmer_AT_gmx.com')
#  self.rubyforge_name = 'ruby-statsample' # if different than 'svg_graph'
#  self.remote_rdoc_dir = 'svg-graph'
#end

# run all unit tests with 'rake spec'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task default: %w[spec]
