use strict;
use warnings;
use FindBin;
use File::Path;

my $scriptLocation = $FindBin::Bin;
my $guideFileLocation = $ARGV[0] or die "No guide file specified.";
my $guideFile = fileToString($guideFileLocation);

sub fileToString {
  open (my $fileHandle, $_[0]);
  my $file = join("", <$fileHandle>);
  close $fileHandle;
  return $file;
}

sub parseCommand {
  if ($_[0] =~ /^dir ([a-z0-9_.-]+)$/i) {
    dirCommand($1);
  }
  elsif ($_[0] =~ /^load ([a-z0-9_.-]+)$/i) {
    loadCommand($1);
  }
  elsif ($_[0] =~ /^compile$/) {
    compileCommand();
  }
  else {
    die "Invalid command found in guide file \"$guideFileLocation\"";
  }
}

sub compileCommand {

}

sub dirCommand {
  mkpath($_[0]) unless(-d $_[0]);
}

sub loadCommand {

}

foreach my $current_line (split(/[\r\n]+/,$guideFile)) {
  print "$current_line\n";
  parseCommand($current_line);
}