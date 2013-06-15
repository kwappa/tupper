# -*- coding: utf-8 -*-
require "tupper/version"
require 'json'

class Tupper
  DEFAULT_TMP_DIR = File.join(%w{ / tmp tupper })
  SESSION_STORE_KEY = 'tupper_file_info'

  attr_reader :temp_dir, :file_info

  def initialize session
    @session = session

    if @session.is_a? Hash
      json = @session.fetch(SESSION_STORE_KEY, '')
    else
      json = @session.fetch(SESSION_STORE_KEY) || ''
    end

    unless json.empty?
      begin
        @file_info = JSON.parse(json)
      rescue
        @session.delete(SESSION_STORE_KEY)
        raise RuntimeError.new('invalid session data')
      end
    end
  end

  def temp_dir= temp_dir
    FileUtils.mkdir_p temp_dir
    @temp_dir = temp_dir
  end

  def has_uploaded_file?
    @file_info && File.exists?(@file_info.fetch("uploaded_file", ''))
  end

  def upload file_info
    unless @temp_dir
      self.temp_dir = DEFAULT_TMP_DIR
    end

    file_hash = "#{Time.now.to_i}_#{Digest::MD5.hexdigest(file_info[:filename]).slice(0, 8)}"
    uploaded_file = File.join(temp_dir, file_hash + File.extname(file_info[:filename]))
    FileUtils.copy(file_info[:tempfile], uploaded_file)
    tupper_file_info = {
      uploaded_file: uploaded_file,
      original_file: file_info[:filename],
    }.to_json
    @session.store SESSION_STORE_KEY, tupper_file_info
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
