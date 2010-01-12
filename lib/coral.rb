require 'pathname'

module Coral
  # a coral reef is a place where repositories are kept
  LocalReef = Pathname.new(ENV['CORALREEF'] || "#{ENV['HOME']}/.coral").expand_path
  
  autoload :Runner, 'coral/runner'
  autoload :Repository, 'coral/repository'
  autoload :Index, 'coral/index'
  
  def self.index
    @index ||= Index.new LocalReef
  end
  
  def self.find(name, version = nil)
    index.find_repo(name, version)
  end
  
  def self.list(pattern)
    keys = Coral.index.keys
    keys = keys.grep(/^#{pattern}/) if pattern
    
    for name in keys.sort
      yield name, Coral.index[name]
    end
  end
  
  class LoadError < ::LoadError
  end
  
  def self.activate(repo)
    repo = find(repo) if String === repo
    libdir = LocalReef + repo.path + 'lib'
    
    unless libdir.directory?
      raise Coral::LoadError, "Directory #{libdir.to_s.inspect} not found"
    end
    $LOAD_PATH.unshift libdir.to_s
  end
end

unless 'coral' == File.basename($0)
  require 'coral/custom_require'
end

if ENV['CORAL']
  ENV['CORAL'].split(',').each { |name| Coral.activate(name) }
end
