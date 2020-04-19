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
      let(:options) do
        super().merge(
          :max_x_value => 9,
          :max_y_value => 9,
          :min_x_value => 6,
          :min_y_value => 6,
          :scale_x_divisions => 3,
          :scale_y_divisions => 3
        )
      end
      it 'still writes a graph' do
        graph.add_data({
          :data => [5,5,  12,12,  6,6,  9,9,  7,7,  10,10],
          :title => '10',
        })

        expect { File.write(File.expand_path("../plot_axis_short.svg", __FILE__), graph.burn) }.not_to raise_error
      end
    end

    context 'polyline connecting data points' do
      context 'default' do
        it 'draws the polyline by default' do
          actual = [
            0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
            15, 6,   4, 17,   2, 12
          ]

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
          actual = [
            0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
            15, 6,   4, 17,   2, 12
          ]

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

      context 'default' do
        it 'rounds the values to integer by default' do
          actual = [
            0.1, 18,    8.55, 15.1234,    9.09876765, 4,
          ]

          graph.add_data({
            :data => actual,
            :title => 'Actual',
          })

          out=graph.burn()
          File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)
          [
            ['(0.1, 18)', '(0, 18)'],
            ['(8.55, 15.1234)', '(9, 15)'], # round up
            ['(9.09876765, 4)', '(9, 4)']
          ].each do |unrounded, rounded|
            expect(out).not_to include unrounded
            expect(out).to include rounded
          end
        end
      end

      context ':round_popups is false' do
        let(:options) { super().merge round_popups: false }

        it 'preserves decimal values if :round_popups is false' do
          actual = [
            0.1, 18,    8.55, 15.1234,    9.09876765, 4,
          ]

          graph.add_data({
            :data => actual,
            :title => 'Actual',
          })

          out=graph.burn()
          File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)

          [
            ['(0.1, 18)', '(0, 18)'],
            ['(8.55, 15.1234)', '(9, 15)'], # round up
            ['(9.09876765, 4)', '(9, 4)']
          ].each do |unrounded, rounded|
            expect(out).to include unrounded
            expect(out).not_to include rounded
          end
        end

        it 'shows text descriptions if provided' do
          actual = [
            8.55, 15.1234,    9.09876765, 4,     0.1, 18,
          ]
          description = [
           'first',    'second',          'third',
          ]

          graph.add_data({
            :data => actual,
            :title => 'Actual',
            :description => description,
          })

          out=graph.burn()
          File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)
          [
            ['(8.55, 15.1234, first)', '(8.55, 15.1234)'],
            ['(9.09876765, 4, second)', '(9.09876765, 4)'],
            ['(0.1, 18, third)', '(0.1, 18)']
          ].each do |with_string, without_string|
            expect(out).to include with_string
            expect(out).not_to include without_string
          end
        end

        context ':number_format not given' do
          let(:options) { super().tap {|options| options.delete :number_format } }

          it 'combines different shapes based on the descriptions given' do
            actual = [
             8.55, 15.1234,         9.09876765, 4,                  2.1, 18,
            ]
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
          it 'is 10 by default' do
            actual = [
             1, 1,    5, 5,     10, 10,
            ]
            description = [
             'first',    'second',          'third',
            ]

            graph.add_data({
              :data => actual,
              :title => 'Actual',
              :description => description,
            })

            out=graph.burn()
            expect(out).to match /circle .*r='10'/
            expect(out).to match /circle .*onmouseover=.*/
          end

          context ':popup_radius is specified' do
            let(:options) { super().merge popup_radius: 1.23 }

            it 'is the value of :popup_radius' do
              actual = [
               1, 1,    5, 5,     10, 10,
              ]
              description = [
               'first',    'second',          'third',
              ]

              graph.add_data({
                :data => actual,
                :title => 'Actual',
                :description => description,
              })

              out=graph.burn()
              expect(out).to match /circle .*r='1.23'/
              expect(out).to match /circle .*onmouseover=.*/
            end
          end
        end
      end
    end
  end
end
