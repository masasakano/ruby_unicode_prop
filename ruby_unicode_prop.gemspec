# -*- encoding: utf-8 -*-

require 'rake'
require 'date'

Gem::Specification.new do |s|
  s.name = %q{ruby_unicode_prop}.sub(/.*/){|c| (c == File.basename(Dir.pwd)) ? c : raise("ERROR: s.name=(#{c}) in gemspec seems wrong!")}
  s.version = "1.0.2".sub(/.*/){|c| fs = Dir.glob('changelog', File::FNM_CASEFOLD); raise('More than one ChangeLog exist!') if fs.size > 1; warn("WARNING: Version(s.version=#{c}) already exists in #{fs[0]} - ok?") if fs.size == 1 && !IO.readlines(fs[0]).grep(/^\(Version: #{Regexp.quote c}\)$/).empty? ; c }  # n.b., In macOS, changelog and ChangeLog are identical in default.
  # s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.bindir = 'bin'
  %w(ruby_unicode_prop).each do |f|
    path = s.bindir+'/'+f
    File.executable?(path) ? s.executables << f : raise("ERROR: Executable (#{path}) is not executable!")
  end

  s.authors = ["Masa Sakano"]
  s.date = %q{2019-11-12}.sub(/.*/){|c| (Date.parse(c) == Date.today) ? c : raise("ERROR: s.date=(#{c}) is not today!")}
  s.summary = %q{Command to print the characters and hex-codepoints for the given Unicode properties}
  s.description = <<-EOF
    This module contains a Ruby executable script to print all the characters and/or hex-codepoints for the given Unicode properties.  "--help" option prints the summary of the options.
  EOF
  # s.email = %q{abc@example.com}
  s.extra_rdoc_files = [
     #"LICENSE.txt",
     "README.en.rdoc",
  ]
  s.license = 'MIT'
  s.files = FileList['.gitignore','lib/**/*.rb','[A-Z]*','test/**/*.rb', '*.gemspec', 'bin'].to_a.delete_if{ |f|
    ret = false
    arignore = IO.readlines('.gitignore')
    arignore.map{|i| i.chomp}.each do |suffix|
      if File.fnmatch(suffix, File.basename(f))
        ret = true
        break
      end
    end
    ret
  }
  s.files.reject! { |fn| File.symlink? fn }

  # s.add_runtime_dependency 'rails', '>= 5.0'
  s.add_development_dependency "plain_text", [">= 0.6"]
  s.homepage = %q{https://www.wisebabel.com}
  s.rdoc_options = ["--charset=UTF-8"]

  # s.require_paths = ["lib"]	# Default "lib"
  s.required_ruby_version = '>= 2.0'
  s.test_files = Dir['test/**/*.rb']
  s.test_files.reject! { |fn| File.symlink? fn }

  # s.requirements << 'libmagick, v6.0' # Simply, info to users.
  # s.rubygems_version = %q{1.3.5}      # This is always set automatically!!

  s.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.
  ## cf. https://guides.rubygems.org/specification-reference/#metadata
  ## nb. If you enable any of thse (even changelog only), the Documenatation tag
  ##   in RubyGems.org will disappear in that version!
  # s.metadata["changelog_uri"]     = "https://github.com/masasakano/#{s.name}/blob/master/ChangeLog"
  # s.metadata["source_code_uri"]   = "https://github.com/masasakano/#{s.name}"
  # s.metadata["documentation_uri"] = "https://www.example.info/gems/bestgemever/0.0.1"
end

