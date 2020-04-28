require 'spec_helper'

require_relative '../lib/SVG/Graph/Plot'
require_relative '../lib/SVG/Graph/DataPoint'
require_relative 'shared_examples/all_add_data'

describe SVG::Graph::Plot do
  let(:graph) { described_class.new({}) }

  describe 'constructor and defaults' do
    subject { graph }

    it { is_expected.to be_a_kind_of SVG::Graph::Graph }

    it 'initializes defaults from Graph.initialize'

    its(:scale_x_integers) { is_expected.to be false }
    its(:scale_y_integers) { is_expected.to be false }
    its(:show_data_points) { is_expected.to be true }
  end

  describe '#add_data' do
    let(:params) { {data: data} }
    let(:graph) { super().tap {|graph| graph.add_data params } }
    let(:pairs_count) { rand(2..5) }
    let(:odd_number) { pairs_count * 2 + 1 }

    include_examples 'all add_data'

    context 'array of pairs' do
      let(:data) { Array.new(odd_number) { Faker::Lorem.words number: 2} }

      it 'succeeds even with an odd number of pairs' do
        expect { graph.add_data params }.not_to raise_error
      end
    end

    context 'odd array length' do
      let(:data) { Faker::Lorem.words(number: odd_number) }

      it 'raises an error' do
        expect { graph.add_data params }.to raise_error /contained an odd set of data points/
      end
    end

    context 'description' do
      let(:data) { Faker::Lorem.words(number: pairs_count * 2) }
      let(:description) { Faker::Lorem.words number: description_count }
      let(:params) { {data: data, description: description} }

      shared_examples 'invalid data' do
        it 'raises an error' do
          expect { graph.add_data params }.to raise_error /^Description for popups does not have same size as provided data/
        end
      end

      context 'one entry per pair of data points' do
        let(:description_count) { pairs_count }

        it 'succeeds' do
          expect { graph.add_data params }.not_to raise_error
        end
      end

      context 'fewer entries than pairs' do
        let(:description_count) { pairs_count - 1 }
        include_examples 'invalid data'
      end

      context 'more entries than pairs' do
        let(:description_count) { pairs_count + 1 }
        include_examples 'invalid data'
      end
    end
  end


  describe '#burn' do
    before(:each) { DataPoint.reset_shape_criteria }

    let(:options) do
      {
        height: rand(400..600),
        width: rand(200..400),
        key: true,
        scale_x_integers: true,
        scale_y_integers: true,
      }
    end
    let(:title) { Faker::Lorem.sentence }
    let(:pairs_count) { rand(5..10) }
    let(:data_params) { {data: data, title: title} }
    let(:graph) { described_class.new(options).tap {|graph| graph.add_data data_params } }
    let(:svg_text) { graph.burn }
    let(:svg) { Capybara.string svg_text }

    context 'basic smoketest' do
      let(:data) { Array.new(pairs_count * 2) { rand 20 } }

      it 'writes an SVG string including credits to SVG::Graph' do
        series2 = Array.new(rand(5..10) * 2) { rand 20 }

        graph.add_data({
          data: series2,
          title: Faker::Lorem.sentence
        })

        expect(svg_text).to match /Created with SVG::Graph/
      end

      it 'writes a coherent SVG file' do
        expect { File.write(File.expand_path("../plot.svg", __FILE__), graph.burn) }.not_to raise_error
      end
    end

    context 'plot axis too short' do
      let(:max_x_value) { rand 10..20 }
      let(:max_y_value) { rand 10..20 }
      let(:min_x_value) { rand 2..6 }
      let(:min_y_value) { rand 2..6 }
      let(:x_range) { min_x_value..max_x_value }
      let(:y_range) { min_y_value..max_y_value }
      let(:too_low) { [min_x_value - 1, min_y_value - 1] }
      let(:too_high) { [max_x_value + 1, max_y_value + 1] }
      let(:data) { (Array.new(pairs_count) { [rand(x_range), rand(y_range)] } + [too_low, too_high]).shuffle.flatten }

      let(:options) do
        super().merge(
          max_x_value: max_x_value,
          max_y_value: max_y_value,
          min_x_value: min_x_value,
          min_y_value: min_y_value,
          scale_x_divisions: 3,
          scale_y_divisions: 3
        )
      end

      it 'still writes a graph' do
        expect { File.write(File.expand_path("../plot_axis_short.svg", __FILE__), graph.burn) }.not_to raise_error
      end
    end

    context 'graph options' do
      let(:data) { Array.new(pairs_count * 2) { rand 0.0..20.0 } }

      context 'area fill' do
        let(:background) { 'rect.graphBackground' }

        context ':area_fill is true' do
          let(:options) { super().merge area_fill: true }

          it 'fills the graph background' do
            expect(svg).to have_selector background
          end
        end

        context 'otherwise' do
          it 'does not fill the graph background' do
            pending 'This is a bug! :area_fill defaults to false, so there should not be a background in this case, but there is.'
            expect(svg).not_to have_selector background
          end
        end
      end

      context 'polyline connecting data points' do
        let(:polyline) { 'path.line1' }

        context ':show_lines is false' do
          let(:options) { super().merge show_lines: false }

          it 'does not draw the polyline' do
            expect(svg).not_to have_selector polyline
          end
        end

        context 'otherwise' do
          it 'draws the polyline' do
            expect(svg).to have_selector polyline
          end
        end
      end

      context 'popups' do
        let(:options) do
          super().merge(
            add_popups: true,
            number_format: "%s"
          )
        end

        context ':round_popups' do
          context 'false' do
            let(:options) { super().merge round_popups: false }

            it 'preserves decimal values' do
              File.write(File.expand_path("plot_#{__method__}.svg", __dir__), svg_text)

              data.each_slice(2) do |(x, y)|
                expect(svg_text).to include "(#{x}, #{y})"
                expect(svg_text).not_to include "(#{x.round}, #{y.round})"
              end
            end

            context 'text descriptions provided' do
              let(:descriptions) { Faker::Lorem.words number: pairs_count }
              let(:data_params) { super().merge description: descriptions.dup } # TODO: apparently the :description argument gets altered! This should be fixed...

              it 'shows text descriptions if provided' do
                File.write(File.expand_path("plot_#{__method__}.svg", __dir__), svg_text)

                data.each_slice(2).with_index do |(x, y), index|
                  expect(svg_text).to include "(#{x}, #{y}, #{descriptions[index]})"
                  expect(svg_text).not_to include "(#{x}, #{y})"
                end
              end

              context ':number_format not given' do
                let(:options) { super().tap {|options| options.delete :number_format } }
                let(:pairs_count) { 3 } # TODO: get rid of this when we refactor the one spec in this context
                let(:descriptions) { ['one is a circle', 'two is a rectangle', 'three is a rectangle with strikethrough'] }

                it 'combines different shapes based on the descriptions given' do
                  # TODO: we may be able to move this into a higher context after we refactor it
                  # TODO: does this spec belong here, or should it be in DataPoint, or an integration spec?
                  # TODO: wherever this goes, we should clean it up a bit.

                  # multiple array of the form
                  # [ regex ,
                  #   lambda taking three arguments (x,y, line_number for css)
                  #     -> return value of the lambda must be an array: [svg tag name,  Hash with keys "points" and "class"]
                  # ]
                  DataPoint.configure_shape_criteria(
                    [/^t.*/, lambda{|x,y,line| ['polygon', {
                      "points" => "#{x-1.5},#{y+2.5} #{x+1.5},#{y+2.5} #{x+1.5},#{y-2.5} #{x-1.5},#{y-2.5}",
                      "class" => "dataPoint#{line}"
                      }]
                      }],
                      [/^three.*/, lambda{|x,y,line| ['line', {
                        "x1" => "#{x-4}",
                        "y1" => y.to_s,
                        "x2" => "#{x+4}",
                        "y2" => y.to_s,
                        "class" => "axis"
                        }]
                        },"OVERLAY"],
                      )

                  File.write(File.expand_path("plot_#{__method__}.svg", __dir__), svg_text)
                  ['polygon[points]', 'line.axis'].each {|selector| expect(svg).to have_selector selector }
                end
              end
            end
          end

          context 'otherwise' do
            it 'rounds the values to integer by default' do
              File.write(File.expand_path("plot_#{__method__}.svg", __dir__), svg_text)

              data.each_slice(2) do |(x, y)|
                expect(svg_text).not_to include "(#{x}, #{y})"
                expect(svg_text).to include "(#{x.round}, #{y.round})"
              end
            end
          end
        end

        context 'radius' do
          it 'is 10 by default' do
            expect(svg).to have_selector 'circle[r="10"][onmouseover]'
          end

          context ':popup_radius is specified' do
            let(:popup_radius) { rand(1.0..3.0) }
            let(:options) { super().merge popup_radius: popup_radius }

            it 'is the value of :popup_radius' do
              expect(svg).to have_selector "circle[r='#{popup_radius}'][onmouseover]"
            end
          end
        end
      end
    end
  end
end
