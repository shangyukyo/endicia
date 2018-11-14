module Endicia
  class Label
    attr_reader :postage, :images

    def initialize(response, label_specification = {})
      @response = response
      @label_specification = label_specification
      raise @response["ErrorMessage"] if @response.key?("ErrorMessage")
      @images = Array(@response['Base64LabelImage'] || @response['Label']['Image'])

      if @response['Label'].present?
        @postage = @response.except('Label')
      else
        @postage = @response.except('Base64LabelImage')
      end

      save_images(filepath)
    end

    def name(index = 0)
      filename = tracking_number
      filename += "_#{index}" unless index.zero?
      filename += ".#{format}"
      filename
    end

    def filepath
      @label_specification[:filepath]
    end

    def tracking_number
      @postage["TrackingNumber"]
    end

    def format
      @label_specification[:image_format].downcase
    end

    def save_images(path)
      return if @images.blank?
      files = []

      @images.each_with_index do |img, i|
        full_path = "#{path}_#{name(i)}"
        img = Base64.decode64(img)
        File.open(full_path, 'wb') do|f|
          f.write(img)
        end
        files << full_path
      end
    end
  end
end
