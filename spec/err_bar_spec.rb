require_relative '../lib/SVG/Graph/ErrBar'

describe SVG::Graph::ErrBar do
  describe '#burn' do
    it 'returns a basic SVG graph' do
      fields = %w(Jan Feb);
      myarr1_mean = 10
      myarr1_confidence = 1

      myarr2_mean = 20
      myarr2_confidence = 2

      data_mesure = [myarr1_mean, myarr2_mean]

      err_mesure = [myarr1_confidence, myarr2_confidence]

      graph = SVG::Graph::ErrBar.new(
        :height => 500,
        :width => 600,
        :fields => fields,
        :errorBars =>err_mesure
      )

      graph.add_data(
        :data => data_mesure,
        :title => 'Sales 2002'
      )

      expect do
        File.open(File.expand_path("test_err_bar.svg",__dir__), "w") {|fout|
          fout.print( graph.burn )
        }
      end.not_to raise_error
    end
  end
end
