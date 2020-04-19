require 'spec_helper'

require_relative '../lib/SVG/Graph/Plot'
require_relative '../lib/SVG/Graph/DataPoint'

# TODO: this file needs a lot of work!

describe SVG::Graph::Plot do
  before(:each) { DataPoint.reset_shape_criteria }

  describe '#burn' do
    let(:options) do
      {
        :height => 500,
        :width => 300,
        :key => true,
        :scale_x_integers => true,
        :scale_y_integers => true,
      }
    end
    let(:graph) { described_class.new options }

    it 'writes an SVG string including credits to SVG::Graph' do
      projection = Array.new(rand(5..10) * 2) { rand 20 }
      actual = Array.new(rand(5..10) * 2) { rand 20 }

      graph.add_data({
        :data => projection,
        :title => 'Projected',
      })

      graph.add_data({
        :data => actual,
        :title => 'Actual',
      })

      out=graph.burn()
      expect(out).to match /Created with SVG::Graph/
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
      let(:data) { (Array.new(rand 2..7) { [rand(x_range), rand(y_range)] } + [too_low, too_high]).shuffle.flatten }

      let(:options) do
        super().merge(
          :max_x_value => max_x_value,
          :max_y_value => max_y_value,
          :min_x_value => min_x_value,
          :min_y_value => min_y_value,
          :scale_x_divisions => 3,
          :scale_y_divisions => 3
        )
      end
      it 'still writes a graph' do
        graph.add_data({
          :data => data,
          :title => '10',
        })

        expect { File.write(File.expand_path("../plot_axis_short.svg", __FILE__), graph.burn) }.not_to raise_error
      end
    end

    context 'polyline connecting data points' do
      let(:actual) { Array.new(rand(5..10) * 2) { rand 20 } }

      context 'default' do
        it 'draws the polyline by default' do
          graph.add_data({
            :data => actual,
            :title => 'Actual',
          })
          expect(graph.burn).to match /path.*class='line1'/
        end
      end

      context ':show_lines is false' do
        let(:options) { super().merge show_lines: false }

        it 'does not draw the polyline' do
          graph.add_data({
            :data => actual,
            :title => 'Actual',
          })

          expect(graph.burn).not_to match /path class='line1' d='M.* L.*'/
        end
      end
    end

    context 'popups' do
      let(:options) do
        super().merge(
          :add_popups => true,
          :number_format => "%s"
        )
      end
      let(:pairs_count) { rand(5..10) }
      let(:actual) { Array.new(pairs_count * 2) { rand 0.0..20.0 } }

      context 'default' do
        it 'rounds the values to integer by default' do
          graph.add_data({
            :data => actual,
            :title => 'Actual',
          })

          out=graph.burn()
          File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)

          actual.each_slice(2) do |(x, y)|
            expect(out).not_to include "(#{x}, #{y})"
            expect(out).to include "(#{x.round}, #{y.round})"
          end
        end
      end

      context ':round_popups is false' do
        let(:options) { super().merge round_popups: false }

        it 'preserves decimal values' do
          graph.add_data({
            :data => actual,
            :title => 'Actual',
          })

          out=graph.burn()
          File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)

          actual.each_slice(2) do |(x, y)|
            expect(out).to include "(#{x}, #{y})"
            expect(out).not_to include "(#{x.round}, #{y.round})"
          end
        end

        it 'shows text descriptions if provided' do
          descriptions = Faker::Lorem.words pairs_count

          graph.add_data({
            :data => actual,
            :title => 'Actual',
            :description => descriptions.dup, # TODO: apparently the :description argument gets altered! This should be fixed...
          })

          out=graph.burn()
          File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)

          actual.each_slice(2).with_index do |(x, y), index|
            expect(out).to include "(#{x}, #{y}, #{descriptions[index]})"
            expect(out).not_to include "(#{x}, #{y})"
          end
        end
      end

      context ':number_format not given' do
        let(:options) { super().tap {|options| options.delete :number_format } }
        let(:pairs_count) { 3 } # TODO: get rid of this when refactor the one spec in this context

        it 'combines different shapes based on the descriptions given' do
          # TODO: does this spec belong here, or should it be in DataPoint, or an integration spec?
          # TODO: wherever this goes, we should clean it up a bit.

          description = [
           'one is a circle',     'two is a rectangle',           'three is a rectangle with strikethrough',
          ]

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

          graph.add_data({
            :data => actual,
            :title => 'Actual',
            :description => description,
          })

          out=graph.burn()
          File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)
          expect(out).to match /polygon.*points/
          expect(out).to match /line.*axis/
        end
      end

      context 'radius' do
        let(:descriptions) { Faker::Lorem.words pairs_count } # TODO: we don't need this!

        it 'is 10 by default' do
          graph.add_data({
            :data => actual,
            :title => 'Actual',
            :description => descriptions,
          })

          out=graph.burn()
          expect(out).to match /circle .*r='10'/
          expect(out).to match /circle .*onmouseover=.*/
        end

        context ':popup_radius is specified' do
          let(:popup_radius) { rand(1.0..3.0) }
          let(:options) { super().merge popup_radius: popup_radius }

          it 'is the value of :popup_radius' do
            graph.add_data({
              :data => actual,
              :title => 'Actual',
              :description => descriptions,
            })

            out=graph.burn()
            expect(out).to match /circle .*r='#{Regexp.escape popup_radius.to_s}'/
            expect(out).to match /circle .*onmouseover=.*/
          end
        end
      end
    end
  end
end
