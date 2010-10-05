use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;

BEGIN { use_ok("Recs::KeyGroups"); }

use Recs::Record;

#######################  Test KeyGroups::Group ######################

my $group = Recs::KeyGroups::Group->new('!foo!f');
is_deeply($group, {REGEX=>'foo', OPTIONS => { 'full_match'=>undef}}, "Correctly parsed regex + option");

$group->parse_group('!foo!');
is_deeply($group, {REGEX=>'foo', OPTIONS=>{}}, "Correctly parsed regex, nooption");

$group->parse_group('!foo!d=3');
is_deeply($group, {REGEX=>'foo', OPTIONS=>{ depth => 3}}, "Correctly parsed regex, option with value");

$group->parse_group('!foo!d=3!f');
is_deeply($group, {REGEX=>'foo', OPTIONS=>{ depth => 3, 'full_match'=>undef}}, "Correctly parsed regex, multiple options");

my $rec1 = Recs::Record->new(zip_foo => '1', 'zip_bar' => 2, 'foo_bar' => 3);
$group->parse_group('!^zip!');
is_deeply([sort @{$group->get_fields($rec1)}], [qw(zip_bar zip_foo)], "Group finds prefixes");

my $rec2 = Recs::Record->new(zip_foo => '1', 'zip_bar' => 2, 'zip' => {foo=>1});
is_deeply([sort @{$group->get_fields($rec2)}], [qw(zip_bar zip_foo)], "Group finds prefixes, excluding hashes");

my $rec3 = Recs::Record->new(zip_foo => '1', 'zip_bar' => 2, 'zip' => [1]);
is_deeply([sort @{$group->get_fields($rec3)}], [qw(zip_bar zip_foo)], "Group finds prefixes, excluding arrays");

$group->parse_group('!zip!f');
is_deeply([sort @{$group->get_fields($rec2)}], [qw(zip/foo zip_bar zip_foo)], "Group finds nested");

$group->parse_group('!foo!f');
is_deeply([sort @{$group->get_fields($rec2)}], [qw(zip/foo zip_foo)], "Find second level key, and first level");

$group->parse_group('!foo!d=2');
is_deeply([sort @{$group->get_fields($rec2)}], [qw(zip/foo zip_foo)], "Find only second level key");

eval { $group->parse_group('!foo') };
ok($@ =~ m/Malformed group spec/, "error on missing ending !");

eval { $group->parse_group('!foo!blah') };
ok($@ =~ m/Malformed group spec/, "error on bad option");

eval { $group->parse_group('foo!') };
ok($@ =~ m/Malformed group spec/, "error on missing beginning !");

eval { $group->parse_group('foo') };
ok($@ =~ m/Malformed group spec/, "error on missing !s");

#######################  Test KeyGroups ######################

my $key_groups = Recs::KeyGroups->new('!foo!', '!bar!f');

my $expected = {
   KEY_GROUPS => [
      { REGEX   => 'foo', 
        OPTIONS => {} },
      { REGEX   => 'bar', 
        OPTIONS => {'full_match' => undef} },
   ],
};

is_deeply($key_groups, $expected, "Basic Keygroup specification");

my $g_rec1 = Recs::Record->new(zip_foo => '1', 'zip_bar' => 2, 'zip' => {foo=>1});
is_deeply([sort @{$key_groups->get_keyspecs_for_record($g_rec1)}], [qw(zip_bar zip_foo)], "Find with 2 keygroups");

my $kg2 = Recs::KeyGroups->new('@zip/f', '!bar!f');
is_deeply([sort @{$kg2->get_keyspecs_for_record($g_rec1)}], [qw(zip/foo zip_bar)], "Find with 2 keygroups, one a keyspec");
