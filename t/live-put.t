use Test::DescribeMe qw(author);
use Test::Fatal;
use Test::More;
use strict;
use warnings;

use PawsX::DynamoDB::DocumentClient;
use UUID::Tiny ':std';

my $table_name = $ENV{TEST_DYNAMODB_TABLE}
    || die "please set TEST_DYNAMODB_TABLE";

my $dynamodb = PawsX::DynamoDB::DocumentClient->new();

my %args = (
    TableName => $table_name,
    Item => {
        user_id => create_uuid_as_string(),
        email => 'jdoe@example.com',
    },
);

my $output;
is(
    exception {
        $output = $dynamodb->put(%args);
    },
    undef,
    'put() lives',
);

done_testing;
