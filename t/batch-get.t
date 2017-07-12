use strict;
use warnings;
use Test::More;

use Paws::DynamoDB::BatchGetItemOutput;

my $class;
BEGIN {
    $class = 'PawsX::DynamoDB::DocumentClient::BatchGet';
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

my $test_output = Paws::DynamoDB::BatchGetItemOutput->new();
is(
    $class->transform_output($test_output),
    undef,
    'nothing returned by default',
);

done_testing;
