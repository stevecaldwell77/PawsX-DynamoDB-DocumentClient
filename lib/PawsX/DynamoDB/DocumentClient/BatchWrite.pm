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
    return {
        map { $_ => _marshall_request_items_list($tables->{$_}) }
        keys %$tables
    };
}

sub _marshall_request_items_list {
    my ($requests) = @_;
    return [ map { _marshall_request($_) } @$requests ];
}

sub _marshall_request {
    my ($request) = @_;
    my ($type, $val) = %$request;
    return $type eq 'PutRequest' ? _marshall_put_request($request)
                                 : _marshall_delete_request($request);
}

sub _marshall_put_request {
    my ($request) = @_;
    my ($type, $val) = %$request;
    return {
        $type => {
            %$val,
            Item => dynamodb_marshal($val->{Item}),
        },
    };
}

sub _marshall_delete_request {
    my ($request) = @_;
    my ($type, $val) = %$request;
    return {
        $type => {
            %$val,
            Key => dynamodb_marshal($val->{Key}),
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
