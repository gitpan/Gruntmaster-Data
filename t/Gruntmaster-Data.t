#!/usr/bin/perl -w
use v5.14;

use Test::More;
BEGIN {
	plan skip_all => '$ENV{RUN_TESTS} is false, skipping tests' unless $ENV{RUN_TESTS};
	plan tests => 1;
}

BEGIN { use_ok('Gruntmaster::Data') };
