use strict;
use warnings;
use Test::More;

use Paws::DynamoDB::BatchWriteItemOutput;

my $class;
BEGIN {
    $class = 'PawsX::DynamoDB::DocumentClient::BatchWrite';
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

my $test_output = Paws::DynamoDB::BatchWriteItemOutput->new();
is(
    $class->transform_output($test_output),
    undef,
    'nothing returned by default',
);

done_testing;
