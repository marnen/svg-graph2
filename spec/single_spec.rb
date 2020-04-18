require 'spec_helper'

# TODO: what is this file for? It was translated from test/single.rb, which wasn't run when all the other tests were...

require_relative '../lib/SVG/Graph/BarHorizontal'
require_relative '../lib/SVG/Graph/Bar'
require_relative '../lib/SVG/Graph/Line'
require_relative '../lib/SVG/Graph/Pie'

describe 'single pie chart' do
  it 'generates SVG without error' do
    File.open(File.join(__dir__, "data.txt")) { |fin|
      title = fin.readline
      fields = fin.readline.split( /,/ )
      female_data = fin.readline.split( " " ).collect{|x| x.to_i}
      male_data = fin.readline.split( " " ).collect{|x| x.to_i}

      graph = SVG::Graph::Pie.new( {
        :width => 640,
        :height => 480,
        :fields => fields,
        :graph_title => title,
        :show_graph_title => true,
        :no_css => true,
        :expanded => true,
        :show_data_labels => true
      })
      graph.add_data( {
          :data => female_data,
          :title => "Female"
        })
      graph.add_data( {
          :data => male_data,
          :title => "Male"
        })
      expect { puts graph.burn }.not_to raise_error
    }
  end
end
