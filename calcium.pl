use strict;
use warnings;
use FindBin;
use File::Path;
use Cwd;

my $scriptLocation = $FindBin::Bin;
my $guideFileDirectory = ($ARGV[0] or getcwd());
my $guideFileLocation = $guideFileDirectory.'/vitamind';
(-e $guideFileLocation) ? my $guideFile = fileToString($guideFileLocation) : stopGoing("No vitamind found.");
my $documents;

sub fileToString {
  open (my $fileHandle, $_[0]);
  my $file = join("", <$fileHandle>);
  close $fileHandle;
  return $file;
}

sub stopGoing {
  print "$_[0]\n";
  exit;
}

sub getDocumentVariable {
  return $documents->{$_[0]}->{$_[1]};
}

sub preCompile {
  my $self = {};
  $self->{'id'} = shift;
  open (my $fileHandle, $self->{'id'}.'.cal');
  $self->{'baseContents'} = join("", <$fileHandle>);
  $self->{'unparsedContents'} = '';
  close $fileHandle;

  foreach my $current_line (split(/[\r\n]+/,$self->{'baseContents'})) {
    $current_line =~ s/^[\s\t]+//;
    if ($current_line =~ /^<cal include="[a-z0-9_.-]+">$/i) {
      $self->{'unparsedContents'} .= "$current_line\n";
    }
    elsif ($current_line =~ /^<cal print="[a-z0-9_.-]+">$/i) {
      $self->{'unparsedContents'} .= "$current_line\n";
    }
    elsif ($current_line =~ /^<cal ([a-z0-9_-]+)="([a-z0-9_.\/\\-]+)">$/i) {
      $self->{$1} = $2;
    }
    else {
      $self->{'unparsedContents'} .= "$current_line\n";
    }
  }
  return $self;
}

sub pageCompile {
  my $self = shift;

  $self->{'Contents'} = '';
  $documents->{'parent'} = $self;
  foreach my $current_line (split(/[\r\n]+/,$self->{'unparsedContents'})) {
    $current_line =~ s/^[\s\t]+//;
    if ($current_line =~ /^<cal include="([a-z0-9_.-]+)">$/i) {
      print "Including $1\n";
      $self->{'Contents'} .= resourceCompile($documents->{$1})."\n";
    }
    else {
      $self->{'Contents'} .= "$current_line\n";
    }
  }
  delete $documents->{'parent'};
  return $self;
}

sub resourceCompile {
  my $self = shift;

  $self->{'Contents'} = '';
  foreach my $current_line (split(/[\r\n]+/,$self->{'unparsedContents'})) {
    $current_line =~ s/^[\s\t]+//;
    if ($current_line =~ /^<cal print="([a-z0-9_-]+)\.([a-z0-9_-]+)">$/i) {
      print "Printing $1.$2\n";
      $self->{'Contents'} .= getDocumentVariable($1,$2)."\n";
    }
    else {
      $self->{'Contents'} .= "$current_line\n";
    }
  }
  return $self->{'Contents'};
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
    stopGoing("Invalid command found in guide file \"$guideFileLocation\".");
  }
}

sub compileCommand {
  while (my ($key, $value) = each %{$documents}) {
    if ($documents->{$key}->{'location'}) {
      $documents->{$key} = pageCompile($value);
      print $documents->{$key}->{'Contents'};
    }
  }
}

sub dirCommand {
  mkpath($_[0]) unless(-d $_[0]);
}

sub loadCommand {
  $documents->{$_[0]} = preCompile($guideFileDirectory.$_[0]);
}


foreach my $current_line (split(/[\r\n]+/,$guideFile)) {
  print "$current_line\n";
  parseCommand($current_line);
}