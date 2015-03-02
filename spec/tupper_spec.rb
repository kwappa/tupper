require 'bundler'
Bundler.setup(:default, :test)
require 'fakefs/spec_helpers'
require 'tupper'
require 'tupper/errors'

describe Tupper do
  include FakeFS::SpecHelpers

  let(:initialize_json) {
    "{\"tupper_file_info\":\"test\"}"
  }
  let(:collect_json) {
    "{\"uploaded_file\":\"/tmp/tupper/1341556030_54c89662.txt\",\"original_file\":\"dummy_tsv.txt\"}"
  }
  let(:blank_session)      { Hash.new }
  let(:invalid_session)    { { Tupper::SESSION_STORE_KEY => 'invalid session' } }
  let(:collect_session)    { { Tupper::SESSION_STORE_KEY => collect_json } }
  let(:initialize_session) { { Tupper::SESSION_STORE_KEY => initialize_json } }

  describe '#initialize' do
    context 'without session data' do
      let(:tupper) { Tupper.new(blank_session) }
      before { tupper.temp_dir = Tupper::DEFAULT_TMP_DIR }

      it "should create default temporary directory" do
        expect(Dir.exists?(tupper.temp_dir)).to be
        expect(tupper.temp_dir).to eq '/tmp/tupper'
      end

      it "should initialize max_size by default" do
        expect(tupper.max_size).to eq 8
      end
    end

    context 'with invalid session data' do
      specify { expect { Tupper.new(invalid_session) }.to raise_error Tupper::SessionError }
    end

    context 'with valid session data' do
      subject(:file_info) { Tupper.new(collect_session).file_info }
      specify { expect(file_info).to be_an_instance_of Hash }
    end
  end

  describe '#configure' do
    let(:tupper) do
      Tupper.new({}).configure do |tupper|
        tupper.max_size = 16
        tupper.temp_dir = '/tmp/hoge/piyo'
      end
    end

    it 'configures correctly' do
      expect(tupper.max_size).to eq 16
      expect(tupper.temp_dir).to eq '/tmp/hoge/piyo'
      expect(Dir.exists?('/tmp/hoge/piyo')).to be
    end
  end

  describe '#temp_dir=' do
    let(:tupper) { Tupper.new(blank_session) }
    before { tupper.temp_dir = 'hoge' }

    it 'should set property "temp_dir" and create directory' do
      expect(tupper.temp_dir).to eq 'hoge'
      expect(Dir.exists?(tupper.temp_dir)).to be
    end
  end

  describe '#temp_dir' do
    context 'temp_dir is not assigned' do
      subject(:temp_dir) { Tupper.new(blank_session).temp_dir }
      specify { expect(temp_dir).to eq Tupper::DEFAULT_TMP_DIR }
    end
  end

  describe '#upload' do
    let(:test_dir)  { '/tmp' }
    let(:test_file) { File.join(test_dir, 'test_file') }
    let(:tupper)    { Tupper.new(blank_session).configure { |t| t.max_size = 1 } }
    before          { FileUtils.mkdir_p(test_dir) }

    context 'file that smaller than or equal max size was uploaded' do
      before do
        File.open(test_file, 'w') { |f| f.write('*' * 1024 * 1024) }
        tupper.upload(tempfile: test_file, filename: 'dummy.txt')
      end
      specify { expect(tupper).to have_uploaded_file }
    end

    context 'file that lager than max size was uploaded' do
      before do
        File.open(test_file, 'w') { |f| f.write('*' * 1024 * (1024 + 1)) }
      end
      specify { expect { tupper.upload(tempfile: test_file, filename: 'too_large_file.txt') }.to raise_error Tupper::FileSizeError }
    end
  end

  describe '#has_uploaded_file?' do
    context 'before upload' do
      let(:tupper) { Tupper.new(blank_session) }
      specify { expect(tupper).to_not have_uploaded_file }
    end

    context 'has collect session' do
      let(:tupper) { Tupper.new(collect_session) }
      before do
        FileUtils.mkdir_p Tupper::DEFAULT_TMP_DIR
        FileUtils.touch('/tmp/tupper/1341556030_54c89662.txt')
      end
      specify { expect(tupper).to have_uploaded_file }
    end
  end

  describe '#uploaded_file' do
    context 'before upload'do
      subject { Tupper.new(initialize_session).uploaded_file }
      specify { expect(subject).to be_nil }
    end

    context 'has collect session' do
      let!(:tupper) { Tupper.new(collect_session) }
      before do
        FileUtils.mkdir_p Tupper::DEFAULT_TMP_DIR
        FileUtils.touch('/tmp/tupper/1341556030_54c89662.txt')
      end

      specify { expect(tupper.uploaded_file).to eq '/tmp/tupper/1341556030_54c89662.txt' }
    end
  end

  describe '#cleanup' do
    let!(:tupper) { Tupper.new(collect_session) }

    before do
      FileUtils.mkdir_p Tupper::DEFAULT_TMP_DIR
      FileUtils.touch('/tmp/tupper/1341556030_54c89662.txt')
      tupper.cleanup
    end

    it 'should delete uploaded_file and session' do
      expect(tupper.instance_variable_get(:@session)).to_not be_include Tupper::SESSION_STORE_KEY
      expect(File.exists?('/tmp/tupper/1341556030_54c89662.txt')).to_not be
    end
  end
end
