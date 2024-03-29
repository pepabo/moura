# frozen_string_literal: true

require_relative "lib/moura/version"

Gem::Specification.new do |spec|
  spec.name = "moura"
  spec.version = Moura::VERSION
  spec.authors = ["Yuki Koya"]
  spec.email = ["ykky@pepabo.com"]

  spec.summary = "Management tool for Onelogin resources."
  spec.description = spec.summary
  spec.homepage = "https://github.com/pepabo/moura/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hashdiff", "~> 1.0.1"
  spec.add_dependency "onelogin", "~> 3.0.0.pre.alpha.1"
  spec.add_dependency "thor", "~> 1.2", ">= 1.2.1"
end
