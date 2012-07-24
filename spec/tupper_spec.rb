# -*- coding: utf-8 -*-
require 'bundler'
Bundler.setup(:default, :test)
require 'fakefs/spec_helpers'
require 'tupper'
require 'tupper/errors'

describe Tupper do
  include FakeFS::SpecHelpers

  let(:collect_json) {
    "{\"uploaded_file\":\"/tmp/tupper/1341556030_54c89662.txt\",\"original_file\":\"dummy_tsv.txt\"}"
  }

  describe '#initialize' do
    context 'without session data' do
      before do
        @tupper = Tupper.new({})
        @tupper.temp_dir = Tupper::DEFAULT_TMP_DIR
      end
      it "should create default temporary directory" do
        Dir.exists?(@tupper.temp_dir).should be_true
        @tupper.temp_dir.should == '/tmp/tupper'
      end
    end

    context 'with invalid session data' do
      specify {
        expect { Tupper.new(Tupper::SESSION_STORE_KEY.to_s => 'invalid json') }
          .to raise_error Tupper::SessionError
      }
    end

    context 'with valid session data' do
      subject { Tupper.new(Tupper::SESSION_STORE_KEY.to_s => collect_json) }
      its(:file_info) { should be_instance_of Hash }
    end
  end

  describe '#temp_dir=' do
    before do
      @tupper = Tupper.new({})
      @tupper.temp_dir = 'hoge'
    end

    it 'should set property "temp_dir" and create directory' do
      @tupper.temp_dir.should == 'hoge'
      Dir.exists?(@tupper.temp_dir).should be_true
    end
  end

  describe '#temp_dir' do
    context 'temp_dir is not assigned' do
      subject { Tupper.new({}) }
      its(:temp_dir) { should == Tupper::DEFAULT_TMP_DIR }
    end
  end

  describe '#has_uploaded_file?' do
    context 'before upload' do
      subject { Tupper.new({}) }
      it { should_not have_uploaded_file }
    end

    context 'has collect session' do
      before do
        @tupper = Tupper.new(Tupper::SESSION_STORE_KEY.to_s => collect_json)
        FileUtils.mkdir_p Tupper::DEFAULT_TMP_DIR
        FileUtils.touch('/tmp/tupper/1341556030_54c89662.txt')
      end
      specify { @tupper.should have_uploaded_file }
    end
  end

  describe '#uploaded_file' do
    context 'before upload'do
      subject { Tupper.new({}) }
      its(:uploaded_file) { should be_nil }
    end

    context 'has collect session' do
      before do
        @tupper = Tupper.new(Tupper::SESSION_STORE_KEY.to_s => collect_json)
        FileUtils.mkdir_p Tupper::DEFAULT_TMP_DIR
        FileUtils.touch('/tmp/tupper/1341556030_54c89662.txt')
      end

      subject { @tupper.uploaded_file }
      it { should == '/tmp/tupper/1341556030_54c89662.txt' }
    end
  end

  describe '#cleanup' do
    before do
      @tupper = Tupper.new(Tupper::SESSION_STORE_KEY.to_s => collect_json)
      FileUtils.mkdir_p Tupper::DEFAULT_TMP_DIR
      FileUtils.touch('/tmp/tupper/1341556030_54c89662.txt')
      @tupper.cleanup
    end

    it 'should delete uploaded_file and session' do
      @tupper.instance_variable_get(:@session).should_not be_include Tupper::SESSION_STORE_KEY
      File.exists?('/tmp/tupper/1341556030_54c89662.txt').should be_false
    end
  end
end
