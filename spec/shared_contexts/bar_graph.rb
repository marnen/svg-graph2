require_relative 'graph'

RSpec.shared_context 'bar graph' do
  include_context 'graph' do
    let(:length) { rand 5..8 }
    let(:x_title) { Faker::Lorem.sentence }
    let(:fields) { Faker::Lorem.words number: length }
    let(:y_title) { Faker::Lorem.sentence }

    let(:extra_options) { {} }

    before(:each) do
      options.merge!(
        stack: :side,  # the stack option is valid for Bar graphs only
        fields: fields,
        scale_integers: true,
        x_title: x_title,
        x_title_location: :end,
        y_title: y_title,
        y_title_location: :end,
        no_css: true
      ).merge! extra_options
    end
  end

  let(:series_count) { rand 2..4 }
  let(:series) do
    Array.new(series_count) do
      {data: Array.new(length) { rand(1.0..10.0).send [:to_f, :to_i].sample }, title: Faker::Lorem.word}
    end
  end

  let(:graph) do
    described_class.new(options).tap do |graph|
      series.each {|series| graph.add_data series }
    end
  end
end
