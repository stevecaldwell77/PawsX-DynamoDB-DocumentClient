package PawsX::DynamoDB::DocumentClient::BatchWrite;

use strict;
use 5.008_005;

use Net::Amazon::DynamoDB::Marshaler;
use PawsX::DynamoDB::DocumentClient::Util qw(unmarshal_attribute_map);

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
    my $tables = $output->UnprocessedItems->Map;
    return undef unless %$tables;
    return {
        map { $_ => _unmarshall_requests($tables->{$_}) }
        keys %$tables
    };
}

sub run_service_command {
    my ($class, $service, %args) = @_;
    return $service->BatchWriteItem(%args);
}

sub _marshall_request_items {
    my ($tables) = @_;
    die 'batch_write(): RequestItems must be a hashref' unless (
        $tables
        && ref $tables
        && ref $tables eq 'HASH'
    );
    return {
        map { $_ => _marshall_request_items_list($tables->{$_}) }
        keys %$tables
    };
}

sub _marshall_request_items_list {
    my ($requests) = @_;
    die 'batch_write(): RequestItems value must be an arrayref' unless (
        $requests
        && ref $requests
        && ref $requests eq 'ARRAY'
    );
    return [ map { _marshall_request($_) } @$requests ];
}

sub _marshall_request {
    my ($request) = @_;

    die 'batch_write(): write request must be a hashref' unless (
        $request
        && ref $request
        && ref $request eq 'HASH'
    );

    my $put_request = $request->{PutRequest};
    my $delete_request = $request->{DeleteRequest};

    die 'batch_write(): write request missing PutRequest or DeleteRequest'
        unless ($put_request || $delete_request);

    return _marshall_put_request($put_request) if $put_request;
    return _marshall_delete_request($delete_request);
}

sub _marshall_put_request {
    my ($val) = @_;
    die 'batch_write(): PutRequest must be a hashref' unless (
        $val
        && ref $val
        && ref $val eq 'HASH'
    );
    my $item = $val->{Item};
    die 'batch_write(): PutRequest must contain Item' unless $item;
    die q|batch_write(): PutRequest's Item must be a hashref| unless (
        ref $item
        && ref $item eq 'HASH'
    );
    return {
        PutRequest => {
            Item => dynamodb_marshal($item),
        },
    };
}

sub _marshall_delete_request {
    my ($val) = @_;
    die 'batch_write(): DeleteRequest must be a hashref' unless (
        $val
        && ref $val
        && ref $val eq 'HASH'
    );
    my $key = $val->{Key};
    die 'batch_write(): DeleteRequest must contain Key' unless $key;
    die q|batch_write(): DeleteRequest's Key must be a hashref| unless (
        ref $key
        && ref $key eq 'HASH'
    );
    return {
        DeleteRequest => {
            Key => dynamodb_marshal($key),
        },
    };
}

sub _unmarshall_requests {
    my ($requests) = @_;
    return [ map { _unmarshall_request($_) } @$requests ];
}

sub _unmarshall_request {
    my ($request) = @_;
    return $request->PutRequest
        ? _unmarshall_put_request($request->PutRequest)
        : _unmarshall_delete_request($request->DeleteRequest);
}

sub _unmarshall_put_request {
    my ($request) = @_;
    return {
        PutRequest => {
            Item => unmarshal_attribute_map($request->Item),
        },
    };
}

sub _unmarshall_delete_request {
    my ($request) = @_;
    return {
        DeleteRequest => {
            Key => unmarshal_attribute_map($request->Key),
        },
    };
}

1;
__END__
