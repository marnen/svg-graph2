require_relative '../lib/svggraph'

describe SVG::Graph::C3js do
  describe 'constructor' do
    context 'inlined dependencies' do
      context 'valid files' do
        it 'creates a usable object' do
          opts = {
            "inline_dependencies" => true,
            "d3_js"  => File.expand_path("d3.min.js",__dir__),
            "c3_css" => File.expand_path("c3.min.css",__dir__),
            "c3_js"  => File.expand_path("c3.min.js",__dir__)
          }

          expect { described_class.new opts }.not_to raise_error
          # TODO: add specs to make sure that #burn writes the dependencies?
        end
      end

      context 'invalid files' do
        it 'raises an error' do
          opts = {
            "inline_dependencies" => true,
            "d3_js"  => "/path/to/local/copy/of/d3.min.js",
            "c3_css" => "/path/to/local/copy/of/c3.min.css",
            "c3_js"  => "/path/to/local/copy/of/c3.min.js"
          }

          expect { described_class.new opts }.to raise_error RuntimeError
        end
      end
    end
  end

  describe 'instance methods' do
    let(:bindto_id) { 'this_is_my_awesom_graph' }
    let(:dataset1) { ['data1', 30, 200, 100, 400, 150, 250] }
    let(:dataset2) { ['data2', 300, 20, 10, 40, 15, 25] }

    let(:hash_chart_spec) do
      {
        bindto: "##{bindto_id}",
        data: {
          columns: [
            dataset1,
            dataset2
          ],
          axes: {
            data1: 'y',
            data2: 'y2',
          }
        },
        axis: {
          x: {
            label: 'X Label'
          },
          y: {
            label: {
              text: 'Y Axis Label',
              position: 'outer-middle'
            }
          },
          y2: {
            show: true,
            label: {
              text: 'Y2 Axis Label',
              position: 'outer-middle'
            }
          }
        },
        tooltip: {
      #   enabled: false
        },
        zoom: {
          enabled: true
        },
        subchart: {
          show: true
        }
      }
    end

    let(:heredoc_chart_spec) do
      <<-HEREDOC
        var my_chart1 = c3.generate({
          // bindto is mandatory
          "bindto": "##{bindto_id}",
          "data": {
            "columns": [
                #{dataset1},
                #{dataset2}
            ],
            "axes": {
              "data1": "y",
              "data2": "y2"
            }
          },
          "axis": {
            "x": {
              "label": "X Label"
            },
            "y": {
              "label": {
                "text": "Y Axis Label",
                "position": "outer-middle"
              }
            },
            "y2": {
              "show": true,
              "label": {
                "text": "Y2 Axis Label",
                "position": "outer-middle"
              }
            }
          },
          "tooltip": {
          },
          "zoom": {
            "enabled": true
          },
          "subchart": {
            "show": true
          }
        });

        setTimeout(function () {
          my_chart1.load({
              columns: [
                  ['data1', 230, 190, 300, 500, 300, 400]
              ]
          });
        }, 1000);

        setTimeout(function () {
          my_chart1.load({
                columns: [
                    ['data3', 130, 150, 200, 300, 200, 100]
                ]
            });
        }, 1500);

        setTimeout(function () {
          my_chart1.unload({
                ids: 'data1'
            });
        }, 2000);
      HEREDOC
    end

    let(:graph) { described_class.new }

    describe '#burn' do
      context 'hash chart spec' do
        it 'writes a file without error' do |example|
          graph.add_chart_spec hash_chart_spec, 'mychart1'
          expect { write_file filename_for(example), graph.burn }.not_to raise_error
        end
      end

      context 'heredoc chart spec' do
        it 'writes a file without error' do |example|
          graph.add_chart_spec heredoc_chart_spec
          expect { write_file filename_for(example), graph.burn }.not_to raise_error
        end
      end
    end

    describe '#burn_svg_only' do
      it 'writes a file without error' do |example|
        graph.add_chart_spec hash_chart_spec, 'mychart1'
        expect { write_file filename_for(example), graph.burn_svg_only }.not_to raise_error
      end
    end
  end
  private

  def filename_for(example)
    example.full_description.downcase.gsub /\W/, '_'
  end

  def write_file(method_name, output)
    File.open(File.expand_path("c3js_#{method_name}.html", __dir__), "w+") do |f|
      f.write(output)
    end # File.open
  end
end
