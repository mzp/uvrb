Then /^the output should contain ping pong exchange$/ do
  step %q{the exit status should be 0}
  step %q{the output should contain "sent ping to server"}
  step %q{the output should contain "received pong from server"}
end

Then /^the output should contain consumed workload$/ do
  step %q{the exit status should be 0}
  step %q{the output should contain "received workload"}
end

Given /^a named pipe "(.*?)"$/ do |path|
  if RUBY_PLATFORM.downcase.include?("mswin")
    f = File.open(path, 'w+')
    f.close
  else
    system "/usr/bin/mkfifo", path
  end
  at_exit { File.unlink(path) }
end