require_relative '../lib/SVG/Graph/BarHorizontal'
require_relative '../lib/SVG/Graph/Bar'
require_relative '../lib/SVG/Graph/Line'
require_relative '../lib/SVG/Graph/Pie'

def gen klass, args, title, fields, female_data, male_data
  args[ :width ] = 640
  args[ :height ] = 480
  #args[ :compress ] = true
  args[ :fields ] = fields
  args[ :graph_title ] = title
  #args[ :show_graph_title ] = true
  #args[ :key ] = false
  #args[ :key_position ] = :bottom
  args[ :show_x_title ]       = true
  args[ :x_title ]             = 'X Field names very long'
  #args[ :x_title ]             = 'X'
  args[ :x_title_location ] = :middle
  args[ :show_y_title ]        = true

  args[ :y_title_text_direction ] = :bt
  args[ :y_title ]             ='Y Scale very long name'
  #args[ :y_title ]             ='Y'
  args[ :y_title_location ] = :end
  args[ :no_css ] = true
  puts klass.name
  graph = klass.new( args )
  graph.add_data( {
      :data => female_data,
      :title => "Female"
    })
  graph.add_data( {
      :data => male_data,
      :title => "Male"
    })
  #return graph.burn
  return graph.burn_svg_only
end

File.open( File.expand_path("../data.txt", __FILE__ )) { |fin|
  title = fin.readline
  fields = fin.readline.split( /,/ )
  female_data = fin.readline.split( " " ).collect{|x| x.to_i}
  male_data = fin.readline.split( " " ).collect{|x| x.to_i}

  for file, klass, args in [
    [ "bar", SVG::Graph::Bar,
      { :scale_integers => true,
	      :stack => :side } ],
    [ "barhorizontal",SVG::Graph::BarHorizontal,
      {:scale_integers=> true,
	     :stack=>:side,
	     :rotate_x_labels => true
      }],
    [ "line", SVG::Graph::Line,
      { :scale_integers => true,
	    :area_fill => true, } ],
    [ "pie", SVG::Graph::Pie,
      { :expand_greatest => true,
	    :show_data_labels => true, } ],
    ]
    File.open(File.join(__dir__, "#{file}.svg"), "w") {|fout|
      fout.print( gen(klass, args, title, fields, female_data, male_data ) )
    }
  end
}
