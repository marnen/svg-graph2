require 'spec_helper'

require_relative '../lib/SVG/Graph/ErrBar'
require_relative 'shared_contexts/bar_graph.rb'
require_relative 'shared_examples/a_bar_graph'

describe SVG::Graph::ErrBar do
  describe 'constructor' do
    let(:error_bars) { Faker::Lorem.words number: rand(1..5) }
    let(:fields) { Faker::Lorem.words number: rand(1..5) }
    let(:config) { {errorBars: error_bars, fields: fields} }

    subject { described_class.new config }

    shared_examples 'invalid unless non-empty array' do
      shared_examples 'invalid data' do
        it 'raises an error' do
          expect { subject }.to raise_error 'fields was not supplied or is empty'
        end
      end

      context 'not present' do
        let(:config) { super().tap {|config| config.delete field } }
        include_examples 'invalid data'
      end

      context 'not an array' do
        let(:config) { super().merge field => Faker::Lorem.sentence }
        include_examples 'invalid data'
      end

      context 'an empty array' do
        let(:config) { super().merge field => [] }
        include_examples 'invalid data'
      end
    end

    context ':errorBars' do
      let(:field) { :errorBars }
      include_examples 'invalid unless non-empty array'
    end

    context ':fields' do # TODO: this probably belongs in shared examples for BarBase
      let(:field) { :fields }
      include_examples 'invalid unless non-empty array'
    end

    context 'otherwise' do
      it { is_expected.to be_a_kind_of described_class }
      it { is_expected.to be_a_kind_of SVG::Graph::BarBase }
    end
  end

  describe '#burn' do
    include_context 'bar graph' do
      let(:error_bars) { series.first[:data].map {|value| rand((value * 0.1)..(value * 0.4)) } }
      let(:extra_options) { {errorBars: error_bars} }
      let(:series_count) { 1 }
    end

    let(:svg) { Capybara.string graph.burn }

    it_behaves_like 'a bar graph', label_axis: 'x', scale_dimension: :height, rotate_y_labels_default: false, supports_customized_data_labels: false, normalize_popup_formatting: false # TODO: make this behave more like the other bar graphs so we can remove all these options!

    it 'returns a basic SVG graph' do
      expect do
        File.open(File.expand_path("err_bar.svg",__dir__), "w") {|fout|
          fout.print( graph.burn )
        }
      end.not_to raise_error
    end
  end
end
