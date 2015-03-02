require_relative "tupper/version"
require_relative "tupper/errors"
require 'json'

class Tupper
  DEFAULT_TMP_DIR   = File.join(%w{ / tmp tupper })
  DEFAULT_MAX_SIZE  = 8         # MB
  SESSION_STORE_KEY = 'tupper_file_info'

  attr_reader   :temp_dir, :file_info
  attr_accessor :max_size

  def initialize session
    @max_size = DEFAULT_MAX_SIZE
    @session = session
    if @session.has_key?(SESSION_STORE_KEY)
      json = @session.fetch(SESSION_STORE_KEY)
    else
      json = ''
    end

    unless json.empty?
      begin
        @file_info = JSON.parse(json)
      rescue
        @session.delete(SESSION_STORE_KEY)
        raise Tupper::SessionError.new('invalid session data')
      end
    end
  end

  def configure &block
    yield self
    self
  end

  def temp_dir= temp_dir
    FileUtils.mkdir_p temp_dir
    @temp_dir = temp_dir
  end

  def temp_dir
    @temp_dir || DEFAULT_TMP_DIR
  end

  def has_uploaded_file?
    @file_info && File.exists?(@file_info.fetch("uploaded_file", ''))
  end

  def upload file_info
    unless @temp_dir
      self.temp_dir = DEFAULT_TMP_DIR
    end

    if (file_size = File.size(file_info[:tempfile])) > max_size * 1024 * 1024
      cleanup
      raise FileSizeError.new("Uploaded file was too large. uploaded_size: #{file_size} bytes / max_size: #{max_size} MB")
    end

    file_hash = "#{Time.now.to_i}_#{Digest::MD5.hexdigest(file_info[:filename]).slice(0, 8)}"
    uploaded_file = File.join(temp_dir, file_hash + File.extname(file_info[:filename]))
    FileUtils.cp(file_info[:tempfile], uploaded_file)
    @file_info = {
      'uploaded_file' => uploaded_file,
      'original_file' => file_info[:filename],
    }
    @session[SESSION_STORE_KEY] = @file_info.to_json
  end

  def uploaded_file
    (@file_info || {}).fetch('uploaded_file', nil)
  end

  def original_file
    (@file_info || {}).fetch('original_file', nil)
  end

  def cleanup
    File.unlink uploaded_file if has_uploaded_file?
    @session.delete SESSION_STORE_KEY
    @file_info = nil
  end
end
