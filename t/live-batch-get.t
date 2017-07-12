use Test::DescribeMe qw(author);
use Test::Fatal;
use Test::More;
use strict;
use warnings;

use PawsX::DynamoDB::DocumentClient;

my $table_name = $ENV{TEST_DYNAMODB_TABLE}
    || die "please set TEST_DYNAMODB_TABLE";

my $dynamodb = PawsX::DynamoDB::DocumentClient->new();

my %args = (
);

my $output;
is(
    exception {
        $output = $dynamodb->batch_get(%args);
    },
    undef,
    'batch_get() lives',
);
is($output, undef, 'no output by default');

done_testing;
