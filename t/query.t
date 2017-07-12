use strict;
use warnings;
use Test::More;

use Paws::DynamoDB::QueryOutput;

my $class;
BEGIN {
    $class = 'PawsX::DynamoDB::DocumentClient::Query';
    use_ok($class);
}

is_deeply(
    {
        $class->transform_arguments(
        )
    },
    {
    },
    'transform_arguments() marshalls correct args',
);

my $test_output = Paws::DynamoDB::QueryOutput->new();
is(
    $class->transform_output($test_output),
    undef,
    'nothing returned by default',
);

done_testing;
