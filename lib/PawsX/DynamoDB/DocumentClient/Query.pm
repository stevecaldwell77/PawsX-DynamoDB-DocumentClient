package PawsX::DynamoDB::DocumentClient::Query;

use strict;
use 5.008_005;

use PawsX::DynamoDB::DocumentClient::Util qw(
    make_arg_transformer
    unmarshal_attribute_map
);
use PerlX::Maybe;

my $arg_transformer = make_arg_transformer(
    method_name => 'query',
    to_marshall => ['ExpressionAttributeValues', 'ExclusiveStartKey'],
);

sub transform_arguments {
    my $class = shift;
    my %args = @_;
    return map { $_ => $arg_transformer->($_, $args{$_}) } keys %args;
}

sub transform_output {
    my ($class, $output) = @_;
    return {
        count => $output->Count,
        items => _unmarshall_items($output->Items),
        maybe last_evaluated_key => _unmarshall_key($output->LastEvaluatedKey),
    };
}

sub run_service_command {
    my ($class, $service, %args) = @_;
    return $service->Query(%args);
}

sub _unmarshall_items {
    my ($items) = @_;
    return [ map { unmarshal_attribute_map($_) } @$items ];
}

sub _unmarshall_key {
    my ($key) = @_;
    return undef unless $key && %{ $key->Map };
    return unmarshal_attribute_map($key);
}

1;
__END__
