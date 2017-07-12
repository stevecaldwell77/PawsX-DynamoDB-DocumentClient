package PawsX::DynamoDB::DocumentClient::BatchGet;

use strict;
use 5.008_005;

use PawsX::DynamoDB::DocumentClient::Util qw(make_arg_transformer);

my $arg_transformer = make_arg_transformer(
    method_name => 'batch_get',
    to_marshall => [],
);

sub transform_arguments {
    my $class = shift;
    my %args = @_;
    return map { $_ => $arg_transformer->($_, $args{$_}) } keys %args;
}

sub transform_output {
    my ($class, $output) = @_;
    return undef;
}

sub run_service_command {
    my ($class, $service, %args) = @_;
    return $service->BatchGetItem(%args);
}

1;
__END__
