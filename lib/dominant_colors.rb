class DominantColors
  attr_accessor :options
  attr_reader :image_path

  def initialize(image_path, options={})
    @image_path = image_path

    default_options = {
      gm: `which gm`.strip || '/usr/bin/gm',
      colors: 8,
      resize: '200x200',
      colorspace: 'RGB'
    }
    @options = default_options.merge(options)
  end

  def output
    output = `#{options[:gm]} convert #{image_path} -resize #{options[:resize]} +dither -colorspace #{options[:colorspace]} -colors #{options[:colors]} histogram:- | #{options[:gm]} convert - -format "%c" info:-`
    output.force_encoding('binary')
  end

  def raw_results
    @raw_results ||= output.scan(/(\d*):.*(#[0-9A-Fa-f]*)/).map { |m| [m[0].to_i, m[1]] }
  end

  def results
    @results ||= begin
      total = raw_results.map(&:first).inject(:+).to_f
      raw_results.map do |match|
        [match[0] / total, Color::RGB.from_html(match[1][0..6])]
      end
    end
  end
end
