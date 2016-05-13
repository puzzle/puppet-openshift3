require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_blacksmith'
require "highline/import"

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

def metadata
  @metadata ||= Blacksmith::Modulefile.new
end

def metadata_reload
  @metadata = Blacksmith::Modulefile.new
end

def git
  @git ||= Blacksmith::Git.new
end

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

task :spec_prep do
  sh('bundle exec librarian-puppet install --path spec/fixtures/modules')
  pwd = Dir.pwd.strip
  unless File.exists?("#{pwd}/spec/fixtures/modules/#{metadata.name}")
    sh("ln -s #{pwd} #{pwd}/spec/fixtures/modules/#{metadata.name}")
  end
end

task :spec_clean do
  sh('rm -rf spec/fixtures/modules/*')
end

namespace :module do
  desc 'bump the module version'
  task :bump do
    level = :patch
    level = :minor if agree('Did you add new features?')
    level = :major if agree('Did you change the API so code who uses this module needs to change?')
    if agree("The selected level for the realease is '#{level.to_s}'. Do you agree?")
      new_version = metadata.send("bump_#{level}!")
      git.commit_modulefile!(new_version)
      say("Bumping version from #{metadata.version} to #{new_version}")
    else
      say('canceling release')
      exit -1
    end
  end

  desc 'clear the tag'
  task :clear_tag do
    metadata_reload
    git.exec_git("tag --delete v#{metadata.version}")
    git.exec_git("push origin :refs/tags/v#{metadata.version}")
    say("removing git tag v#{metadata.version}")
  end

  desc 'tag the release'
  task :tag do
    metadata_reload
    git.tag_pattern = "v%s"
    git.tag!(metadata.version)
    say("taging git revision with v#{metadata.version}")
  end

  desc 'push the new release and trigger the build'
  task :push do
    git.push!
  end
end

desc 'release the puppet module to the internal forge (bump, tag and push)'
task :release => ['module:bump', 'module:tag', 'module:push']

desc 're-release the puppet module in case the build failed (clear_tag, tag and push)'
task :rerelease => ['module:clear_tag', 'module:tag', 'module:push']

task :default => :release_checks
