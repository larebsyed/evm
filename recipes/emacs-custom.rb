recipe 'emacs-custom' do
  if ARGV.length == 2
    git 'http://git.savannah.gnu.org/r/emacs.git', 'master', ARGV[1]
  else
    git 'http://git.savannah.gnu.org/r/emacs.git', 'master'
  end

  osx do
    option '--with-ns'
    option '--without-x'
    option '--without-dbus'
  end

  linux do
    option '--prefix', installation_path
    option '--without-gif'
  end

  install do
    autogen
    configure
    make 'bootstrap'
    make 'install'

    osx do
      copy File.join(build_path, 'nextstep', 'Emacs.app'), installation_path
    end
  end
end
