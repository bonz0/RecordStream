package #
Date::Manip::TZ::afniam00;
# Copyright (c) 2008-2014 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# This file was automatically generated.  Any changes to this file will
# be lost the next time 'tzdata' is run.
#    Generated on: Thu Aug 21 13:06:09 EDT 2014
#    Data version: tzdata2014f
#    Code version: tzcode2014f

# This module contains data from the zoneinfo time zone database.  The original
# data was obtained from the URL:
#    ftp://ftp.iana.org/tz

use strict;
use warnings;
require 5.010000;

our (%Dates,%LastRule);
END {
   undef %Dates;
   undef %LastRule;
}

our ($VERSION);
$VERSION='6.47';
END { undef $VERSION; }

%Dates         = (
   1    =>
     [
        [ [1,1,2,0,0,0],[1,1,2,0,8,28],'+00:08:28',[0,8,28],
          'LMT',0,[1911,12,31,23,51,31],[1911,12,31,23,59,59],
          '0001010200:00:00','0001010200:08:28','1911123123:51:31','1911123123:59:59' ],
     ],
   1911 =>
     [
        [ [1911,12,31,23,51,32],[1911,12,31,22,51,32],'-01:00:00',[-1,0,0],
          'WAT',0,[1934,2,26,0,59,59],[1934,2,25,23,59,59],
          '1911123123:51:32','1911123122:51:32','1934022600:59:59','1934022523:59:59' ],
     ],
   1934 =>
     [
        [ [1934,2,26,1,0,0],[1934,2,26,1,0,0],'+00:00:00',[0,0,0],
          'GMT',0,[1959,12,31,23,59,59],[1959,12,31,23,59,59],
          '1934022601:00:00','1934022601:00:00','1959123123:59:59','1959123123:59:59' ],
     ],
   1960 =>
     [
        [ [1960,1,1,0,0,0],[1960,1,1,1,0,0],'+01:00:00',[1,0,0],
          'WAT',0,[9999,12,31,0,0,0],[9999,12,31,1,0,0],
          '1960010100:00:00','1960010101:00:00','9999123100:00:00','9999123101:00:00' ],
     ],
);

%LastRule      = (
);

1;
