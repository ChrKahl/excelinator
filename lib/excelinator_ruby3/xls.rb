# ExcelinatorRuby3 module
module ExcelinatorRuby3
  MIME_TYPE = 'application/vnd.ms-excel'

  # Detects HTML table content (with a rather stupid regex: /<table/) and re-uses it, or attempts to convert from
  # CSV if HTML not detected.
  def self.convert_content(content)
    content =~ /<table/ ? ExcelinatorRuby3.html_as_xls(content) : ExcelinatorRuby3.csv_to_xls(content)
  end

  # rubocop:disable Metrics/MethodLength
  def self.csv_to_xls(csv_content, separator = ',')
    ary = (!old_ruby? ? CSV : FasterCSV).parse(csv_content, col_sep: separator)

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    ary.each_with_index do |row_ary, index|
      row = sheet.row(index)
      row.push(*row_ary)
    end
    content = ''
    ios = StringIO.new(content)
    book.write(ios)
    content
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def self.csv_to_xls_file(csv_path, file, separator = ',')
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet

    CSV.open(csv_path, col_sep: separator) do |csv|
      index = 0
      csv.each do |raw_row|
        row = sheet.row(index)
        row.push(*raw_row)
        index += 1
      end
    end

    book.write(file)
    file
  end
  # rubocop:enable Metrics/MethodLength

  # This only strips a <table> out of the html and adds a meta tag for utf-8 support. Excel will open an .xls file
  # with this content and grok it correctly (including formatting); however, many alternate spreadsheet applications
  # will not do this.
  #
  # If the html_content is very large, the default behavior of scanning out the table contents will consume a lot
  # of memory. If the :do_not_strip option is passed, this expensive scan call will be skipped and the entire
  # contents will be returned.
  #
  # If you don't have need of utf-8 encoding, or want to prepend that yourself, there's no need to use this method.
  def self.html_as_xls(html_content, options = {})
    encoding_meta_tag = '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
    encoding_meta_tag + (options.delete(:do_not_strip) ? html_content : html_content.scan(%r{<table.*/table>}mi).join)
  end

  # def self.html_to_xls might be nice to do - convert html table to _real_ xls file
end
