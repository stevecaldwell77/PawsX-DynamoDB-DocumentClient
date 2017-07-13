# NAME

PawsX::DynamoDB::DocumentClient - a simplified way of working with AWS DynamoDB items that uses Paws under the hood.

# SYNOPSIS

    use PawsX::DynamoDB::DocumentClient;

    my $dynamodb = PawsX::DynamoDB::DocumentClient->new();

    $dynamodb->put(
        TableName => 'users',
        Item => {
            user_id => 24,
            email => 'bob@example.com',
            roles => ['admin', 'finance'],
        },
    );

    my $user = $dynamodb->get(
        TableName => 'users',
        Key => {
            user_id => 24,
        },
    );

# DESCRIPTION

Paws (in this author's opinion) is the best and most up-to-date way of working with AWS. However, reading and writing DynamoDB items via Paws' low-level API calls can involve a lot of busy work formatting your data structures to include DynamoDB types.

This module simplifies some DynamoDB operations by automatically converting back and forth between simpler Perl data structures and the request/response data structures used by Paws.

For more information about how types are mananged, see [Net::Amazon::DynamoDB::Marshaler](https://metacpan.org/pod/Net::Amazon::DynamoDB::Marshaler).

This module is based on a similar class in the [AWS JavaScript SDK](http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/DynamoDB/DocumentClient.html).

## outputs

By default, the methods below return plain values (or nothing) that make normal use cases simpler, as opposed to the output objects that Paws generates. For example, get() returns a hashref of the item's data, as opposed to a [Paws::DynamoDB::GetItemOutput](https://metacpan.org/pod/Paws::DynamoDB::GetItemOutput) object.

For use cases where you need more extensive output data, every method supports a return\_paws\_output flag, which will return the Paws object instead.

    my $item = $dynamodb->get(
        TableName => 'users',
        Key => {
            user_id => 1000,
        },
    );
    # $item looks like { user_id => 1000, email => 'foo@bar.com', ... }

    my $output = $dynamodb->get(
        TableName => 'users',
        Key => {
            user_id => 1000,
        },
        return_paws_output => 1,
    );
    # $output isa Paws::DynamoDB::GetItemOutput

# METHODS

## new

    my $dynamodb = PawsX::DynamoDB::DocumentClient->new(
        region => 'us-east-1',
    );

This class method returns a new PawsX::DynamoDB::DocumentClient object. It accepts the following parameters:

### paws

A Paws object to use to create the Paws::DynamoDB service object. Optional. Available in case you need to custom configuration of Paws (e.g. authentication).

### dynamodb

Alternatively, you can provide a Paws::DynamoDB service object directly if you have one. Optional. If given, the 'paws' parameter will be ignored.

### region

The AWS region to use when creating the Paws::DynamoDB service object. If not specified, will try to grab from the AWS\_DEFAULT\_REGION	environment variable. Will be ignored if the object is constructed with a dynamodb object, or with a paws object that has a region configured.

If the constructor can't figure out what region to use, an error will be thrown.

## batch\_get

    my $result = $dynamodb->batch_get(
        RequestItems => {
            $table_name => {
                Keys => [
                    { user_id => 1000 },
                    { user_id => 1001 },
                ],
            },
        },
    );

Returns the attributes of one or more items from one or more tables by delegating to [Paws::DynamoDB::BatchGetItem](https://metacpan.org/pod/Paws::DynamoDB::BatchGetItem).

The following arguments are marshalled: values in 'RequestItems.$table\_name.Keys'.

By default (return\_paws\_output not set), returns a hashref that looks like:

    {
        responses => {
            $table_name => [
                {...} # unmarshalled item
                ...
            ],
        },
        unprocessed_keys => {
            $table_name => {
                Keys => [
                    { ... }, # unmarshalled key
                    ...
                ],
                ProjectionExpression => '...',
                ConsistentRead => $boolean,
            }
        }
    }

unprocessed\_keys can be fed back into a new call to batch\_get(). See [Paws::DynamoDB::BatchGetItemOutput](https://metacpan.org/pod/Paws::DynamoDB::BatchGetItemOutput) for more infomation.

## batch\_write

    my $result = $dynamodb->batch_write(
        RequestItems => {
            $table_name => [
                {
                    PutRequest => {
                        Item => {
                            user_id => 1000,
                            email => 'jdoe@example.com',
                        },
                    },
                },
                {
                    DeleteRequest => {
                        Key => {
                            user_id => 1001,
                        },
                    },
                },
            ],
        },
    );

Puts or deletes multiple items in one or more tables by delegating to [Paws::DynamoDB::BatchWriteItem](https://metacpan.org/pod/Paws::DynamoDB::BatchWriteItem).

The following arguments are marshalled: Items in PutRequests, Keys in DeleteRequests.

By default (return\_paws\_output not set), returns a hashref of unprocessed items, in the same format as the RequestItems parameters. The unprocessed items are meant to be fed back into a new call to batch\_write(). See [Paws::DynamoDB::BatchWriteItemOutput](https://metacpan.org/pod/Paws::DynamoDB::BatchWriteItemOutput) for more information.

## delete

    my $result = $dynamodb->delete(
        TableName => 'users',
        Key => {
            user_id => 1001,
        },
    );

Deletes a single item in a table by primary key by delegating to [Paws::DynamoDB::DeleteItem](https://metacpan.org/pod/Paws::DynamoDB::DeleteItem).

The following arguments are marshalled: 'ExpressionAttributeValues', 'Key'.

By default (return\_paws\_output not set), returns undef, unless the 'ReturnValues' argument was set to 'ALL\_OLD', in which case an unmarshalled hashref of how the item looked prior to deletion is returned.

## get

    my $result = $dynamodb->get(
        TableName => 'users',
        Key => {
            user_id => 1000,
        },
    );

Returns a set of attributes for the item with the given primary key by delegating to [Paws::DynamoDB::GetItem](https://metacpan.org/pod/Paws::DynamoDB::GetItem).

The following arguments are marshalled: 'Key'.

By default (return\_paws\_output not set), returns the fetched item as an unmarshalled hashref, or undef if the item was not found.

## put

    my $result = $dynamodb->put(
        TableName => 'users',
        Item => {
            user_id => 1000,
            email => 'jdoe@example.com',
            tags => ['foo', 'bar', 'baz'],
        },
    );

Creates a new item, or replaces an old item with a new item by delegating to [Paws::DynamoDB::PutItem](https://metacpan.org/pod/Paws::DynamoDB::PutItem).

The following arguments are marshalled: 'ExpressionAttributeValues', 'Item'.

By default (return\_paws\_output not set), returns undef.

## query

    my $result = $dynamodb->query(
        TableName => 'users',
        IndexName => 'company_id',
        KeyConditionExpression => 'company_id = :company_id',
        ExpressionAttributeValues => {
            ':company_id' => 25,
        },
    );

Directly access items from a table by primary key or a secondary index by delegating to [Paws::DynamoDB::Query](https://metacpan.org/pod/Paws::DynamoDB::Query).

The following arguments are marshalled: 'ExclusiveStartKey', 'ExpressionAttributeValues'.

By default (return\_paws\_output not set), returns a hashref that looks like:

    {
        items => [
            { ... }, # unmarshalled item
            ...
        ],
        last_evaluated_key => {
            ... # unmarshalled key
        },
        count => $count,
    }

last\_evaluated\_key has a value if the query has more items to fetch. It can be used for the 'ExclusiveStartKey' value for a subsequent query.

## scan

    my $result = $dynamodb->scan(
        TableName => 'users',
        FilterExpression => 'first_name = :first_name',
        ExpressionAttributeValues => {
            ':first_name' => 'John',
        },
    );

Returns one or more items and item attributes by accessing every item in a table or a secondary index by delegating to [Paws::DynamoDB::Scan](https://metacpan.org/pod/Paws::DynamoDB::Scan).

The following arguments are marshalled: 'ExclusiveStartKey', 'ExpressionAttributeValues'.

Returns the same hashref as returned by query().

## update

    my $result = $dynamodb->update(
        TableName => 'users',
        Key: {
            user_id => 1000,
        },
        UpdateExpression: 'SET status = :new_status',
        ExpressionAttributeValues => {
            ':new_status' => 'active',
        },
    );

Edits an existing item's attributes, or adds a new item to the table if it does not already exist by delegating to [Paws::DynamoDB::UpdateItem](https://metacpan.org/pod/Paws::DynamoDB::UpdateItem).

# AUTHOR

Steve Caldwell <scaldwell@gmail.com>

# COPYRIGHT

Copyright 2017- Steve Caldwell

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

- [Paws](https://metacpan.org/pod/Paws)
- [Paws::DynamoDB](https://metacpan.org/pod/Paws::DynamoDB)
- [Net::Amazon::DynamoDB::Marshaler](https://metacpan.org/pod/Net::Amazon::DynamoDB::Marshaler)
- [DocumentClient](http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/DynamoDB/DocumentClient.html) in the AWS JavaScript SDK.

# ACKNOWLEDGEMENTS

Thanks to [Campus Explorer](http://www.campusexplorer.com), who allowed me to release this code as open source.

Thanks to Jose Luis Martinez Torres (JLMARTIN), for suggestions (and for Paws!).
