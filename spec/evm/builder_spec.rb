require 'spec_helper'

describe Evm::Builder do
  describe Evm::Builder::Dsl do
    before do
      @dsl = Evm::Builder::Dsl.new
    end

    describe '#tar_gz' do
      it 'should download and extract tar' do
        tar_file = double('tar_file')
        tar_file.should_receive(:download!)
        tar_file.should_receive(:extract!)

        Evm::TarFile.should_receive(:new).with('foo.tar.gz').and_return(tar_file)

        @dsl.tar_gz('foo.tar.gz')
      end
    end

    describe '#osx' do
      it 'should yield if osx' do
        Evm::Os.stub(:osx?).and_return(true)

        expect { |block|
          @dsl.osx(&block)
        }.to yield_control
      end

      it 'should not yield if not osx' do
        Evm::Os.stub(:osx?).and_return(false)

        expect { |block|
          @dsl.osx(&block)
        }.not_to yield_control
      end
    end

    describe '#linux' do
      it 'should yield if linux' do
        Evm::Os.stub(:linux?).and_return(true)

        expect { |block|
          @dsl.linux(&block)
        }.to yield_control
      end

      it 'should not yield if not linux' do
        Evm::Os.stub(:linux?).and_return(false)

        expect { |block|
          @dsl.linux(&block)
        }.not_to yield_control
      end
    end

    describe '#option' do
      it 'should add option without value' do
        @dsl.option '--foo'
        @dsl.instance_variable_get('@options').should =~ ['--foo']
      end

      it 'should add option with value' do
        @dsl.option '--foo', 'bar'
        @dsl.instance_variable_get('@options').should =~ ['--foo', 'bar']
      end

      it 'should add multiple options' do
        @dsl.option '--foo'
        @dsl.option '--foo', 'bar'
        @dsl.option '--bar', 'baz'
        @dsl.option '--qux'
        @dsl.instance_variable_get('@options').should =~
          ['--foo', '--foo', 'bar', '--bar', 'baz', '--qux']
      end
    end

    describe '#install' do
      it 'should yield' do
        expect { |block|
          @dsl.install(&block)
        }.to yield_control
      end
    end

    describe '#configure' do
      it 'should configure when no options' do
        @dsl.should_receive(:run_command).with('./configure')
        @dsl.configure
      end

      it 'should configure when single option' do
        @dsl.should_receive(:run_command).with('./configure', '--foo', 'bar')
        @dsl.option '--foo', 'bar'
        @dsl.configure
      end

      it 'should configure when multiple options' do
        @dsl.should_receive(:run_command).with('./configure', '--foo', 'bar', '--baz')
        @dsl.option '--foo', 'bar'
        @dsl.option '--baz'
        @dsl.configure
      end
    end

    describe '#make' do
      it 'should run make command with target' do
        @dsl.should_receive(:run_command).with('make', 'foo')
        @dsl.make('foo')
      end
    end

    describe '#build_path' do
      it 'should return package build path' do
        @dsl.recipe 'name' do
          @dsl.build_path.to_s.should == '/usr/local/evm/tmp/name'
        end
      end
    end

    describe '#installation_path' do
      it 'should return package installation path' do
        @dsl.recipe 'name' do
          @dsl.installation_path.to_s.should == '/usr/local/evm/name'
        end
      end
    end

    describe '#platform_name' do
      it 'should platform name' do
        Evm::Os.stub(:platform_name).and_return(:foo)

        @dsl.platform_name.should == :foo
      end
    end

    describe '#copy' do
      it 'should copy recursively' do
        FileUtils.should_receive(:cp_r).with('from', 'to')

        @dsl.copy 'from', 'to'
      end
    end
  end
end
