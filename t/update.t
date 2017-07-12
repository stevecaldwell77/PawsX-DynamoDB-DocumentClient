use strict;
use warnings;
use Test::More;

use Paws::DynamoDB::UpdateItemOutput;

my $class;
BEGIN {
    $class = 'PawsX::DynamoDB::DocumentClient::Update';
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

my $test_output = Paws::DynamoDB::UpdateItemOutput->new();
is(
    $class->transform_output($test_output),
    undef,
    'nothing returned by default',
);

done_testing;
