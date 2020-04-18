require_relative '../lib/SVG/Graph/Bar'

describe SVG::Graph::Bar do
  context '#burn_svg_only' do
    it 'returns a basic SVG graph' do
      x_axis = ['1-10', '10-30', '30-50', '50-70', 'older']

      options = {
        :width             => 640,
        :height            => 500,
        :stack             => :side,  # the stack option is valid for Bar graphs only
        :fields            => x_axis,
        :graph_title       => "kg per head and year chocolate consumption",
        :show_graph_title  => true,
        :scale_integers    => true,
        :show_x_title      => true,
        :x_title           => 'Age in years',
        :stagger_x_labels => true,
        :rotate_x_labels   => true,
        :x_title_location  => :end,
        :show_y_title      => true,
        :y_title           => 'kg/year',
        :y_title_location  => :end,
        :add_popups        => true,
        :no_css            => true,
        :show_percent      => true,
        :show_actual_values => true,
        # :x_axis_position   => 0,
        # :y_axis_position   => '30-50',
      }

      data1   = [15, 4, 6.7, 4, 2.8]
      data2 = [1, 5, 4, 5, 12.7]

      g = SVG::Graph::Bar.new(options)

      g.add_data( {
          :data => data1,
          :title => "Dataset1"
        })
      g.add_data( {
          :data => data2,
          :title => "Dataset2"
        })

      # graph.burn            # this returns a full valid xml document containing the graph
      # graph.burn_svg_only   # this only returns the <svg>...</svg> node
      expect { File.open(File.expand_path('bar.svg',__dir__), 'w') {|f| f.write(g.burn_svg_only)} }.not_to raise_error
    end
  end
end
