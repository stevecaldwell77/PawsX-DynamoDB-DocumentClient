use strict;
use warnings;
use Test::More;

use Paws::DynamoDB::PutItemOutput;

my $class;
BEGIN {
    $class = 'PawsX::DynamoDB::DocumentClient::Put';
    use_ok($class);
}

is_deeply(
    {
        $class->transform_arguments(
            ConditionExpression => 'create_time < :min_create_time',
            ExpressionAttributeValues => {
                ':min_create_time' => 1499872950,
            },
            Item => {
                user_id => 25,
                create_time => 1499872950,
                email => 'jdoe@example.com',
            },
            TableName => 'users',
        )
    },
    {
        ConditionExpression => 'create_time < :min_create_time',
        ExpressionAttributeValues => {
            ':min_create_time' => { N => 1499872950 },
        },
        Item => {
            user_id => { N => 25 },
            create_time => { N => 1499872950 },
            email => { S => 'jdoe@example.com' },
        },
        TableName => 'users',
    },
    'transform_arguments() marshalls correct args',
);

my $test_output = Paws::DynamoDB::PutItemOutput->new();
is(
    $class->transform_output($test_output),
    undef,
    'nothing returned by default',
);

done_testing;
