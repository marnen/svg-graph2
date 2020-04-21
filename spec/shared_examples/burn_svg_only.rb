RSpec.shared_examples 'burn_svg_only' do
  let(:svg) { REXML::Document.new subject }

  subject { graph.burn_svg_only }

  it 'contains an <svg> element as root' do
    expect(svg.root.name).to be == 'svg'
  end

  it 'does not contain an XML declaration' do
    expect(subject).not_to include '?xml'
  end

  it 'does not contain a doctype declaration' do
    expect(subject).not_to include 'DOCTYPE'
  end
end
