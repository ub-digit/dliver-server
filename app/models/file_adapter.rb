class FileAdapter
  def self.create_thumbnail(source_file:, destination_file:, format:)
    path = Pathname.new(source_file)
    filename = path.basename('.*')
    img = MiniMagick::Image.open(source_file)
    img.resize("#{format}x")
    img.format("jpg")
    img.write(destination_file)
  end
end
