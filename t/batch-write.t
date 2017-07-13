use strict;
use warnings;
use Test::More;

use aliased 'Paws::DynamoDB::BatchWriteItemOutput';
use aliased 'Paws::DynamoDB::BatchWriteItemRequestMap';
use aliased 'Paws::DynamoDB::PutItemInputAttributeMap';
use aliased 'Paws::DynamoDB::WriteRequest';
use aliased 'Paws::DynamoDB::PutRequest';
use aliased 'Paws::DynamoDB::DeleteRequest';
use PawsX::DynamoDB::DocumentClient::Util qw(make_attr_map make_key);

my $class;
BEGIN {
    $class = 'PawsX::DynamoDB::DocumentClient::BatchWrite';
    use_ok($class);
}

sub make_put_request {
    my ($attrs) = @_;
    my $attr_map = make_attr_map($attrs);
    my $put_attr_map = PutItemInputAttributeMap->new(Map => $attr_map->Map);
    return WriteRequest->new(
        PutRequest => PutRequest->new(
            Item => $put_attr_map,
        ),
    );
}

sub make_delete_request {
    my ($key) = @_;
    return WriteRequest->new(
        DeleteRequest => DeleteRequest->new(
            Key => make_key($key),
        ),
    );
}

is_deeply(
    {
        $class->transform_arguments(
            RequestItems => {
                'friends' => [
                    {
                        PutRequest => {
                            Item => { user_id => 100, friend_id => 101 },
                        },
                    },
                    {
                        PutRequest => {
                            Item => { user_id => 100, friend_id => 102 },
                        },
                    },
                    {
                        DeleteRequest => {
                            Key => { user_id => 100, friend_id => 200 },
                        },
                    },
                ],
                'user' => [
                    {
                        PutRequest => {
                            Item => { user_id => 101, name => 'Johnny' },
                        },
                    },
                ],
            },
            ReturnConsumedCapacity => 'NONE',
        ),
    },
    {
        RequestItems => {
            'friends' => [
                {
                    PutRequest => {
                        Item => {
                            user_id => { N => 100 },
                            friend_id => { N => 101 },
                        },
                    },
                },
                {
                    PutRequest => {
                        Item => {
                            user_id => { N => 100 },
                            friend_id => { N => 102 },
                        },
                    },
                },
                {
                    DeleteRequest => {
                        Key => {
                            user_id => { N => 100 },
                            friend_id => { N => 200 },
                        },
                    },
                },
            ],
            'user' => [
                {
                    PutRequest => {
                        Item => {
                            user_id => { N => 101 },
                            name => { S => 'Johnny' },
                        },
                    },
                },
            ],
        },
        ReturnConsumedCapacity => 'NONE',
    },
    'transform_arguments() marshalls correct args',
);

my $test_output = BatchWriteItemOutput->new(
    UnprocessedItems => BatchWriteItemRequestMap->new(
        Map => {
            'friends' => [
                make_put_request({
                    user_id => { N => 100 },
                    friend_id => { N => 102 },
                }),
                make_put_request({
                    user_id => { N => 100 },
                    friend_id => { N => 103 },
                }),
            ],
            'user' => [
                make_delete_request({
                    user_id => { N => 100 },
                }),
            ],
        },
    ),
);

is_deeply(
    $class->transform_output($test_output),
    {
        'friends' => [
            {
                PutRequest => {
                    Item => { user_id => 100, friend_id => 102 },
                },
            }, {
                PutRequest => {
                    Item => { user_id => 100, friend_id => 103 },
                },
            },
        ],
        'user' => [
            {
                DeleteRequest => {
                    Key => { user_id => 100 },
                },
            },
        ],
    },
    'unprocessed items returned',
);

done_testing;
