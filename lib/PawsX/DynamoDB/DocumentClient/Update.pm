package PawsX::DynamoDB::DocumentClient::Update;

use strict;
use 5.008_005;

use PawsX::DynamoDB::DocumentClient::Util qw(make_arg_transformer unmarshal_attribute_map);

my $arg_transformer = make_arg_transformer(
    method_name => 'update',
    to_marshall => ['ExpressionAttributeValues', 'Key'],
);

sub transform_arguments {
    my $class = shift;
    my %args = @_;
    my $force_type = delete $args{force_type};
    return map
        {
            $_ => $arg_transformer->($_, $args{$_}, $force_type)
        }
        keys %args;
}

sub transform_output {
    my ($class, $output) = @_;
    if ($output->Attributes) {
        my $item = unmarshal_attribute_map($output->Attributes);
        return $item if %$item;
    }
    return undef;
}

sub run_service_command {
    my ($class, $service, %args) = @_;
    return $service->UpdateItem(%args);
}

1;
__END__
