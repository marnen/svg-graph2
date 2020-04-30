RSpec.shared_context 'graph' do
  let(:graph_title) { Faker::Lorem.sentence }
  let(:width) { rand 600..1000 }
  let(:height) { rand 400..500 }

  let(:options) do
    {
      width: width,
      height: height,
      graph_title: graph_title,
    }
  end

  let(:length) { rand 5..8 }
  let(:series_count) { rand 2..4 }
  let(:generator) { proc { rand(1.0..10.0).send [:to_f, :to_i].sample } }
  let(:series) do
    Array.new(series_count) do
      {data: Array.new(length, &generator), title: Faker::Lorem.word}
    end
  end

  let(:graph) do
    described_class.new(options).tap do |graph|
      series.each {|series| graph.add_data series }
    end
  end
end
