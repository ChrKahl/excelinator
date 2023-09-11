# frozen_string_literal: false

require "#{File.dirname(__FILE__)}/spec_helper"
require 'benchmark'

# rubocop:disable Metrics/BlockLength
describe Excelinator do
  let(:table) do
    table = <<-HTML
        <table>
          <tr>
            <td></td>
          </tr>
        </table>
    HTML
    table.strip
  end
  let(:utf8) { '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' }
  let(:one_two_three_xls) do
    case RUBY_VERSION
    when /^1.8/
      "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1"
    when /^1.9/
      "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1".force_encoding('US-ASCII')
    when /^2/
      "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1\x00\x00"
    when /^3/
      "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1"
    end
  end

  it 'should strip out table' do
    Excelinator.html_as_xls("<body>#{table}</body>").should == utf8 + table
  end

  it 'should strip out multiple tables' do
    # TODO: this will grab any html in between tables - should be smarter about that
    Excelinator.html_as_xls("<body>#{table}<hr/>#{table}</body>").should == utf8 + "#{table}<hr/>#{table}"
  end

  it 'should allow option to not strip out table since this\'ll be an expensive memory operation for a big HTML file' do
    Excelinator.html_as_xls("<body>#{table}</body>", do_not_strip: true).should == utf8 + "<body>#{table}</body>"
  end

  it 'should detect table and convert as html' do
    Excelinator.convert_content("<body>#{table}</body>").should == utf8 + table
  end

  it 'should not detect table and convert CSV' do
    compare_string = one_two_three_xls

    # mini-gold standard test: pre-calculated the Excel header bytes and merely that part to match
    expect(Excelinator.convert_content([1, 2, 3].join(','))[0..7].force_encoding('UTF-8'))
      .to eq(compare_string.force_encoding('UTF-8'))
  end

  it 'should not take a very long time to detect CSV content' do
    # this test verifies a quick HTML regex. Previously, the 'strip table' regex was used and that's too expensive
    # for detection in the case of large HTML content (at least double, though progressively worse as size increased)
    #
    # it's a risky test, as this can easily fail in other environments than it was written in. so, judge for yourself
    # whether or not it's worth it.
    large_html = table * 200_000
    Benchmark.realtime { Excelinator.convert_content(large_html) }.should < 1.0
  end
end
# rubocop:enable Metrics/BlockLength
