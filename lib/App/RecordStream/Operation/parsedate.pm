use strict;
use warnings;

package App::RecordStream::Operation::parsedate;
use base qw(App::RecordStream::Operation);
use App::RecordStream::KeyGroups;

use Time::ParseDate qw< parsedate >;
use POSIX qw< strftime >;

sub init {
  my $this = shift;
  my $args = shift;

  $this->{'KEYS'} = App::RecordStream::KeyGroups->new;
  $this->{'TIME_FUNC'} = sub { localtime $_[0] };   # \&CORE::localtime doesn't work until 5.16 :(

  # Using a single "now" is important if we're processing a lot of relative
  # dates so that "now" doesn't drift during processing.  time() is the
  # default, anyway.
  $this->{'NOW'} = time;

  my $options = {
    'key|k=s'       => sub { $this->{'KEYS'}->add_groups($_[1]) },
    'format|f=s'    => \($this->{'FORMAT'}),
    'dmy'           => \($this->{'UK'}),
    'past'          => \($this->{'PAST'}),
    'future'        => \($this->{'FUTURE'}),
    'timezone|tz=s' => \($this->{'TIMEZONE'}),
    'relative!'     => \($this->{'RELATIVE'}),
    'now=i'         => \($this->{'NOW'}),
    'localtime'     => sub { $this->{'TIME_FUNC'} = sub { localtime $_[0] } },
    'gmtime'        => sub { $this->{'TIME_FUNC'} = sub {    gmtime $_[0] } },
  };
  $this->parse_options($args, $options);

  die "--key is required\n"    unless $this->{'KEYS'}->has_any_group;
  die "--format is required\n" unless defined $this->{'FORMAT'};
}

sub accept_record {
  my $this   = shift;
  my $record = shift;

  my @values = map { $record->guess_key_from_spec($_) }
    @{ $this->{'KEYS'}->get_keyspecs_for_record($record) };

  for my $date (@values) {
    my $epoch = parsedate(
      $$date,
      WHOLE           => 1,
      VALIDATE        => 1,
      ZONE            => $this->{'TIMEZONE'},
      PREFER_PAST     => $this->{'PAST'},
      PREFER_FUTURE   => $this->{'FUTURE'},
      NO_RELATIVE     => !$this->{'RELATIVE'},
      UK              => $this->{'UK'},
      NOW             => $this->{'NOW'},
    );
    next unless $epoch;
    $$date = strftime($this->{'FORMAT'}, $this->{'TIME_FUNC'}->($epoch))
  }

  $this->push_record($record);
  return 1;
}

sub add_help_types {
  my $this = shift;
  $this->use_help_type('keyspecs');
  $this->use_help_type('keygroups');
  $this->use_help_type('keys');
}

sub usage {
  my $this = shift;
  my $options = [
    ['key|-k <keys>',        'Datetime keys to parse and reformat; may be a key spec or key group.  Required.'],
    ['format|-f <strftime>', 'Format string for strftime(3).  Required.'],
    ['dmy',                  'Assume dd/mm (UK-style) instead of mm/dd (US-style)'],
    ['past',                 'Assume ambiguous years and days of the week are in the past'],
    ['future',               'Assume ambiguous years and days of the week are in the future'],
    ['timezone|tz <zone>',   'Assume ambiguous datetimes are in the given timezone (defaults to the local TZ)'],
    ['relative',             'Try to parse relative dates and times (e.g. 1 hour ago)'],
    ['localtime',            'Output formatted datetimes in localtime (the default)'],
    ['gmtime',               'Output formatted datetimes in GMT'],
    ['now <integer>',        'Set the "current time" for relative datetimes, as seconds since the epoch (rarely needed)'],
  ];
  my $args_string = $this->options_string($options);

  return <<USAGE;
Usage: recs parsedate -k <keys> -f <format> [<options>] [<files>]
   __FORMAT_TEXT__
   Parses the values of the specified keys and reformats them according to the
   specified strftime(3) format string.  Partial dates and times may be parsed.  A
   full list of formats parsed is provided in the documentation for
   Time::ParseDate [1].

   Times without a timezone are parsed in the current TZ, unless otherwise
   specified by --timezone.

   Values that cannot be parsed will be passed through unmodified.

   If using --relative, you probably also want to specify --past or --future,
   otherwise your ambiguous datetimes (e.g. "Friday") won't be parsed.

   [1] https://metacpan.org/pod/Time::ParseDate#DATE-FORMATS-RECOGNIZED
   __FORMAT_TEXT__

Arguments:
$args_string

Examples:
   Normalize dates from a variety of formats to YYYY-MM-DD:
      ... | recs parsedate -k when -f "%Y-%m-%d"
   Convert timestamps in GMT to localtime in an ISO 8601 format:
      ... | recs parsedate -k timestamp -f "%F %T" --tz GMT --localtime
USAGE
}

1;
