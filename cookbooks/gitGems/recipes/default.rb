gitruby = node[:gitRubyLib]
libdir = gitruby[:libdir]
bindir = gitruby[:bindir]
gitdir = gitruby[:gitdir]

#$stdout.puts libdir
#$stdout.puts bindir
#$stdout.puts gitdir

class Chef::Resource::Deploy
      def clear_symlinks
        @symlinks = {}
        @symlink_before_migrate = {}
      end
end
directory libdir do
  recursive true
  action :create
  $stdout.puts libdir
end

directory bindir do
  recursive true
  action :create
end

directory gitdir do
  owner gitruby[:user]
  recursive true
  action :create
end

node[:gitGems].each do |gitgem|
  name = "#{gitdir}/#{gitgem[:name]}"
  directory name do
    action :create
    owner gitruby[:user]
  end
  deploy name do
    clear_symlinks
    repository gitgem[:source]
    user gitruby[:user]
    dest = destination
    syms = {}
    before_symlink do
      d = Dir.new("#{dest}/lib")
      d.each do |filename|
        unless filename =~ /^\./
          syms["#{libdir}/filename"] = "lib/#{filename}"
        end
      end
    end
  end
end

