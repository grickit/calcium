use strict;
use warnings;

package caldoc;

sub new {
  my $self = {};
  my $garbage = shift;
  $self->{'fileName'} = shift;
  open (my $fileHandle, $self->{fileName});
  $self->{'baseContents'} = join("", <$fileHandle>);
  $self->{'unparsedContents'} = '';
  close $fileHandle;

  foreach my $current_line (split(/[\r\n]+/,$self->{baseContents})) {
    $current_line =~ s/^[\s\t]+//;
    if ($current_line =~ /^<cal include="[a-z0-9_.-]+">$/i) {
      $self->{'unparsedContents'} .= $current_line;
    }
    elsif ($current_line =~ /^<cal print="[a-z0-9_.-]+">$/i) {
      $self->{'unparsedContents'} .= $current_line;
    }
    elsif ($current_line =~ /^<cal ([a-z0-9_.-]+)="([a-z0-9_.-]+)">$/i) {
      $self->{$1} = $2;
    }
    else {
      $self->{'unparsedContents'} .= $current_line;
    }
  }

  unless ($self->{'id'}) {
    stopGoing("Document has no id.");
  }

  bless($self);
  return $self;
}

1;