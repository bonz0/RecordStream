use strict;
use warnings;

use Test::More;
use App::RecordStream::Test::OperationHelper;
use App::RecordStream::Operation::parsedate;

BEGIN {
  # Normalize localtime for testing
  $ENV{TZ} = 'US/Pacific';
}

# These tests aim to exercise the interplay of recs-provided options to
# parsedate to ensure they're working correctly, not test Time::ParseDate's
# functionality which is proven elsewhere.

subtest 'Timezones' => sub {
  my @args = qw[ -k when --format %T ];

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@args, qw[ --localtime ]],
    '{"when":"Feb 23 21:51:47 2016"}',
    '{"when":"21:51:47"}',
    "Feb 23 21:51:47 2016 (assuming \$ENV{TZ} = $ENV{TZ}) is 21:51:47 PST",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@args, qw[ --gmtime ]],
    '{"when":"Feb 23 21:51:47 2016"}',
    '{"when":"05:51:47"}',
    "Feb 23 21:51:47 2016 (assuming \$ENV{TZ} = $ENV{TZ}) is 05:51:47 UTC",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@args, qw[ --tz UTC --localtime ]],
    '{"when":"Feb 23 21:51:47 2016"}',
    '{"when":"13:51:47"}',
    "Feb 23 21:51:47 2016 (with --tz UTC) is 13:51:47 PST",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@args, qw[ --tz UTC --gmtime ]],
    '{"when":"Feb 23 21:51:47 2016"}',
    '{"when":"21:51:47"}',
    "Feb 23 21:51:47 2016 (with --tz UTC) is 21:51:47 UTC",
  );
};

subtest 'MDY vs DMY' => sub {
  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [qw[ -k when --format %F ]],
    '{"when":"10/5/2015"}',
    '{"when":"2015-10-05"}',
    "10/5/2015 is 2015-10-05",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [qw[ -k when --format %F --dmy ]],
    '{"when":"10/5/2015"}',
    '{"when":"2015-05-10"}',
    "10/5/2015 is 2015-05-10 with --dmy",
  );
};

subtest '--relative: Friday' => sub {
  my @relative = qw[ --relative -k when --format %F --now 1456293091 ]; # Tue Feb 23 21:51:47 PST 2016

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@relative],
    '{"when":"friday"}',
    '{"when":"friday"}',
    "Friday is Friday without --future or --past",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@relative, "--future"],
    '{"when":"friday"}',
    '{"when":"2016-02-26"}',
    "Friday is 2016-02-26 with --future",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@relative, "--past"],
    '{"when":"friday"}',
    '{"when":"2016-02-19"}',
    "Friday is 2016-02-19 with --past",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@relative, "--future", "--gmtime"],
    '{"when":"friday"}',
    '{"when":"2016-02-27"}',
    "Friday is 2016-02-27 with --future --gmtime",
  );
};

subtest '--relative: +2d' => sub {
  my @relative = qw[ --relative -k when --format %F --now 1456293091 ]; # Tue Feb 23 21:51:47 PST 2016

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@relative],
    '{"when":"+2 days"}',
    '{"when":"2016-02-25"}',
    "Friday is 2016-02-25 without --future or --past",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@relative, "--future"],
    '{"when":"+2 days"}',
    '{"when":"2016-02-25"}',
    "Friday is 2016-02-25 with --future",
  );

  App::RecordStream::Test::OperationHelper->do_match(
    'parsedate',
    [@relative, "--past"],
    '{"when":"+2 days"}',
    '{"when":"2016-02-25"}',
    "Friday is 2016-02-25 with --past",
  );
};

done_testing;
