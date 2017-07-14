package PawsX::DynamoDB::DocumentClient::BatchGet;

use strict;
use 5.008_005;

use Net::Amazon::DynamoDB::Marshaler;
use PawsX::DynamoDB::DocumentClient::Util qw(unmarshal_attribute_map);
use PerlX::Maybe;

sub transform_arguments {
    my $class = shift;
    my %args = @_;
    return (
        %args,
        RequestItems => _marshall_request_items($args{RequestItems}),
    );
}

sub transform_output {
    my ($class, $output) = @_;
    my $response = $output->Responses;
    return {
        responses => _unmarshall_responses($output->Responses),
        unprocessed_keys => _unmarshall_unproc_keys($output->UnprocessedKeys),
    };
}

sub run_service_command {
    my ($class, $service, %args) = @_;
    return $service->BatchGetItem(%args);
}

sub _marshall_request_items {
    my ($items) = @_;
    die 'batch_get(): RequestItems must be a hashref' unless (
        $items
        && ref $items
        && ref $items eq 'HASH'
    );
    return { map { $_ => _marshall_request_item($items->{$_}) } keys %$items };
}

sub _marshall_request_item {
    my ($item) = @_;
    my $keys = $item->{Keys};
    die 'batch_get(): RequestItems entry must have Keys' unless $keys;
    die 'batch_get(): Keys must be arrayref' unless (
        ref $keys
        && ref $keys eq 'ARRAY'
    );
    die 'batch_get(): Keys entries must be hashrefs'
        for grep { !(ref $_ && ref $_ eq 'HASH') }
        @$keys;
    return {
        %$item,
        Keys => [ map { dynamodb_marshal($_) } @{$item->{Keys}} ],
    };
}

sub _unmarshall_responses {
    my ($responses) = @_;
    return undef unless $responses;
    my $tables = $responses->Map;
    return {
        map { $_ => _unmarshall_response_items($tables->{$_}) }
        keys %$tables
    };
}

sub _unmarshall_response_items {
    my ($items) = @_;
    return [ map { unmarshal_attribute_map($_) } @$items ];
}

sub _unmarshall_unproc_keys {
    my ($unprocessed) = @_;
    my $tables = $unprocessed->Map;
    return undef unless %$tables;
    return {
        map { $_ => _unmarshall_keys_and_attrs($tables->{$_}) }
        keys %$tables
    };
}

sub _unmarshall_keys_and_attrs {
    my ($obj) = @_;
    my $attr_names;
    if ($obj->ExpressionAttributeNames) {
        $attr_names = $obj->ExpressionAttributeNames->Map;
    };

    return {
        maybe ConsistentRead => $obj->ConsistentRead,
        maybe ProjectionExpression => $obj->ProjectionExpression,
        maybe ExpressionAttributeNames => $attr_names,
        Keys => [
            map { unmarshal_attribute_map($_) } @{$obj->Keys}
        ],
    }
}

1;
__END__
